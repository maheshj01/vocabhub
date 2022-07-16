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

  static Future<UserModel> findByEmail({required String email}) async {
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
  static Future<List<User>> findAllUsers() async {
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

  static Future<PostgrestResponse> deleteById(String email) async {
    logger.i(_tableName);
    final response = await DatabaseService.deleteRow(email,
        columnName: USER_EMAIL_COLUMN, tableName: _tableName);
    return response;
  }
}
