import 'package:supabase/supabase.dart';
import 'package:logger/logger.dart' as log;
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/utils/secrets.dart';
import 'package:postgrest/postgrest.dart';

import 'services.dart';

class UserStore {
  static String _tableName = '$USER_TABLE_NAME';
  final _logger = log.Logger();
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

  Future<User?> findByEmail({required String email}) async {
    try {
      final response = await _supabase
          .from(_tableName)
          .select("*")
          .contains('$USER_EMAIL_COLUMN', email)
          .execute();
      if (response.status == 200) {
        final user = User.fromJson(response.data);
        return user;
      } else {
        return null;
      }
    } catch (_) {
      _logger.e(_);
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
      print(_);
    }
    return users;
  }

//: TODO: Add a new user to the database
//: and verify

//     Future<VocabResponse> addUser(User user) async {
//     final json = user.toJson();
//     final vocabresponse = VocabResponse(didSucced: false, message: "Failed");
//     try {
//       final response = await insert(json);
//       if (response.status == 201) {
//         vocabresponse.didSucced = true;
//         vocabresponse.message = 'Success';
//         final word = Word.fromJson(response.data[0]);
//         vocabresponse.data = word;
//       }
//     } catch (_) {
//       print('error caught $_');
//       throw "Failed to add word";
//     }
//     return vocabresponse;
//   }

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
    _logger.i(response.toJson());
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
    _logger.i(response.toJson());
    return response;
  }

  Future<PostgrestResponse> deleteById(String id) async {
    _logger.i(_tableName);
    final response = await _supabase
        .from(_tableName)
        .delete()
        .eq('$ID_COLUMN', id)
        .execute();
    _logger.i(response.toJson());
    return response;
  }
}
