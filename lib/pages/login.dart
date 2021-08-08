import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/services/auth.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';

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
        account == null
            ? CircularProgressIndicator()
            : CircularAvatar(
                url: account!.avatarUrl,
                name: account!.name,
              ),
        ElevatedButton(
          onPressed: () => _handleSignIn(context),
          child: Text('Sign In'),
        ),
        SizedBox(
          height: 100,
        )
      ],
    ));
  }
}
