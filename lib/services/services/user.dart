import 'package:supabase/supabase.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:vocabhub/utils/secrets.dart';
import '../services.dart';

class UserService {
  static String _tableName = '$USER_TABLE_NAME';
  final SupabaseClient _supabase = SupabaseClient("$CONFIG_URL", "$APIkey");

  Future<PostgrestResponse> findById(String id) async {
    final response = await DatabaseService.findSingleRowByColumnValue(id,
        columnName: ID_COLUMN, tableName: _tableName);
    return response;
  }

  Future<UserModel> findByEmail({required String email}) async {
    try {
      final response = await DatabaseService.findSingleRowByColumnValue(email,
          columnName: USER_EMAIL_COLUMN, tableName: _tableName);

      if (response.status == 200) {
        final user = UserModel.fromJson(response.data);
        return user;
      } else {
        logger.d('existing user not found');
        return UserModel.init();
      }
    } catch (_) {
      logger.e(_);
      return UserModel.init();
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
      logger.e(_);
    }
    return users;
  }

//: TODO: Add a new user to the database
//: and verify

  Future<Response> registerUser(UserModel user) async {
    final resp = Response(didSucced: false, message: "Failed");
    final json = user.toJson();
    try {
      final response =
          await DatabaseService.insertIntoTable(json, table: USER_TABLE_NAME);
      if (response.status == 201) {
        resp.didSucced = true;
        resp.message = 'Success';
        resp.data = response.data;
      } else {
        logger.e('error caught');
        throw "Failed to register new user";
      }
    } catch (_) {
      logger.e('error caught $_');
      throw "Failed to register new user";
    }
    return resp;
  }

  Future<PostgrestResponse> deleteById(String id) async {
    logger.i(_tableName);
    final response =
        await DatabaseService.deleteRow(ID_COLUMN, tableName: _tableName);
    return response;
  }

  Future<ResponseObject> updateLogin(
      {required String email, bool isLoggedIn = false}) async {
    try {
      final response = await DatabaseService.updateColumn(
          searchColumn: USER_EMAIL_COLUMN,
          searchValue: email,
          columnValue: isLoggedIn,
          columnName: USER_LOGGEDIN_COLUMN,
          tableName: _tableName);

      if (response.status == 200) {
        return ResponseObject(Status.success.name,
            UserModel.fromJson((response.data as List).first), Status.success);
      } else {
        logger.d('existing user not found');
        return ResponseObject(Status.notfound.name,
            UserModel.fromJson(response.data), Status.notfound);
      }
    } catch (_) {
      logger.e(_);
      return ResponseObject(_.toString(), UserModel.init(), Status.error);
    }
  }
}
