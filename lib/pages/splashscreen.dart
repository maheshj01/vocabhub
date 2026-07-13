import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/onboarding/onboarding.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/utils/size_utils.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> with TickerProviderStateMixin {
  /// Cross-fade duration for the hand-off from the splash to the next screen, so
  /// the app UI eases in instead of snapping.
  static const _handoffDuration = Duration(milliseconds: 600);

  /// Plays once. Drives the title's fade + scale entrance and, on completion,
  /// hands off to navigation (preserving the original ~1.8s dwell).
  late final AnimationController _entrance = AnimationController(
    duration: const Duration(milliseconds: 1800),
    vsync: this,
  );

  /// Loops (when ambient animations are enabled) to drive the drifting glows
  /// and the title shimmer. Started in [initState] so it can be suppressed in
  /// tests — an endless animation makes `pumpAndSettle()` never settle.
  late final AnimationController _ambient = AnimationController(
    duration: const Duration(seconds: 8),
    vsync: this,
  );

  late final Animation<double> _fadeIn = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
  );
  late final Animation<double> _scaleIn = Tween<double>(begin: 0.86, end: 1.0).animate(
    CurvedAnimation(parent: _entrance, curve: Curves.easeOutCubic),
  );
  late final Animation<double> _taglineIn = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
    if (ambientAnimationsEnabled) _ambient.repeat();
    _entrance.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Onboarding is now responsive, so it runs on every form factor: show it
        // to anyone who hasn't completed it; otherwise resolve the session.
        if (settingsController.isOnboarded) {
          handleNavigation();
        } else {
          Navigate.pushReplace(
            context,
            WelcomePage(
              title: 'Welcome to VocabHub',
              description: 'Your companion to learn new words everyday',
            ),
            transitionType: TransitionType.fade,
            transitionDuration: _handoffDuration,
          );
        }
      }
    });
  }

  Future<void> handleNavigation() async {
    final user = ref.watch(userNotifierProvider);
    // A signed-in user is identified by isLoggedIn + any identity (uid/email/
    // phone) — not email alone, so phone-auth users are recognized too.
    if (user.isLoggedIn && user.isNotEmpty) {
      Navigate.pushReplace(context, AdaptiveLayout(),
          transitionType: TransitionType.fade, transitionDuration: _handoffDuration);
    } else {
      final int count = settingsController.skipCount + 1;
      settingsController.setSkipCount = count;
      if (count % 3 != 0) {
        Navigate.pushReplace(context, AdaptiveLayout(),
            transitionType: TransitionType.fade, transitionDuration: _handoffDuration);
      } else {
        Navigate.pushReplace(context, AppSignIn(),
            transitionType: TransitionType.fade, transitionDuration: _handoffDuration);
      }
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SizeUtils.size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          _AuroraBackground(animation: _ambient),
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scaleIn,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _ShimmerTitle(text: Constants.APP_TITLE, animation: _ambient),
                    const SizedBox(height: 18),
                    FadeTransition(
                      opacity: _taglineIn,
                      child: Text(
                        'Learn a new word, every day',
                        style: GoogleFonts.quicksand(
                          fontSize: 16,
                          letterSpacing: 0.6,
                          color: Colors.white.withValues(alpha: 0.75),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A dark branded base with two soft radial glows that drift on slow, offset
/// orbits — an aurora-like ambient motion. Pure gradient work, so it's cheap.
class _AuroraBackground extends StatelessWidget {
  final Animation<double> animation;
  const _AuroraBackground({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final t = animation.value * 2 * math.pi;
        final glowA = Alignment(0.55 * math.cos(t), 0.55 * math.sin(t));
        final glowB = Alignment(-0.5 * math.cos(t * 0.8 + 1.2), -0.45 * math.sin(t * 0.8 + 1.2));
        return DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF0B1F17), Color(0xFF0A1210), Color(0xFF102A20)],
            ),
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: glowA,
                radius: 1.1,
                colors: [const Color(0xFF2E7D5B).withValues(alpha: 0.55), Colors.transparent],
              ),
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: glowB,
                  radius: 0.9,
                  colors: [const Color(0xFF1DE9B6).withValues(alpha: 0.16), Colors.transparent],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// The app title filled with a brand-colored gradient that sweeps across it,
/// giving a soft shimmer. A green glow shadow lifts it off the background.
class _ShimmerTitle extends StatelessWidget {
  final String text;
  final Animation<double> animation;
  const _ShimmerTitle({required this.text, required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final shift = animation.value * 2; // sweep offset
        return ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (rect) => LinearGradient(
            begin: Alignment(-1 + shift, -0.3),
            end: Alignment(1 + shift, 0.3),
            tileMode: TileMode.mirror,
            colors: const [
              Color(0xFF57A96E),
              Colors.white,
              Color(0xFFF3FF6A),
              Colors.white,
              Color(0xFF57A96E),
            ],
            stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
          ).createShader(rect),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.quicksand(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
              shadows: [
                Shadow(color: const Color(0xFF57A96E).withValues(alpha: 0.6), blurRadius: 28),
              ],
            ),
          ),
        );
      },
    );
  }
}
