import 'package:supabase/supabase.dart';
import 'package:logger/logger.dart' as log;
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:postgrest/postgrest.dart';
import 'package:vocabhub/utils/secrets.dart';

class SupaStore {
  static String tableName = '$TABLE_NAME';
  final _logger = log.Logger();
  final SupabaseClient _supabase = SupabaseClient("$CONFIG_URL", "$APIkey");

  Future<PostgrestResponse> findById(String id) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .eq('$ID_COLUMN', id)
        .single()
        .execute();
    return response;
  }

  Future<List<Word>> findByWord(String word) async {
    if (word.isEmpty) {
      return findAll();
    }
    final response = await _supabase
        .from(tableName)
        .select("*")
        .contains('$WORD_COLUMN', word)
        .execute();
    List<Word> words = [];
    if (response.status == 200) {
      words = (response.data as List).map((e) => Word.fromJson(e)).toList();
    }
    return words;
  }

  /// ```Select * from words;```
  Future<List<Word>> findAll() async {
    final response = await _supabase.from(tableName).select("*").execute();
    List<Word> words = [];
    if (response.status == 200) {
      words = (response.data as List).map((e) => Word.fromJson(e)).toList();
    }
    return words;
  }

  Future<PostgrestResponse> insert(Map<String, dynamic> json) async {
    final response = await _supabase.from(tableName).insert(json).execute();
    return response;
  }

  Future<PostgrestResponse> updateMeaning({
    required String id,
    required Word word,
  }) async {
    final response = await _supabase
        .from(tableName)
        .update({"$MEANING_COLUMN": word.meaning})
        .eq("$ID_COLUMN", "$id")
        .execute();
    _logger.i(response.toJson());
    return response;
  }

  Future<PostgrestResponse> deleteById(String id) async {
    _logger.i(tableName);
    final response =
        await _supabase.from(tableName).delete().eq('$ID_COLUMN', id).execute();
    _logger.i(response.toJson());
    return response;
  }
}
