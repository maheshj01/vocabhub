import 'package:supabase/supabase.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/constants/strings.dart';

class DatabaseService {
  static SupabaseClient _supabase =
      SupabaseClient("${Constants.SUPABASE_URL}", "${Constants.SUPABASE_API_KEY}");

  // fetches data from table1 based on eq condition `columnValue`
  // and inner joins on table2 (returns all rows) based on innerJoincolumn
  static Future<PostgrestResponse> innerJoinTwoTables(String columnValue,
      {String columnName = '${Constants.WORD_COLUMN}',
      String innerJoincolumn = '${Constants.USER_EMAIL_COLUMN}',
      String table1 = '${Constants.EDIT_HISTORY_TABLE}',
      String table2 = '${Constants.USER_TABLE_NAME}',
      bool sort = false}) async {
    final response = await _supabase
        .from(table1)
        .select('*, $table2:$innerJoincolumn, $table2(*)')
        .eq('$columnName', columnValue)
        .order('${Constants.CREATED_AT_COLUMN}', ascending: sort)
        .execute();
    return response;
  }

  static Future<PostgrestResponse> findRowByColumnValue(String columnValue,
      {String columnName = '${Constants.ID_COLUMN}',
      String tableName = '${Constants.VOCAB_TABLE_NAME}',
      bool sort = false}) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .eq('$columnName', columnValue)
        .order('${Constants.CREATED_AT_COLUMN}', ascending: sort)
        .execute();
    return response;
  }

  static Future<PostgrestResponse> findRowBy2ColumnValues(
    String column1Value,
    String column2Value, {
    String column1Name = '${Constants.ID_COLUMN}',
    String column2Name = '${Constants.USER_EMAIL_COLUMN}',
    String tableName = '${Constants.VOCAB_TABLE_NAME}',
    bool ascending = false,
  }) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .eq('$column1Name', column1Value)
        .eq('$column2Name', column2Value)
        .order(Constants.CREATED_AT_COLUMN, ascending: ascending)
        .execute();
    return response;
  }

  static Future<PostgrestResponse> findRowsContaining(String columnValue,
      {String columnName = '${Constants.ID_COLUMN}',
      String tableName = '${Constants.VOCAB_TABLE_NAME}'}) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .ilike('$columnName', "%$columnValue%")
        //TODO
        .execute();
    return response;
  }

  /// fetches all
  static Future<PostgrestResponse> findRowsByInnerJoinOnColumnValue(
      String innerJoinColumn, String value,
      {String table1 = '${Constants.EDIT_HISTORY_TABLE}',
      bool ascending = false,
      String table2 = '${Constants.USER_TABLE_NAME}'}) async {
    final response = await _supabase
        .from('$table1')
        .select('*, $table2!inner(*)')
        .order('created_at', ascending: ascending)
        // .eq('$table2.$innerJoinColumn', '$value')
        .execute();

    return response;
  }

  /// ```
  /// final response = await _supabase
  ///      .from('$table1')
  ///      .select('*, $table2!inner(*)')
  ///      .eq('$table2.$innerJoinColumn1', '$value1')
  ///      .eq('$table2.$innerJoinColumn2', '$value2')
  ///      .order('created_at', ascending: ascending)
  ///      .execute();
  ///  return response;
  /// ```
  static Future<PostgrestResponse> findRowsByInnerJoinOn2ColumnValue(
      String innerJoinColumn1, String value1, String innerJoinColumn2, String value2,
      {String table1 = '${Constants.EDIT_HISTORY_TABLE}',
      bool ascending = false,
      String table2 = '${Constants.USER_TABLE_NAME}'}) async {
    final response = await _supabase
        .from('$table1')
        .select('*, $table2!inner(*)')
        .eq('$table2.$innerJoinColumn1', '$value1')
        .eq('$table2.$innerJoinColumn2', '$value2')
        // .order('created_at', ascending: ascending)
        .execute();
    return response;
  }

  // static Future<PostgrestResponse> exploreWords(
  //     // String innerJoinColumn1,
  //     //       String value1, String innerJoinColumn2, String value2,
  //     //       {String table1 = '$EDIT_HISTORY_TABLE',
  //     //       String table2 = '$USER_TABLE_NAME'}

  //     ) async {
  //   final response = await _supabase
  //       .from('$VOCAB_TABLE_NAME')
  //       .select()
  //       .select('*, $WORD_STATE_TABLE_NAME!inner(*)')
  //       // .eq('$table2.$innerJoinColumn1', '$value1')
  //       // .eq('state', 'known')
  //       // .order('created_at', ascending: ascending)
  //       .execute();
  //   return response;
  // }

  static Future<PostgrestResponse> findAll(
      {String tableName = '${Constants.VOCAB_TABLE_NAME}', bool sort = false}) async {
    final resp =
        await _supabase.from(tableName).select().execute().timeout(Constants.timeoutDuration);
    return resp;
  }

  static Future<PostgrestResponse> findReports(
      {String tableName = '${Constants.VOCAB_TABLE_NAME}', bool sort = false}) async {
    final resp =
        await _supabase.from(tableName).select().order('created_at', ascending: false).execute();
    return resp;
  }

  /// fetch words sorted by created_at column
  static Future<PostgrestResponse> findLimitedWords(
      {String tableName = '${Constants.VOCAB_TABLE_NAME}', bool sort = false, int page = 0}) async {
    // final response =
    //     await _supabase.from(tableName).select().range(page * 20, (page + 1) * 20).execute();
    return await _supabase
        .from(tableName)
        .select()
        .order('${Constants.CREATED_AT_COLUMN}', ascending: sort)
        .execute()
        .timeout(Constants.timeoutDuration, onTimeout: () {
      throw NETWORK_ERROR;
    });
  }

  static Future<PostgrestResponse> findRecentlyUpdatedRow(String innerJoinColumn, String value,
      {String table1 = '${Constants.EDIT_HISTORY_TABLE}',
      bool ascending = false,
      String table2 = '${Constants.USER_TABLE_NAME}'}) async {
    final response = await _supabase
        .from('$table1')
        .select('*, $table2!inner(*)')
        .order('created_at', ascending: ascending)
        .execute()
        .timeout(Constants.timeoutDuration);
    return response;
  }

  static Future<PostgrestResponse> findSingleRowByColumnValue(String columnValue,
      {String columnName = '${Constants.ID_COLUMN}',
      String tableName = '${Constants.VOCAB_TABLE_NAME}'}) async {
    try {
      final response = await _supabase
          .from(tableName)
          .select()
          .eq('$columnName', columnValue)
          .single()
          .execute()
          .timeout(Constants.timeoutDuration, onTimeout: () async {
        throw NETWORK_ERROR;
      });
      return response;
    } catch (_) {
      rethrow;
    }
  }

  static Future<PostgrestResponse> insertIntoTable(Map<String, dynamic> data,
      {String table = '${Constants.VOCAB_TABLE_NAME}'}) async {
    final response = await _supabase
        .from(table)
        .insert(data)
        .execute()
        .timeout(Constants.timeoutDuration, onTimeout: () {
      throw NETWORK_ERROR;
    });
    return response;
  }

  /// Upsert will update the data if it exists, otherwise it will insert it.
  /// conflict column refers to the columns which should be unique across all the rows
  /// it is responsible to determine whether insert or update is called.
  static Future<PostgrestResponse> upsertIntoTable(Map<String, dynamic> data,
      {String table = '${Constants.VOCAB_TABLE_NAME}',
      String conflictColumn = '${Constants.ID_COLUMN}'}) async {
    final response = await _supabase
        .from(table)
        .upsert(data, onConflict: 'id')
        .execute()
        .timeout(Constants.timeoutDuration)
        .onError((error, stackTrace) {
      return PostgrestResponse();
    });
    return response;
  }

  /// updates a row in the table
  /// update `tableName` where `columnName` = `colValue`
  /// with `data`
  static Future<PostgrestResponse> updateRow(
      {required String colValue,
      required Map<String, dynamic> data,
      String columnName = '${Constants.ID_COLUMN}',
      String tableName = '${Constants.VOCAB_TABLE_NAME}'}) async {
    final response = await _supabase
        .from(tableName)
        .update(data)
        .eq("$columnName", "$colValue")
        .execute()
        .timeout(Constants.timeoutDuration);
    return response;
  }

  /// updates a value in a column
  /// update `ColumnName` to `columnValue` in `tableName where
  /// `searchColumn` = `searchValue`
  static Future<PostgrestResponse> updateColumn(
      {required String searchColumn,
      required String searchValue,
      required String columnName,
      required dynamic columnValue,
      required String tableName}) async {
    final response = await _supabase
        .from(tableName)
        .update({columnName: columnValue})
        .eq("$searchColumn", "$searchValue")
        .execute()
        .timeout(Constants.timeoutDuration);
    return response;
  }

  static Future<PostgrestResponse> upsertRow(Map<String, dynamic> data,
      {String tableName = '${Constants.VOCAB_TABLE_NAME}'}) async {
    final response =
        await _supabase.from(tableName).upsert(data).execute().timeout(Constants.timeoutDuration);
    return response;
  }

  static Future<PostgrestResponse> deleteRow(String columnValue,
      {String columnName = '${Constants.ID_COLUMN}',
      String tableName = '${Constants.VOCAB_TABLE_NAME}'}) async {
    final response = await _supabase
        .from(tableName)
        .delete()
        .eq('$columnName', columnValue)
        .execute()
        .timeout(Constants.timeoutDuration);
    ;
    return response;
  }
}
