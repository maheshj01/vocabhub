import 'dart:async';

import 'package:supabase/supabase.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:logger/logger.dart' as log;

/// Api to access the edit history and also to update the VocabTable
/// These edits are only made when the edits are approved by the admin.
class WordStateService {
  static String _tableName = '$WORD_STATE_TABLE_NAME';
  final _logger = log.Logger();

  /// id could be userId or wordId
  /// This edits need to be shown under notifications for the user
  /// for admin the notifications will be of state (pending,add,delete)
  /// for user the notifications will be of state (pending)
  static Future<PostgrestResponse> findMasteredWords(String id,
      {String columnName = USER_EMAIL_COLUMN}) async {
    final response = await DatabaseService.findRowByColumnValue(id,
        columnName: columnName, tableName: _tableName);
    return response;
  }

  /// approve/reject an edit by updating the state to [EditState]
  ///
  static Future<PostgrestResponse> updateWordPreference(
      String id, WordState state) async {
    final response = await DatabaseService.updateRow(
        colValue: id,
        data: {'state': '${state.name}'},
        columnName: 'word_id',
        tableName: _tableName);
    return response;
  }

  static Future<Response> storeWordPreference(
      String wordId, String email, WordState state) async {
    final vocabresponse = Response(didSucced: false, message: "Failed");
    final Map<String, dynamic> data = {};
    data['word_id'] = wordId;
    // data['id'] = '232234';
    data['email'] = email;
    data['created_at'] = DateTime.now().toIso8601String();
    data['state'] = state.name;
    final response = await DatabaseService.upsertIntoTable(data,
        table: _tableName, conflictColumn: 'word_id');
    vocabresponse.status = response.status;
    if (response.status == 201) {
      vocabresponse.didSucced = true;
      vocabresponse.message = 'Success';
      vocabresponse.data = response.data;
    } else {
      vocabresponse.message = response.error!.message;
    }
    return vocabresponse;
  }
}
