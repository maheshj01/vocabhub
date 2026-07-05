import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/services/services/auth_repository.dart';
import 'package:vocabhub/services/services/service_base.dart';
import 'package:vocabhub/services/services/user.dart';
import 'package:vocabhub/utils/logger.dart';

/// Outcome of an authentication attempt, so the UI can react without knowing
/// anything about Firebase or Supabase.
enum AuthOutcome { success, accountDeleted, failed }

class AuthResult {
  final AuthOutcome outcome;
  final UserModel user;

  /// True when this sign-in created a brand-new profile row.
  final bool isNewUser;
  final String? errorMessage;

  const AuthResult({
    required this.outcome,
    required this.user,
    this.isNewUser = false,
    this.errorMessage,
  });
}

/// The single source of truth for the auth session.
///
/// It orchestrates three collaborators and owns none of their concerns:
///   • [AuthRepository]  — proves identity (Firebase: Google + phone)
///   • [UserService]     — the Supabase profile row, keyed on the Firebase uid
///   • [SharedPreferences] — the local session cache
///
/// UI observes the current user through `userNotifierProvider`, which watches
/// this controller.
class AuthController extends ChangeNotifier implements ServiceBase {
  AuthController({AuthRepository? repository}) : _repository = repository ?? AuthRepository();

  final AuthRepository _repository;
  final _logger = Logger('AuthController');

  static const _userKey = 'userKey';

  late SharedPreferences _prefs;
  UserModel _user = UserModel.init();

  UserModel get user => _user;
  bool get isLoggedIn => _user.isLoggedIn;

  @override
  Future<void> initService() async {
    _prefs = await SharedPreferences.getInstance();
    _user = _readCachedUser();
  }

  @override
  Future<void> disposeService() async {}

  // --------------------------------------------------------------------------
  // Session state
  // --------------------------------------------------------------------------

  /// Updates in-memory + cached user and notifies listeners.
  Future<void> setUser(UserModel user) async {
    _user = user;
    await _prefs.setString(_userKey, json.encode(user.toJson()));
    notifyListeners();
  }

  UserModel _readCachedUser() {
    final raw = _prefs.getString(_userKey) ?? '';
    if (raw.isEmpty) return UserModel.init();
    try {
      return UserModel.fromJson(json.decode(raw) as Map<String, dynamic>);
    } catch (_) {
      return UserModel.init();
    }
  }

  /// Re-validates the cached session against Supabase on app launch.
  Future<void> restoreSession() async {
    if (_user.isEmpty || !_user.isLoggedIn) return;
    try {
      final fresh = _user.uid.isNotEmpty
          ? await UserService.findByUid(uid: _user.uid)
          : await UserService.findByEmail(email: _user.email);
      if (fresh.isNotEmpty) {
        await setUser(fresh.copyWith(isLoggedIn: true));
      }
    } catch (e) {
      _logger.d('Session restore skipped: $e');
    }
  }

  // --------------------------------------------------------------------------
  // Google
  // --------------------------------------------------------------------------

  Future<AuthResult> signInWithGoogle({String? fcmToken}) async {
    try {
      final identity = await _repository.signInWithGoogle();
      return _resolveProfile(identity, fcmToken: fcmToken);
    } catch (e) {
      _logger.e('Google sign-in failed: $e');
      return AuthResult(outcome: AuthOutcome.failed, user: _user, errorMessage: e.toString());
    }
  }

  // --------------------------------------------------------------------------
  // Phone
  // --------------------------------------------------------------------------

  /// Starts phone verification. [onCodeSent] receives the verificationId to
  /// pass back into [verifyOtp]. Errors are surfaced as plain messages.
  Future<void> startPhoneVerification({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(String error) onError,
  }) async {
    try {
      await _repository.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onFailed: (e) => onError(e.message ?? 'Phone verification failed'),
      );
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<AuthResult> verifyOtp({
    required String verificationId,
    required String smsCode,
    String? fcmToken,
  }) async {
    try {
      final identity =
          await _repository.verifyOtp(verificationId: verificationId, smsCode: smsCode);
      return _resolveProfile(identity, fcmToken: fcmToken);
    } catch (e) {
      _logger.e('OTP verification failed: $e');
      return AuthResult(outcome: AuthOutcome.failed, user: _user, errorMessage: e.toString());
    }
  }

  // --------------------------------------------------------------------------
  // Shared: identity -> Supabase profile
  // --------------------------------------------------------------------------

  /// Turns a proven identity into a session.
  ///
  /// Phone users without an email get a **local, browse-only session** (no
  /// Supabase row) — the app's data is email-keyed (bookmarks, edits), so we
  /// persist a profile only once we have a verified email (via
  /// [linkEmailWithGoogle]). Identities that carry an email resolve/create the
  /// Supabase profile.
  Future<AuthResult> _resolveProfile(AuthUser identity, {String? fcmToken}) async {
    final email = identity.email;

    if (email == null || email.isEmpty) {
      final session = UserModel(
        uid: identity.uid,
        phone: identity.phoneNumber,
        name: identity.displayName ?? '',
        avatarUrl: identity.photoUrl,
        username: _deriveUsername(identity),
        token: fcmToken ?? _user.token,
        isLoggedIn: true,
        created_at: DateTime.now(),
        updated_at: DateTime.now(),
      );
      await setUser(session);
      return AuthResult(outcome: AuthOutcome.success, user: session, isNewUser: false);
    }

    return _resolveEmailProfile(identity, email, fcmToken: fcmToken);
  }

  /// Resolves the Supabase profile for an identity that has a verified [email].
  /// Merge-safe: an existing legacy row (found by email, with no/other uid) is
  /// updated in place so its history is preserved, rather than inserting a
  /// duplicate that would collide on the unique uid/email indexes.
  Future<AuthResult> _resolveEmailProfile(AuthUser identity, String email,
      {String? fcmToken}) async {
    UserModel profile = await UserService.findByUid(uid: identity.uid);
    bool isNewUser = false;
    bool mergeByEmail = false;

    if (profile.isEmpty) {
      final byEmail = await UserService.findByEmail(email: email);
      if (byEmail.isNotEmpty) {
        profile = byEmail;
        mergeByEmail = true;
      } else {
        isNewUser = true;
        profile = UserModel(
          uid: identity.uid,
          email: email,
          username: _deriveUsername(identity),
          created_at: DateTime.now(),
          updated_at: DateTime.now(),
        );
      }
    }

    if (profile.isDeleted) {
      return AuthResult(outcome: AuthOutcome.accountDeleted, user: profile);
    }

    profile = profile.copyWith(
      uid: identity.uid,
      email: email,
      phone: identity.phoneNumber ?? profile.phone,
      name: profile.name.isEmpty ? (identity.displayName ?? '') : profile.name,
      avatarUrl: profile.avatarUrl ?? identity.photoUrl,
      isLoggedIn: true,
      token: fcmToken ?? profile.token,
      updated_at: DateTime.now(),
    );

    final saved = mergeByEmail
        ? await UserService.updateProfileByEmail(email, profile)
        : await UserService.upsertProfile(profile);
    await setUser(saved.copyWith(isLoggedIn: true));
    return AuthResult(outcome: AuthOutcome.success, user: _user, isNewUser: isNewUser);
  }

  /// Attaches a verified email to the current (phone) session by linking a
  /// Google account, then resolves/merges the Supabase profile. This is how a
  /// browse-only phone user becomes a full user and how a legacy Google account
  /// is adopted under the phone user's uid.
  Future<AuthResult> linkEmailWithGoogle({String? fcmToken}) async {
    try {
      final linked = await _repository.linkGoogleAccount();
      final email = linked.email;
      if (email == null || email.isEmpty) {
        return AuthResult(
            outcome: AuthOutcome.failed,
            user: _user,
            errorMessage: 'Could not read an email from that Google account.');
      }
      // Preserve the phone number from the current session on the merged profile.
      final identity = AuthUser(
        uid: linked.uid,
        email: email,
        displayName: linked.displayName,
        photoUrl: linked.photoUrl,
        phoneNumber: linked.phoneNumber ?? _user.phone,
      );
      return _resolveEmailProfile(identity, email, fcmToken: fcmToken ?? _user.token);
    } on FirebaseAuthException catch (e) {
      final message = e.code == 'credential-already-in-use'
          ? 'This Google account is already registered. Sign in with Google instead.'
          : (e.message ?? 'Failed to link email.');
      _logger.e('linkEmailWithGoogle: ${e.code} $message');
      return AuthResult(
          outcome: AuthOutcome.failed, user: _user, errorMessage: message);
    } catch (e) {
      _logger.e('linkEmailWithGoogle failed: $e');
      return AuthResult(
          outcome: AuthOutcome.failed, user: _user, errorMessage: e.toString());
    }
  }

  String _deriveUsername(AuthUser identity) {
    if (identity.email != null && identity.email!.contains('@')) {
      return identity.email!.split('@').first;
    }
    if (identity.phoneNumber != null && identity.phoneNumber!.isNotEmpty) {
      return identity.phoneNumber!;
    }
    return identity.uid;
  }

  // --------------------------------------------------------------------------
  // Sign out
  // --------------------------------------------------------------------------

  Future<void> signOut() async {
    try {
      if (_user.uid.isNotEmpty) {
        await UserService.setLoginState(uid: _user.uid, isLoggedIn: false);
      }
      await _repository.signOut();
    } catch (e) {
      _logger.e('Sign-out error: $e');
    } finally {
      await setUser(_user.copyWith(isLoggedIn: false));
    }
  }
}
