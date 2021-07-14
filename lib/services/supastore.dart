import 'package:supabase/supabase.dart';
import 'package:logger/logger.dart' as log;
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:postgrest/postgrest.dart';
import 'package:vocabhub/utils/secrets.dart';

class VocabResponse {
  bool didSucced;
  String message;
  int? status;
  Object? data;

  VocabResponse(
      {required this.didSucced, required this.message, this.status, this.data});
}

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

  Future<VocabResponse> addWord(Word word) async {
    final json = word.toJson();
    final vocabresponse = VocabResponse(didSucced: false, message: "Failed");
    try {
      print('inserting \n $json');
      final response = await insert(json);
      print('response  =${response.data}');
      if (response.status == 201) {
        vocabresponse.didSucced = true;
        vocabresponse.message = 'Success';
        final word = Word.fromJson(response.data[0]);
        vocabresponse.data = word;
      }
    } catch (_) {
      print(_);
    }
    return vocabresponse;
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
    json.remove('id');
    json.remove('antonyms');
    final response = await _supabase
        .from(tableName)
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
