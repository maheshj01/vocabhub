import 'dart:convert';

import 'package:supabase/supabase.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/platform/mobile.dart'
    if (dart.library.html) 'package:vocabhub/platform/web.dart' as platformOnly;
import 'package:vocabhub/services/services/database.dart';
import 'package:vocabhub/utils/logger.dart';
import 'package:vocabhub/utils/utility.dart';

/// Global Vocabulary table's api.
class VocabStoreService {
  static String tableName = '${Constants.VOCAB_TABLE_NAME}';
  static final _logger = Logger("VocabStoreService");
  static final SupabaseClient _supabase =
      SupabaseClient("${Constants.SUPABASE_URL}", "${Constants.SUPABASE_API_KEY}}");
  static Future<PostgrestResponse> findById(String id) async {
    final response = await DatabaseService.findSingleRowByColumnValue(id,
        columnName: Constants.ID_COLUMN, tableName: tableName);
    return response;
  }

  static Future<Word?> findByWord(String word) async {
    if (word.isEmpty) {
      return null;
    }
    final response = await DatabaseService.findSingleRowByColumnValue(word,
        columnName: Constants.WORD_COLUMN, tableName: tableName);
    Word? result;
    if (response.status == 200) {
      result = Word.fromJson(response.data);
      return result;
    }
    return null;
  }

  static Future<Response> addWord(Word word) async {
    final json = word.toJson();
    final vocabresponse = Response(didSucced: false, message: "Failed");
    try {
      final response = await DatabaseService.insertIntoTable(json, table: tableName);
      if (response.status == 201) {
        vocabresponse.didSucced = true;
        vocabresponse.message = 'Success';
        final word = Word.fromJson(response.data[0]);
        vocabresponse.data = word;
      }
      vocabresponse.status = response.status;
      vocabresponse.message = response.error!.message;
    } catch (_) {
      throw "Failed to add word,error:$_";
    }
    return vocabresponse;
  }

  /// ```Select * from words Where state = 'approved';```
  ///
  // Future<List<Word>> getAllApprovedWords({bool sort = true}) async {
  //   final response = await _supabase
  //       .from(tableName)
  //       .select("*")
  //       .eq('state', 'approved')
  //       .execute();
  //   List<Word> words = [];
  //   if (response.status == 200) {
  //     words = (response.data as List).map((e) => Word.fromJson(e)).toList();
  //     if (sort) {
  //       words.sort((a, b) => a.word.compareTo(b.word));
  //     }
  //   }
  //   return words;
  // }

  /// ```Select * from words```

  static Future<List<Word>> getAllWords({bool sort = false}) async {
    try {
      final response = await DatabaseService.findAll(tableName: tableName);
      List<Word> words = [];
      if (response.status == 200) {
        words = (response.data as List).map((e) => Word.fromJson(e)).toList();
        if (sort) {
          words.sort((a, b) => a.word.compareTo(b.word));
        }
        dashboardController.words = words;
      } else {
        return dashboardController.words;
      }
      return words;
    } catch (_) {
      _logger.e("Failed to get words,error:$_");
      rethrow;
    }
  }

  static Future<List<Word>> getBookmarks(String email, {bool isBookmark = true}) async {
    final response = await DatabaseService.findRowsByInnerJoinOn2ColumnValue(
      'email',
      email,
      'state',
      isBookmark ? 'unknown' : 'known',
      table1: '${Constants.VOCAB_TABLE_NAME}',
      table2: '${Constants.WORD_STATE_TABLE_NAME}',
    );
    List<Word> words = [];
    if (response.status == 200) {
      words = (response.data as List).map((e) => Word.fromJson(e)).toList();
    }
    return words;
  }

  static removeBookmark(String id, {bool isBookmark = true}) async {
    final response = await DatabaseService.updateColumn(
        searchColumn: 'word_id',
        searchValue: id,
        columnName: 'state',
        columnValue: isBookmark ? 'known' : 'unknown',
        tableName: '${Constants.WORD_STATE_TABLE_NAME}');
    return response;
  }

  // Gets previous word of the day from the database.
  static Future<Word> getLastUpdatedRecord() async {
    final response = await DatabaseService.findRecentlyUpdatedRow('created_at', '',
        table1: Constants.WORD_OF_THE_DAY_TABLE_NAME,
        table2: Constants.VOCAB_TABLE_NAME,
        ascending: false);
    if (response.status == 200) {
      Word lastWordOfTheDay = Word.fromJson(response.data[0]['${Constants.VOCAB_TABLE_NAME}']);
      lastWordOfTheDay.created_at = DateTime.parse(response.data[0]['created_at']);
      return lastWordOfTheDay;
    } else {
      throw "Failed to get last updated record ${response.error!.message} ${response.status}";
    }
  }

  static Future<Response> publishWod(Word word) async {
    final vocabresponse = Response(didSucced: false, message: "Failed", data: word);
    final now = DateTime.now().toUtc();
    final wordOfTheDay = {'word': word.word, 'id': word.id, 'created_at': now.toIso8601String()};
    final resp = await DatabaseService.insertIntoTable(
      wordOfTheDay,
      table: Constants.WORD_OF_THE_DAY_TABLE_NAME,
    );
    if (resp.status == 201) {
      return vocabresponse.copyWith(
          didSucced: true,
          message: 'Word of the day published successfully',
          status: resp.status,
          data: word.copyWith(created_at: now));
    } else {
      return vocabresponse.copyWith(
        didSucced: false,
        message: resp.error!.message,
        status: resp.status,
      );
    }
  }

  static Future<List<Word>> searchWord(String query, {bool sort = false}) async {
    final response = await DatabaseService.findRowsContaining(query,
        columnName: Constants.WORD_COLUMN, tableName: tableName);
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
      _logger.d(x.toString());
      throw 'x';
    }
  }

  static Future<PostgrestResponse> updateWord({
    required String id,
    required Word word,
  }) async {
    final Map<String, dynamic> json = word.toJson();
    final response = await DatabaseService.updateRow(
        colValue: id, data: json, columnName: Constants.ID_COLUMN, tableName: tableName);
    return response;
  }

  Future<PostgrestResponse> updateMeaning({
    required String id,
    required Word word,
  }) async {
    final response = await DatabaseService.updateColumn(
        searchColumn: Constants.ID_COLUMN,
        searchValue: id,
        columnValue: word.meaning,
        columnName: Constants.MEANING_COLUMN,
        tableName: tableName);
    return response;
  }

  static Future<PostgrestResponse> deleteById(String id) async {
    _logger.i(tableName);
    final response =
        await DatabaseService.deleteRow(id, tableName: tableName, columnName: Constants.ID_COLUMN);
    if (response.error != null) {
      _logger.e("${response.error!.message}$id");
    }
    return response;
  }
}
