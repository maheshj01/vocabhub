import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:vocabhub/utils/utility.dart';

class AuthService {
  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
      // Constants.SIGN_IN_SCOPE_URL,
    ],
  );

  static String _tableName = '${Constants.USER_TABLE_NAME}';
  static final _logger = Logger("AuthService");

  static Future<Response> registerUser(UserModel user) async {
    final resp = Response(didSucced: false, message: "Failed");
    final json = user.toJson();
    json['created_at'] = DateTime.now().toIso8601String();
    json['isLoggedIn'] = true;
    try {
      final response =
          await DatabaseService.insertIntoTable(json, table: Constants.USER_TABLE_NAME);
      if (response.status == 201) {
        resp.didSucced = true;
        resp.message = 'Success';
        resp.data = response.data;
      } else {
        _logger.e('error caught ${response.error}');
        throw "Failed to register new user";
      }
    } catch (_) {
      _logger.e('error caught $_');
      throw "Failed to register new user";
    }
    return resp;
  }

  Future<UserModel?> googleSignIn(BuildContext context,
      {bool isLogin = true, bool socialSignUp = false}) async {
    UserModel? user;
    try {
      await _googleSignIn.signOut();
      final result = await _googleSignIn.signIn();
      final googleKey = await result!.authentication;
      final String? accessToken = googleKey.accessToken;
      final String? idToken = googleKey.idToken;
      final String email = _googleSignIn.currentUser!.email;

      /// default username
      final String username = email.split('@').first;
      user = UserModel(
          name: _googleSignIn.currentUser!.displayName ?? '',
          email: _googleSignIn.currentUser!.email,
          avatarUrl: _googleSignIn.currentUser!.photoUrl,
          idToken: idToken,
          username: username,
          accessToken: accessToken);
    } catch (error) {
      _logger.e(error.toString());
      showMessage(context, 'Failed to signIn');
      throw 'Failed to signIn';
    }
    return user;
  }

  Future<bool> googleSignOut(BuildContext context) async {
    try {
      await _googleSignIn.disconnect();
      return true;
    } catch (err) {
      _logger.e(err.toString());
      showMessage(context, 'Failed to signout!');
      return false;
    }
  }

  static Future<ResponseObject> updateLogin(
      {required String email, bool isLoggedIn = false}) async {
    try {
      final response = await DatabaseService.updateColumn(
          searchColumn: Constants.USER_EMAIL_COLUMN,
          searchValue: email,
          columnValue: isLoggedIn,
          columnName: Constants.USER_LOGGEDIN_COLUMN,
          tableName: _tableName);

      if (response.status == 200) {
        return ResponseObject(
            Status.success.name, UserModel.fromJson((response.data as List).first), Status.success);
      } else {
        _logger.d('existing user not found');
        return ResponseObject(
            Status.notfound.name, UserModel.fromJson(response.data), Status.notfound);
      }
    } catch (_) {
      _logger.e(_.toString());
      return ResponseObject(_.toString(), UserModel.init(), Status.error);
    }
  }

  static Future<ResponseObject> updateTokenOnLogin(
      {required String email, required String token}) async {
    try {
      final response = await DatabaseService.updateRow(
          colValue: email,
          data: {
            Constants.USER_TOKEN_COLUMN: token,
            Constants.USER_LOGGEDIN_COLUMN: true,
          },
          columnName: Constants.USER_EMAIL_COLUMN,
          tableName: _tableName);

      if (response.status == 200) {
        return ResponseObject(
            Status.success.name, UserModel.fromJson((response.data as List).first), Status.success);
      } else {
        _logger.d('existing user not found');
        return ResponseObject(
            Status.notfound.name, UserModel.fromJson(response.data), Status.notfound);
      }
    } catch (_) {
      _logger.e(_.toString());
      return ResponseObject(_.toString(), UserModel.init(), Status.error);
    }
  }
}
