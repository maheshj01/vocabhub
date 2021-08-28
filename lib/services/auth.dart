import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/widgets.dart';

class Authentication {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      //   'https://www.googleapis.com/auth/contacts.readonly',
    ],
  );

  static String tableName = '$USER_TABLE_NAME';

  Future<UserModel?> googleSignIn(BuildContext context,
      {bool isLogin = true, bool socialSignUp = false}) async {
    UserModel? user;
    try {
      showCircularIndicator(context);
      await _googleSignIn.signOut();
      final result = await _googleSignIn.signIn();
      final googleKey = await result!.authentication;
      final String? accessToken = googleKey.accessToken;
      final String? idToken = googleKey.idToken;
      user = UserModel(
          name: _googleSignIn.currentUser!.displayName ?? '',
          email: _googleSignIn.currentUser!.email,
          avatarUrl: _googleSignIn.currentUser!.photoUrl,
          idToken: idToken,
          accessToken: accessToken);
      print('signed In as ${user.name}');
      stopCircularIndicator(context);
    } catch (error) {
      stopCircularIndicator(context);
      showMessage(context, 'Failed to signIn');
      throw 'Failed to signIn';
    }
    return user;
  }

  Future<bool> googleSignOut(BuildContext context) async {
    try {
      _googleSignIn.disconnect();
      if (await _googleSignIn.isSignedIn()) {
        _googleSignIn.signOut();
        return false;
      } else {
        return true;
      }
    } catch (err) {
      showMessage(context, 'Failed to signIn!');
      return false;
    }
  }
}
