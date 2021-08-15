import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/pages/home.dart';
import 'package:vocabhub/services/auth.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/settings.dart';

class AppSignIn extends StatefulWidget {
  const AppSignIn({Key? key}) : super(key: key);

  @override
  _AppSignInState createState() => _AppSignInState();
}

class _AppSignInState extends State<AppSignIn> {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  Authentication auth = Authentication();
  Future<void> _handleSignIn(BuildContext context) async {
    try {
      account = await auth.googleSignIn(context);
      print('SIGNING IN');
      setState(() {});
    } catch (error) {
      print(error);
    }
  }

  User? account;
  @override
  Widget build(BuildContext context) {
    Widget _heading(String text) {
      return Text(
        '$text',
        style: Theme.of(context).textTheme.headline3!,
      );
    }

    Widget _signInButton() {
      return Align(
          alignment: Alignment.center,
          child: VocabButton(
            width: 300,
            leading: Image.asset('assets/google.png', height: 32),
            label: 'Sign in with Google',
            onTap: () {
              print('object');
            }, // _handleSignIn(context),
            backgroundColor: Colors.white,
          ));
    }

    Widget _skipButton() {
      return Align(
          alignment: Alignment.center,
          child: VocabButton(
            width: 300,
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
            label: 'Skip Sign in',
            onTap: () {
              Navigate().pushReplace(context, MyHomePage(title: '$APP_TITLE'),
                  slideTransitionType: SlideTransitionType.ttb);
              Settings().setSkipCount = Settings.maxSkipCount;
            }, // _handleSignIn(context),
          ));
    }

    Settings.size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: surfaceGreen,
        body: Settings.size.width > DESKTOP_WIDTH
            ? Row(
                children: [
                  AnimatedContainer(
                    width: Settings.size.width / 2,
                    duration: Duration(seconds: 1),
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _heading('Hi!'),
                        _heading('Welcome Back.'),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: surfaceGrey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(child: Container()),
                          _signInButton(),
                          SizedBox(
                            height: 20,
                          ),
                          _skipButton(),
                          Expanded(child: Container()),
                        ],
                      ),
                    ),
                  )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 200,
                  ),
                  _heading('Hi!'),
                  _heading('Welcome Back.'),
                  Expanded(child: Container()),
                  _signInButton(),
                  SizedBox(
                    height: 20,
                  ),
                  _skipButton(),
                  Expanded(child: Container()),
                ],
              ));
  }
}

class VocabButton extends StatefulWidget {
  VocabButton(
      {Key? key,
      this.backgroundColor = Colors.white,
      this.foregroundColor = Colors.black,
      required this.onTap,
      required this.label,
      this.height = 55.0,
      this.width,
      this.leading})
      : super(key: key);

  final Function() onTap;

  /// label on the button
  final String label;

  final Widget? leading;

  final Color backgroundColor;

  final Color foregroundColor;

  final double height;

  final double? width;

  @override
  _VocabButtonState createState() => _VocabButtonState();
}

class _VocabButtonState extends State<VocabButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: widget.width,
      child: ElevatedButton(
        style: ButtonStyle(
            foregroundColor: MaterialStateColor.resolveWith(
                (states) => widget.foregroundColor),
            backgroundColor: MaterialStateColor.resolveWith(
                (states) => widget.backgroundColor)),
        onPressed: widget.onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.leading ?? SizedBox(),
            SizedBox(width: widget.leading == null ? 0 : 20),
            Text(
              '${widget.label}',
              style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontWeight: FontWeight.bold, color: widget.foregroundColor),
            ),
          ],
        ),
      ),
    );
  }
}
