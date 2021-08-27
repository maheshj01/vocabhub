import 'package:supabase/supabase.dart';
import 'package:logger/logger.dart' as log;
import 'package:vocabhub/constants/const.dart';
import 'package:postgrest/postgrest.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/utils/secrets.dart';

class Response {
  bool didSucced;
  String message;
  int? status;
  Object? data;

  Response(
      {required this.didSucced, required this.message, this.status, this.data});
}

// TODO: this class should be a private class around which other
// TODO: wrappers must be defined
class SupaStore {
  static String tableName = '$VOCAB_TABLE_NAME';
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

  Future<Response> addWord(Word word) async {
    final json = word.toJson();
    final vocabresponse = Response(didSucced: false, message: "Failed");
    try {
      final response = await insert(json);
      if (response.status == 201) {
        vocabresponse.didSucced = true;
        vocabresponse.message = 'Success';
        final word = Word.fromJson(response.data[0]);
        vocabresponse.data = word;
      }
    } catch (_) {
      print('error caught $_');
      throw "Failed to add word";
    }
    return vocabresponse;
  }

  /// ```Select * from words;```
  Future<List<Word>> findAll() async {
    final response = await _supabase.from(tableName).select("*").execute();
    List<Word> words = [];
    if (response.status == 200) {
      words = (response.data as List).map((e) => Word.fromJson(e)).toList();
      words.sort((a, b) => a.word.compareTo(b.word));
    }
    return words;
  }

  Future<PostgrestResponse> insert(Map<String, dynamic> json,
      {String table = '$VOCAB_TABLE_NAME'}) async {
    json.remove('id');

    /// TODO: remove antonyms
    json.remove('antonyms');
    json.remove('isLoggedIn');
    final response = await _supabase
        .from(table)
        .insert(
          json,
        )
        .execute();
    return response;
  }

  Future<PostgrestResponse> updateWord({
    required String id,
    required Word word,
  }) async {
    final Map<String, dynamic> json = word.toJson();
    final response = await _supabase
        .from(tableName)
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
