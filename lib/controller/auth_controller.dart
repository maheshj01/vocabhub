import 'dart:convert';

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

  /// Given a proven identity, find-or-create the Supabase profile keyed on uid,
  /// link any legacy email-only row, persist login state, and cache locally.
  Future<AuthResult> _resolveProfile(AuthUser identity, {String? fcmToken}) async {
    UserModel profile = await UserService.findByUid(uid: identity.uid);
    bool isNewUser = false;

    // Legacy link: pre-Firebase Google users exist keyed on email with no uid.
    if (profile.isEmpty && identity.email != null && identity.email!.isNotEmpty) {
      final legacy = await UserService.findByEmail(email: identity.email!);
      if (legacy.isNotEmpty) {
        profile = legacy.copyWith(uid: identity.uid);
      }
    }

    if (profile.isEmpty) {
      // Brand-new account.
      isNewUser = true;
      profile = UserModel(
        uid: identity.uid,
        email: identity.email ?? '',
        phone: identity.phoneNumber,
        name: identity.displayName ?? '',
        avatarUrl: identity.photoUrl,
        username: _deriveUsername(identity),
        created_at: DateTime.now(),
        updated_at: DateTime.now(),
      );
    }

    if (profile.isDeleted) {
      return AuthResult(outcome: AuthOutcome.accountDeleted, user: profile);
    }

    profile = profile.copyWith(
      isLoggedIn: true,
      token: fcmToken ?? profile.token,
      phone: identity.phoneNumber ?? profile.phone,
      updated_at: DateTime.now(),
    );

    final saved = await UserService.upsertProfile(profile);
    await setUser(saved.copyWith(isLoggedIn: true));
    return AuthResult(outcome: AuthOutcome.success, user: _user, isNewUser: isNewUser);
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
