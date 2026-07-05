import 'package:supabase/supabase.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:vocabhub/utils/logger.dart';

class UserService {
  static String _tableName = '${Constants.USER_TABLE_NAME}';
  static final _logger = Logger("UserService");

  Future<DbResponse> findById(String id) async {
    final response = await DatabaseService.findSingleRowByColumnValue(id,
        columnName: Constants.ID_COLUMN, tableName: _tableName);
    return response;
  }

  /// Look up a profile by its Firebase Auth uid (the canonical identity key).
  /// Returns [UserModel.init] when no matching row exists.
  static Future<UserModel> findByUid({required String uid, bool cache = false}) async {
    try {
      final response = await DatabaseService.findSingleRowByColumnValue(uid,
          columnName: Constants.USER_UID_COLUMN, tableName: _tableName);
      if (response.status == 200) {
        final user = UserModel.fromJson(response.data);
        if (cache) await authController.setUser(user);
        return user;
      }
      return UserModel.init();
    } catch (e) {
      _logger.e(e.toString());
      rethrow;
    }
  }

  /// Inserts or updates the profile row keyed on [UserModel.uid]. Empty emails
  /// (phone-only users) are stored as NULL so the email uniqueness index holds.
  /// Returns the persisted profile.
  static Future<UserModel> upsertProfile(UserModel user) async {
    final Map<String, dynamic> data = user.toJson();
    if ((data[Constants.USER_EMAIL_COLUMN] as String?)?.isEmpty ?? true) {
      data[Constants.USER_EMAIL_COLUMN] = null;
    }
    final response = await DatabaseService.upsertIntoTable(
      data,
      table: _tableName,
      conflictColumn: Constants.USER_UID_COLUMN,
    );
    if (response.status == 201 && response.data is List && (response.data as List).isNotEmpty) {
      return UserModel.fromJson((response.data as List).first);
    }
    if (response.error != null) {
      _logger.e('Failed to upsert profile: ${response.error!.message}');
      throw response.error!.message;
    }
    return user;
  }

  /// Flips login state (and optionally the FCM token) for a profile by uid.
  static Future<DbResponse> setLoginState({
    required String uid,
    required bool isLoggedIn,
    String? token,
  }) async {
    final Map<String, dynamic> data = {
      Constants.USER_LOGGEDIN_COLUMN: isLoggedIn,
      Constants.UPDATED_AT_COLUMN: DateTime.now().toIso8601String(),
    };
    if (token != null) data[Constants.USER_TOKEN_COLUMN] = token;
    return DatabaseService.updateByColumn(
      searchColumn: Constants.USER_UID_COLUMN,
      searchValue: uid,
      data: data,
      tableName: _tableName,
    );
  }

  /// if cache is true, the user will be cached in the app state and local storage
  static Future<UserModel> findByEmail({required String email, bool cache = false}) async {
    try {
      final response = await DatabaseService.findSingleRowByColumnValue(email,
          columnName: Constants.USER_EMAIL_COLUMN, tableName: _tableName);
      if (response.status == 200) {
        final user = UserModel.fromJson(response.data);
        if (cache) {
          await authController.setUser(user);
        }
        return user;
      } else {
        _logger.d('existing user not found');
        return UserModel.init();
      }
    } catch (_) {
      _logger.e(_.toString());
      rethrow;
    }
  }

  static Future<bool> isUsernameValid(
    String userName,
  ) async {
    try {
      final response = await DatabaseService.findSingleRowByColumnValue(userName,
          columnName: Constants.USERNAME_COLUMN, tableName: _tableName);
      if (response.status == 200) {
        final user = UserModel.fromJson(response.data);
        return !(user.email.isNotEmpty && user.username.isNotEmpty);
      }
      if (response.status == 406) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateUser(UserModel user) async {
    try {
      final data = user.toJson();
      final response = await DatabaseService.updateRow(
          colValue: user.email,
          data: data,
          columnName: Constants.USER_EMAIL_COLUMN,
          tableName: _tableName);
      if (response.status == 200) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  static Future<bool> deleteUser(UserModel user) async {
    try {
      final response = await DatabaseService.updateByColumn(
          searchValue: user.email,
          data: {
            Constants.DELETED_COLUMN: true,
            Constants.USER_LOGGEDIN_COLUMN: false,
            Constants.UPDATED_AT_COLUMN: DateTime.now().toIso8601String()
          },
          searchColumn: Constants.USER_EMAIL_COLUMN,
          tableName: _tableName);
      if (response.status == 200) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  /// ```Select * from words;```
  static Future<List<User>> findAllUsers() async {
    List<User> users = [];
    try {
      final response = await DatabaseService.findAll(tableName: _tableName);
      if (response.status == 200) {
        users = (response.data as List).map((e) => User.fromJson(e)).whereType<User>().toList();
      }
    } catch (_) {
      _logger.e(_.toString());
    }
    return users;
  }

//: TODO: Add a new user to the database
//: and verify

  static Future<DbResponse> deleteById(String email) async {
    _logger.i(_tableName);
    final response = await DatabaseService.deleteRow(email,
        columnName: Constants.USER_EMAIL_COLUMN, tableName: _tableName);
    return response;
  }
}
