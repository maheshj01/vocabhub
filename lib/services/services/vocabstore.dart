import 'dart:convert';

import 'package:supabase/supabase.dart';
import 'package:logger/logger.dart' as log;
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:vocabhub/utils/secrets.dart';
import 'package:vocabhub/platform/mobile.dart'
    if (dart.library.html) 'package:vocabhub/platform/web.dart' as platformOnly;

class Response {
  bool didSucced;
  String message;
  int? status;
  Object? data;

  Response(
      {required this.didSucced, required this.message, this.status, this.data});
}

/// Global Vocabulary table's api.
class VocabStoreService {
  static String tableName = '$VOCAB_TABLE_NAME';
  final _logger = log.Logger();
  final SupabaseClient _supabase = SupabaseClient("$CONFIG_URL", "$APIkey");

  Future<PostgrestResponse> findById(String id) async {
    final response = await DatabaseService.findSingleRowByColumnValue(id,
        columnName: ID_COLUMN, tableName: tableName);
    return response;
  }

  /// TODO: Can be used to implement server side search.

  // Future<List<Word>> findByWord(String word) async {
  //   if (word.isEmpty) {
  //     return await getAllWords();
  //   }
  //   final response = await _supabase
  //       .from(tableName)
  //       .select("*")
  //       .contains('$WORD_COLUMN', word)
  //       .execute();
  //   List<Word> words = [];
  //   if (response.status == 200) {
  //     words = (response.data as List).map((e) => Word.fromJson(e)).toList();
  //   }
  //   return words;
  // }

  Future<Response> addWord(Word word) async {
    final json = word.toJson();
    final vocabresponse = Response(didSucced: false, message: "Failed");
    try {
      final response =
          await DatabaseService.insertIntoTable(json, table: tableName);
      if (response.status == 201) {
        vocabresponse.didSucced = true;
        vocabresponse.message = 'Success';
        final word = Word.fromJson(response.data[0]);
        vocabresponse.data = word;
      }
    } catch (_) {
      throw "Failed to add word";
    }
    return vocabresponse;
  }

  /// ```Select * from words Where state = 'approved';```
  ///
  Future<List<Word>> getAllApprovedWords({bool sort = true}) async {
    final response = await _supabase
        .from(tableName)
        .select("*")
        .eq('state', 'approved')
        .execute();
    List<Word> words = [];
    if (response.status == 200) {
      words = (response.data as List).map((e) => Word.fromJson(e)).toList();
      if (sort) {
        words.sort((a, b) => a.word.compareTo(b.word));
      }
    }
    return words;
  }

  /// ```Select * from words```

  Future<List<Word>> getAllWords({bool sort = false}) async {
    final response = await DatabaseService.findAll(tableName: tableName);
    List<Word> words = [];
    if (response.status == 200) {
      words = (response.data as List).map((e) => Word.fromJson(e)).toList();
      if (sort) {
        words.sort((a, b) => a.word.compareTo(b.word));
      }
    }
    return words;
  }

  Future<bool> downloadFile() async {
    try {
      final response = await _supabase.from(tableName).select("*").execute();
      if (response.status == 200) {
        platformOnly.fileSaver(json.encode(response.data), 'file.json');
        return true;
      }
      return false;
    } catch (x) {
      logger.d(x);
      throw 'x';
    }
  }

  Future<PostgrestResponse> updateWord({
    required String id,
    required Word word,
  }) async {
    final Map<String, dynamic> json = word.toJson();
    final response = await DatabaseService.updateRow(
        columnValue: id,
        data: json,
        columnName: ID_COLUMN,
        tableName: tableName);
    return response;
  }

  Future<PostgrestResponse> updateMeaning({
    required String id,
    required Word word,
  }) async {
    final response = await DatabaseService.updateColumn(
        searchColumn: ID_COLUMN,
        searchValue: id,
        columnValue: word.meaning,
        columnName: MEANING_COLUMN,
        tableName: tableName);
    return response;
  }

  Future<PostgrestResponse> deleteById(String id) async {
    _logger.i(tableName);
    final response = await DatabaseService.deleteRow(id,
        tableName: tableName, columnName: ID_COLUMN);
    return response;
  }
}
