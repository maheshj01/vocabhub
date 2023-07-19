import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/button.dart';

import 'onboard.dart';

class WelcomePage extends StatefulWidget {
  final String title;
  final String description;

  const WelcomePage({
    Key? key,
    required this.title,
    required this.description,
  }) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  Future<void> startOnBoarding() async {}

  bool isLoading = false;
  String title = 'Welcome to Vocabhub';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final themeData = VocabTheme.getThemeFromSeed(Colors.blue);
    return Material(
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: title.split(' ')[0],
                    style: GoogleFonts.quicksand(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 87, 169, 110),
                    ),
                    children: [
                      TextSpan(
                        text: '\n${title.split(' ')[1]}',
                        style: GoogleFonts.quicksand(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: '\n${title.split(' ')[2]}',
                        style: GoogleFonts.quicksand(
                          fontSize: 38,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 243, 255, 106),
                        ),
                      )
                    ]),
              ),
            ),
            Column(
              children: [
                VHButton(
                    width: 160,
                    onTap: () {
                      Navigate.push(context, OnboardingPage(),
                          transitionType: TransitionType.reveal);
                    },
                    label: 'Take a tour'),
                16.0.vSpacer(),
                VHButton(
                    width: 200,
                    onTap: () {
                      Navigate.push(context, AppSignIn(), transitionType: TransitionType.scale);
                    },
                    label: 'Skip for now'),
              ],
            )
          ],
        ),
      ),
    );
  }
}
