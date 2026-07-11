import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/onboarding/presentation/onboarding_page.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/responsive.dart';

/// The pre-tour welcome screen. Paints its own full-bleed branded gradient and
/// centers width-constrained content, so it reads well on every form factor.
class WelcomePage extends StatelessWidget {
  final String title;
  final String description;

  const WelcomePage({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Widget body(BuildContext _) => _WelcomeBody(title: title, description: description);
    return ResponsiveBuilder(
      initialAnimationValue: 0.1,
      desktopBuilder: body,
      tabletBuilder: body,
      mobileBuilder: body,
    );
  }
}

class _WelcomeBody extends ConsumerWidget {
  final String title;
  final String description;

  const _WelcomeBody({required this.title, required this.description});

  // Brand accent used across the splash + welcome, readable on the dark gradient.
  static const Color _accent = Color(0xFF57A96E);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);

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
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 32.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Spacer(flex: 3),
                    _logo(),
                    const SizedBox(height: 32),
                    _headline(),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.quicksand(
                        fontSize: 16,
                        height: 1.4,
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    const Spacer(flex: 4),
                    VHButton(
                      width: double.infinity,
                      height: 54,
                      backgroundColor: _accent,
                      foregroundColor: Colors.white,
                      label: 'Take a tour',
                      onTap: () => Navigate.push(
                        context,
                        const OnboardingPage(),
                        transitionDuration: const Duration(milliseconds: 500),
                        transitionType: TransitionType.reveal,
                      ),
                    ),
                    const SizedBox(height: 14),
                    VHButton(
                      width: double.infinity,
                      height: 54,
                      backgroundColor: Colors.transparent,
                      foregroundColor: Colors.white.withValues(alpha: 0.85),
                      label: 'Skip for now',
                      onTap: () {
                        if (user.isLoggedIn) {
                          Navigate.pushAndPopAll(context, AdaptiveLayout());
                        } else {
                          Navigate.push(context, AppSignIn(), transitionType: TransitionType.scale);
                        }
                      },
                    ),
                    const Spacer(flex: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _logo() {
    return Center(
      child: Container(
        width: 92,
        height: 92,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: _accent.withValues(alpha: 0.35), blurRadius: 32, spreadRadius: 2),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset('assets/icon.png', fit: BoxFit.cover),
        ),
      ),
    );
  }

  /// One cohesive headline: the leading words in white, the app name (the last
  /// word of [title]) accented. No more three-colour, three-size word salad.
  Widget _headline() {
    final parts = title.trim().split(' ');
    final lead = parts.length > 1 ? '${parts.sublist(0, parts.length - 1).join(' ')} ' : '';
    final brand = parts.isNotEmpty ? parts.last : title;

    final base = GoogleFonts.quicksand(fontSize: 30, fontWeight: FontWeight.w700, height: 1.15);

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: base.copyWith(color: Colors.white),
        children: [
          if (lead.isNotEmpty) TextSpan(text: lead),
          TextSpan(text: brand, style: base.copyWith(color: _accent)),
        ],
      ),
    );
  }
}
