import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/pages/login.dart';
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
  String title = 'Welcome to VocabHub';
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Material(
      child: Container(
        color: Color.fromARGB(255, 87, 169, 110),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                    text: widget.title.split(' ')[0],
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: [
                      TextSpan(
                        text: '\n${widget.title.split(' ')[1]}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      TextSpan(
                        text: '\n${widget.title.split(' ')[2]}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
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
                    label: 'Take a Tour'),
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
