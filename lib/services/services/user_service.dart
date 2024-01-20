import 'package:supabase/supabase.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:vocabhub/utils/logger.dart';

class UserService {
  String _tableName = '${Constants.USER_TABLE_NAME}';
  final _logger = Logger("UserService");
  final SupabaseClient supabase;

  UserService(this.supabase);

  Future<PostgrestResponse> findUserById(String id) async {
    final response = await DatabaseService.findSingleRowByColumnValue(id,
        columnName: Constants.ID_COLUMN, tableName: _tableName);
    return response;
  }

  /// if cache is true, the user will be cached in the app state and local storage
  Future<UserModel> findUserByEmail({required String email}) async {
    try {
      final response = await DatabaseService.findSingleRowByColumnValue(email,
          columnName: Constants.USER_EMAIL_COLUMN, tableName: _tableName);
      if (response.status == 200) {
        final user = UserModel.fromMap(response.data);
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

  Future<bool> isUsernameValid(
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

  Future<bool> updateUser(UserModel user) async {
    try {
      final data = user.toMap();
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

  Future<bool> deleteUser(UserModel user) async {
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
  Future<List<User>> findAllUsers() async {
    List<User> users = [];
    try {
      final response = await DatabaseService.findAll(tableName: _tableName);
      if (response.status == 200) {
        users = (response.data as List).map((e) => User.fromJson(e)).toList();
      }
    } catch (_) {
      _logger.e(_.toString());
    }
    return users;
  }

//: TODO: Add a new user to the database
//: and verify

  Future<PostgrestResponse> deleteById(String email) async {
    _logger.i(_tableName);
    final response = await DatabaseService.deleteRow(email,
        columnName: Constants.USER_EMAIL_COLUMN, tableName: _tableName);
    return response;
  }
}
