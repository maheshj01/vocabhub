import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/onboarding/presentation/onboarding_page.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/utils/utils.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);
    final words = title.split(' ');

    // Own a branded dark gradient so the vibrant title + buttons stay readable
    // on every form factor and theme, instead of sitting on a bare white surface.
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
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      text: words.isNotEmpty ? words[0] : title,
                      style: GoogleFonts.quicksand(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(255, 87, 169, 110),
                      ),
                      children: [
                        if (words.length > 1)
                          TextSpan(
                            text: '\n${words[1]}',
                            style: GoogleFonts.quicksand(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        if (words.length > 2)
                          TextSpan(
                            text: '\n${words.sublist(2).join(' ')}',
                            style: GoogleFonts.quicksand(
                              fontSize: 38,
                              fontWeight: FontWeight.bold,
                              color: const Color.fromARGB(255, 243, 255, 106),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      VHButton(
                        width: 200,
                        onTap: () {
                          Navigate.push(
                            context,
                            const OnboardingPage(),
                            transitionDuration: const Duration(milliseconds: 500),
                            transitionType: TransitionType.reveal,
                          );
                        },
                        label: 'Take a tour',
                      ),
                      16.0.vSpacer(),
                      VHButton(
                        width: 200,
                        onTap: () {
                          if (user.isLoggedIn) {
                            Navigate.pushAndPopAll(context, AdaptiveLayout());
                          } else {
                            Navigate.push(context, AppSignIn(),
                                transitionType: TransitionType.scale);
                          }
                        },
                        label: 'Skip for now',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
