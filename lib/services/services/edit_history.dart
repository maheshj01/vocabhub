import 'dart:async';

import 'package:supabase/supabase.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/history.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:logger/logger.dart' as log;

/// Api to access the edit history and also to update the VocabTable
/// These edits are only made when the edits are approved by the admin.
class EditHistoryService {
  static String _tableName = '$EDIT_HISTORY_TABLE';
  final _logger = log.Logger();

  /// id could be userId or wordId
  /// This edits need to be shown under notifications for the user
  /// for admin the notifications will be of state (pending,add,delete)
  /// for user the notifications will be of state (pending)
  static Future<PostgrestResponse> findEditById(String id,
      {String columnName = ID_COLUMN}) async {
    final response =
        await DatabaseService.findRowByColumnValue(id, columnName: columnName);
    return response;
  }

  /// approve/reject an edit by updating the state to [EditState]
  ///
  static Future<PostgrestResponse> updateRowState(
      String id, EditState state) async {
    final response = await DatabaseService.updateRow(
        columnValue: id,
        data: {'state': '${state.name}'},
        columnName: '$ID_COLUMN',
        tableName: _tableName);
    return response;
  }

  /// Add a history entry for the word
  /// This is called when the user requests a edit to the VocabTable
  /// The edit state is pending (default) on insert
  static Future<Response> insertHistory(
      EditHistory history, String email) async {
    final vocabresponse = Response(didSucced: false, message: "Failed");
    final data = history.toJson();
    // data.addAll({
    //   'user_email': email,
    //   'state': 'pending',
    // });
    print(data);
    // final response =
    //     await DatabaseService.insertIntoTable(data, table: _tableName);
    // vocabresponse.status = response.status;
    // if (response.status == 201) {
    //   vocabresponse.didSucced = true;
    //   vocabresponse.message = 'Success';
    //   final word = Word.fromJson(response.data[0]);
    //   vocabresponse.data = word;
    // } else {
    //   vocabresponse.message = response.error!.message;
    // }
    return vocabresponse;
  }
}
