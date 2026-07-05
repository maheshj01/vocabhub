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

  /// Interactive Google sign-in, exchanged into a Firebase credential.
  Future<AuthUser> signInWithGoogle() async {
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
    final userCredential = await _auth.signInWithCredential(credential);
    final user = userCredential.user!;

    return AuthUser(
      uid: user.uid,
      email: user.email ?? account.email,
      displayName: user.displayName ?? account.displayName,
      photoUrl: user.photoURL ?? account.photoUrl,
      phoneNumber: user.phoneNumber,
    );
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
    final user = userCredential.user!;
    return AuthUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoUrl: user.photoURL,
      phoneNumber: user.phoneNumber,
    );
  }

  Future<void> signOut() => _auth.signOut();
}
