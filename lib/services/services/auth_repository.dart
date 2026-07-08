import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vocabhub/utils/logger.dart';

/// A provider-agnostic snapshot of an authenticated identity.
///
/// This is what [AuthRepository] hands back after a successful sign-in. It
/// deliberately exposes only the identity facts the app needs — the profile
/// (stored in Supabase) is resolved separately by the auth controller.
class AuthUser {
  /// Firebase Auth uid — stable across Google and phone providers.
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
  });
}

/// Owns the identity layer: Firebase Authentication for both Google and phone.
///
/// Nothing about the Supabase profile or local session lives here — this class
/// only proves *who* the user is and returns an [AuthUser]. Orchestration
/// (profile lookup, caching, navigation) is the controller's job.
class AuthRepository {
  AuthRepository({FirebaseAuth? auth, GoogleSignIn? googleSignIn})
      : _auth = auth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final _logger = Logger('AuthRepository');

  bool _googleInitialized = false;

  static const List<String> _scopes = <String>[
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/userinfo.email',
  ];

  User? get currentUser => _auth.currentUser;

  /// Emits on sign-in / sign-out. Useful for keeping the app session in sync.
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // --------------------------------------------------------------------------
  // Google
  // --------------------------------------------------------------------------

  /// Runs the interactive Google flow and returns a Firebase credential plus the
  /// chosen account (for name/photo/email fallbacks). Shared by sign-in and
  /// account-linking so the two never diverge.
  Future<({AuthCredential credential, GoogleSignInAccount account})>
      _obtainGoogleCredential() async {
    if (!_googleInitialized) {
      // Reads client IDs from the native config (google-services.json /
      // GoogleService-Info.plist). Pass `serverClientId` here if a backend
      // ID token is required on Android.
      await _googleSignIn.initialize();
      _googleInitialized = true;
    }

    // Force the account chooser so switching accounts works.
    await _googleSignIn.signOut();

    final GoogleSignInAccount account = await _googleSignIn.authenticate(scopeHint: _scopes);
    final String? idToken = account.authentication.idToken;

    String? accessToken;
    try {
      final authorization = await account.authorizationClient.authorizeScopes(_scopes);
      accessToken = authorization.accessToken;
    } catch (e) {
      _logger.d('Google scope authorization skipped: $e');
    }

    final credential = GoogleAuthProvider.credential(
      idToken: idToken,
      accessToken: accessToken,
    );
    return (credential: credential, account: account);
  }

  AuthUser _toAuthUser(User user, {GoogleSignInAccount? googleAccount}) => AuthUser(
        uid: user.uid,
        email: user.email ?? googleAccount?.email,
        displayName: user.displayName ?? googleAccount?.displayName,
        photoUrl: user.photoURL ?? googleAccount?.photoUrl,
        phoneNumber: user.phoneNumber,
      );

  /// Interactive Google sign-in, exchanged into a Firebase credential.
  Future<AuthUser> signInWithGoogle() async {
    final google = await _obtainGoogleCredential();
    final userCredential = await _auth.signInWithCredential(google.credential);
    return _toAuthUser(userCredential.user!, googleAccount: google.account);
  }

  /// Links a Google account to the CURRENT (e.g. phone) Firebase user, giving it
  /// a verified email under the same uid. Used to attach/verify an email to a
  /// phone-auth session so it can be merged with a legacy Google profile.
  ///
  /// Throws [FirebaseAuthException] with code `credential-already-in-use` if the
  /// Google account already belongs to a different Firebase user — the caller
  /// must decide how to reconcile.
  Future<AuthUser> linkGoogleAccount() async {
    final current = _auth.currentUser;
    if (current == null) {
      throw FirebaseAuthException(
        code: 'no-current-user',
        message: 'Sign in first before linking an email.',
      );
    }
    final google = await _obtainGoogleCredential();
    try {
      final userCredential = await current.linkWithCredential(google.credential);
      return _toAuthUser(userCredential.user!, googleAccount: google.account);
    } on FirebaseAuthException catch (e) {
      // The Google account is already its own Firebase user, so it can't be
      // linked onto the phone user. Since email is the account key, sign into
      // that existing Google account instead (same credential — no re-prompt).
      // The phone-only Firebase user is left orphaned; see todo.
      if (e.code == 'credential-already-in-use' || e.code == 'email-already-in-use') {
        _logger.d('Google account already exists; signing into it instead.');
        final userCredential = await _auth.signInWithCredential(google.credential);
        return _toAuthUser(userCredential.user!, googleAccount: google.account);
      }
      rethrow;
    }
  }

  // --------------------------------------------------------------------------
  // Phone
  // --------------------------------------------------------------------------

  /// Kicks off phone verification. On mobile this triggers an SMS (or silent
  /// auto-retrieval on Android). Call [verifyOtp] once the user enters the code.
  ///
  /// [onCodeSent] receives the `verificationId` needed by [verifyOtp].
  /// [onAutoVerified] fires on Android instant verification — the credential is
  /// ready with no code entry.
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required void Function(String verificationId) onCodeSent,
    required void Function(FirebaseAuthException error) onFailed,
    void Function(PhoneAuthCredential credential)? onAutoVerified,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      timeout: timeout,
      verificationCompleted: (credential) => onAutoVerified?.call(credential),
      verificationFailed: onFailed,
      codeSent: (verificationId, _) => onCodeSent(verificationId),
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  /// Completes phone sign-in with the SMS code the user typed.
  Future<AuthUser> verifyOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    final credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    return signInWithPhoneCredential(credential);
  }

  /// Completes phone sign-in from a ready credential (used by Android
  /// instant-verification and by [verifyOtp]).
  Future<AuthUser> signInWithPhoneCredential(PhoneAuthCredential credential) async {
    final userCredential = await _auth.signInWithCredential(credential);
    return _toAuthUser(userCredential.user!);
  }

  Future<void> signOut() => _auth.signOut();
}
