import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/pages/phone_auth.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/auth_flow.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/responsive.dart';

class AppSignIn extends ConsumerStatefulWidget {
  const AppSignIn({Key? key}) : super(key: key);

  @override
  _AppSignInState createState() => _AppSignInState();
}

class _AppSignInState extends ConsumerState<AppSignIn> {
  /// Brand accent shared with the splash + welcome screens.
  static const Color _accent = Color(0xFF57A96E);

  /// Google sign-in: identity + profile resolution + persistence all happen in
  /// [AuthController]; this widget only drives loading state and navigation.
  Future<void> _handleGoogleSignIn(BuildContext context) async {
    _requestNotifier.value = Response(state: RequestState.active);
    final result = await authController.signInWithGoogle(
      fcmToken: pushNotificationService.fcmToken,
    );
    _requestNotifier.value = Response(state: RequestState.done);
    if (!context.mounted) return;
    await handleAuthResult(context, result, firebaseAnalytics);
  }

  void _handlePhoneSignIn(BuildContext context) {
    Navigate.push(context, const PhoneAuthPage(), transitionType: TransitionType.rtl);
  }

  late Analytics firebaseAnalytics;
  final ValueNotifier<Response> _requestNotifier =
      ValueNotifier<Response>(Response(state: RequestState.none));

  @override
  void dispose() {
    _requestNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    firebaseAnalytics = Analytics.instance;
  }

  /// Full-bleed branded gradient so sign-in matches the splash/welcome instead
  /// of falling back to a bare white surface.
  Widget _branded({required Widget child}) {
    return Container(
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B1F17), Color(0xFF14382A), Color(0xFF0A1210)],
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: SafeArea(child: child),
      ),
    );
  }

  Widget _logo({double size = 76}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: _accent.withValues(alpha: 0.35), blurRadius: 28, spreadRadius: 1),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset('assets/icon.png', fit: BoxFit.cover),
      ),
    );
  }

  Widget _title(String text, {double fontSize = 30}) {
    return Text(
      text,
      style: GoogleFonts.quicksand(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: Colors.white,
        height: 1.1,
      ),
    );
  }

  Widget _subtitle(String text) {
    return Text(
      text,
      style: GoogleFonts.quicksand(
        fontSize: 15,
        height: 1.4,
        color: Colors.white.withValues(alpha: 0.70),
      ),
    );
  }

  Widget _googleButton(Response request) {
    return VHButton(
      width: double.infinity,
      height: 54,
      foregroundColor: Colors.black87,
      backgroundColor: Colors.white,
      leading: Image.asset('$GOOGLE_ASSET_PATH', height: 26),
      label: 'Sign in with Google',
      isLoading: request.state == RequestState.active,
      onTap: () => _handleGoogleSignIn(context),
    );
  }

  Widget _phoneButton() {
    return VHButton(
      width: double.infinity,
      height: 54,
      foregroundColor: Colors.white,
      backgroundColor: _accent,
      leading: const Icon(Icons.phone_android, color: Colors.white, size: 22),
      label: 'Continue with Phone',
      onTap: () => _handlePhoneSignIn(context),
    );
  }

  Widget _guestButton() {
    return VHButton(
      width: double.infinity,
      height: 54,
      foregroundColor: Colors.white.withValues(alpha: 0.85),
      backgroundColor: Colors.transparent,
      label: 'Continue as a guest',
      onTap: () =>
          Navigate.pushReplace(context, AdaptiveLayout(), transitionType: TransitionType.scale),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeUtils.size = MediaQuery.of(context).size;

    return ValueListenableBuilder<Response>(
      valueListenable: _requestNotifier,
      builder: (BuildContext context, Response request, Widget? child) {
        Widget actions() => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _googleButton(request),
                const SizedBox(height: 14),
                _phoneButton(),
                const SizedBox(height: 14),
                _guestButton(),
              ],
            );

        return IgnorePointer(
          ignoring: request.state == RequestState.active,
          child: ResponsiveBuilder(
            desktopBuilder: (x) => _branded(
              child: Row(
                children: [
                  // Brand / greeting panel.
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _logo(size: 88),
                          const SizedBox(height: 28),
                          _title('Welcome back.', fontSize: 40),
                          const SizedBox(height: 12),
                          _subtitle(
                              'Sign in to sync your words, bookmarks,\nand contributions across devices.'),
                        ],
                      ),
                    ),
                  ),
                  // Actions panel.
                  Expanded(
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 360),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: actions(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            mobileBuilder: (x) => _branded(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(flex: 3),
                        Center(child: _logo()),
                        const SizedBox(height: 28),
                        Center(child: _title('Welcome!')),
                        const SizedBox(height: 10),
                        Center(
                          child: _subtitle('Sign in to save your progress'),
                        ),
                        const Spacer(flex: 4),
                        actions(),
                        const Spacer(flex: 1),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class ImageBackground extends StatelessWidget {
  final Widget child;
  final String? imageSrc;
  const ImageBackground({Key? key, required this.child, this.imageSrc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(imageSrc ?? '$WALLPAPER_1'),
          fit: BoxFit.cover,
        ),
      ),
      child: child,
    );
  }
}
