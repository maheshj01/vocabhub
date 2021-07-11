import 'package:flutter/material.dart';

class AppSignIn extends StatefulWidget {
  const AppSignIn({Key? key}) : super(key: key);

  @override
  _AppSignInState createState() => _AppSignInState();
}

class _AppSignInState extends State<AppSignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(),
        SizedBox(
          height: 100,
        ),
        Expanded(
          child: Center(child: Text('Vocabhub')),
        ),
        ElevatedButton(
          onPressed: () {},
          child: Text('Sign In'),
        ),
        SizedBox(
          height: 100,
        )
      ],
    ));
  }
}
