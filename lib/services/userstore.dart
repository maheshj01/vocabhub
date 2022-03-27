import 'package:supabase/supabase.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/utils/secrets.dart';
import 'services.dart';

class UserStore {
  static String _tableName = '$USER_TABLE_NAME';
  final SupabaseClient _supabase = SupabaseClient("$CONFIG_URL", "$APIkey");
  Future<PostgrestResponse> findById(String id) async {
    final response = await _supabase
        .from(_tableName)
        .select()
        .eq('$ID_COLUMN', id)
        .single()
        .execute();
    return response;
  }

  Future<UserModel?> findByEmail({required String email}) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select("*")
          .eq('$USER_EMAIL_COLUMN', email)
          .execute();
      if (response.status == 200) {
        final user = UserModel.fromJson((response.data as List).first);
        if (user.email == 'maheshmn121@gmail.com') user.isAdmin = true;
        return user;
      } else {
        logger.d('existing user not found');
        return null;
      }
    } catch (_) {
      logger.e(_);
      return null;
    }
  }

  /// ```Select * from words;```
  Future<List<User>> findAllUsers() async {
    List<User> users = [];
    try {
      final response = await _supabase.from(_tableName).select("*").execute();
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
      final response = await SupaStore().insert(json, table: USER_TABLE_NAME);
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

  Future<PostgrestResponse> updateWord({
    required String id,
    required Word word,
  }) async {
    final Map<String, dynamic> json = word.toJson();
    final response = await _supabase
        .from(_tableName)
        .update(json)
        .eq("$ID_COLUMN", "$id")
        .execute();
    logger.i(response.toJson());
    return response;
  }

  Future<PostgrestResponse> updateMeaning({
    required String id,
    required Word word,
  }) async {
    final response = await _supabase
        .from(_tableName)
        .update({"$MEANING_COLUMN": word.meaning})
        .eq("$ID_COLUMN", "$id")
        .execute();
    logger.i(response.toJson());
    return response;
  }

  Future<PostgrestResponse> deleteById(String id) async {
    logger.i(_tableName);
    final response = await _supabase
        .from(_tableName)
        .delete()
        .eq('$ID_COLUMN', id)
        .execute();
    logger.i(response.toJson());
    return response;
  }
}
