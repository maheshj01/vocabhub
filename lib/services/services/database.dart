import 'dart:async';

import 'package:supabase/supabase.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/constants/strings.dart';

class DbError {
  final String message;
  final String? code;
  final Object? details;
  final String? hint;

  const DbError({
    required this.message,
    this.code,
    this.details,
    this.hint,
  });

  factory DbError.fromPostgrestException(PostgrestException error) {
    return DbError(
      message: error.message,
      code: error.code,
      details: error.details,
      hint: error.hint,
    );
  }
}

class DbResponse<T> {
  final int status;
  final T? data;
  final DbError? error;
  final int? count;

  const DbResponse({
    required this.status,
    this.data,
    this.error,
    this.count,
  });
}

class DatabaseService {
  static final SupabaseClient _supabase =
      SupabaseClient(Constants.SUPABASE_URL, Constants.SUPABASE_API_KEY);

  static int _httpStatusFromPostgrestException(PostgrestException error) {
    final parsed = int.tryParse(error.code ?? '');
    if (parsed != null && parsed >= 100 && parsed <= 599) {
      return parsed;
    }
    if (error.code == 'PGRST116') {
      return 406;
    }
    return 500;
  }

  static DbResponse<T> _errorResponse<T>(
    Object error, {
    int status = 500,
  }) {
    if (error is PostgrestException) {
      return DbResponse<T>(
        status: _httpStatusFromPostgrestException(error),
        error: DbError.fromPostgrestException(error),
      );
    }
    return DbResponse<T>(
      status: status,
      error: DbError(message: error.toString()),
    );
  }

  static Future<DbResponse<T>> _run<T>(
    Future<T> Function() callback, {
    int successStatus = 200,
  }) async {
    try {
      final data = await callback();
      return DbResponse<T>(
        status: successStatus,
        data: data,
      );
    } catch (error) {
      return _errorResponse<T>(error);
    }
  }

  // fetches data from table1 based on eq condition `columnValue`
  // and inner joins on table2 (returns all rows) based on innerJoincolumn
  static Future<DbResponse> innerJoinTwoTables(
    String columnValue, {
    String columnName = '${Constants.WORD_COLUMN}',
    String innerJoincolumn = '${Constants.USER_EMAIL_COLUMN}',
    String table1 = '${Constants.EDIT_HISTORY_TABLE}',
    String table2 = '${Constants.USER_TABLE_NAME}',
    bool sort = false,
  }) async {
    return _run(() async {
      return await _supabase
          .from(table1)
          .select('*, $table2:$innerJoincolumn, $table2(*)')
          .eq(columnName, columnValue)
          .order(Constants.CREATED_AT_COLUMN, ascending: sort);
    });
  }

  // fetches data from table1 based on eq condition `columnValue`
  // and inner joins on table2 (returns all rows) based on innerJoincolumn
  static Future<DbResponse> findApprovedEdits(
    String columnValue, {
    String columnName = '${Constants.WORD_COLUMN}',
    String innerJoincolumn = '${Constants.USER_EMAIL_COLUMN}',
    String table1 = '${Constants.EDIT_HISTORY_TABLE}',
    String table2 = '${Constants.USER_TABLE_NAME}',
    bool sort = false,
  }) async {
    return _run(() async {
      return await _supabase
          .from(table1)
          .select('*, $table2:$innerJoincolumn, $table2(*)')
          .eq(columnName, columnValue)
          .eq('state', 'approved')
          .order(Constants.CREATED_AT_COLUMN, ascending: sort);
    });
  }

  static Future<DbResponse> findRowByColumnValue(
    String columnValue, {
    String columnName = '${Constants.ID_COLUMN}',
    String tableName = '${Constants.VOCAB_TABLE_NAME}',
    bool sort = false,
  }) async {
    return _run(() async {
      return await _supabase
          .from(tableName)
          .select()
          .eq(columnName, columnValue)
          .order(Constants.CREATED_AT_COLUMN, ascending: sort);
    });
  }

  static Future<DbResponse> findRowBy2ColumnValues(
    String column1Value,
    String column2Value, {
    String column1Name = '${Constants.ID_COLUMN}',
    String column2Name = '${Constants.USER_EMAIL_COLUMN}',
    String tableName = '${Constants.VOCAB_TABLE_NAME}',
    bool ascending = false,
  }) async {
    return _run(() async {
      return await _supabase
          .from(tableName)
          .select()
          .eq(column1Name, column1Value)
          .eq(column2Name, column2Value)
          .order(Constants.CREATED_AT_COLUMN, ascending: ascending);
    });
  }

  static Future<DbResponse> findRowsContaining(
    String columnValue, {
    String columnName = '${Constants.ID_COLUMN}',
    String tableName = '${Constants.VOCAB_TABLE_NAME}',
  }) async {
    return _run(() async {
      return await _supabase
          .from(tableName)
          .select()
          // .ilike(columnName, "%$columnValue%")
          .or('word.ilike.%$columnValue%,meaning.ilike.%$columnValue%');
    });
  }

  /// fetches all
  static Future<DbResponse> findRowsByInnerJoinOnColumnValue(
    String innerJoinColumn,
    String value, {
    String table1 = '${Constants.EDIT_HISTORY_TABLE}',
    bool ascending = false,
    String table2 = '${Constants.USER_TABLE_NAME}',
  }) async {
    return _run(() async {
      return await _supabase
          .from(table1)
          .select('*, $table2!inner(*)')
          .order('created_at', ascending: ascending);
      // .eq('$table2.$innerJoinColumn', value)
    });
  }

  /// ```
  /// final response = await _supabase
  ///      .from(table1)
  ///      .select('*, $table2!inner(*)')
  ///      .eq('$table2.$innerJoinColumn1', value1)
  ///      .eq('$table2.$innerJoinColumn2', value2)
  ///      .order('created_at', ascending: ascending);
  ///  return response;
  /// ```
  static Future<DbResponse> findRowsByInnerJoinOn2ColumnValue(
    String innerJoinColumn1,
    String value1,
    String innerJoinColumn2,
    String value2, {
    String table1 = '${Constants.EDIT_HISTORY_TABLE}',
    bool ascending = false,
    String table2 = '${Constants.USER_TABLE_NAME}',
  }) async {
    return _run(() async {
      return await _supabase
          .from(table1)
          .select('*, $table2!inner(*)')
          .eq('$table2.$innerJoinColumn1', value1)
          .eq('$table2.$innerJoinColumn2', value2);
      // .order('created_at', ascending: ascending)
    });
  }

  static Future<DbResponse> findAll({
    String tableName = '${Constants.VOCAB_TABLE_NAME}',
    bool sort = false,
  }) async {
    return _run(() async {
      return await _supabase
          .from(tableName)
          .select()
          .timeout(Constants.timeoutDuration);
    });
  }

  static Future<DbResponse> findReports({
    String tableName = '${Constants.VOCAB_TABLE_NAME}',
    bool sort = false,
  }) async {
    return _run(() async {
      return await _supabase
          .from(tableName)
          .select()
          .order('created_at', ascending: false);
    });
  }

  /// fetch words sorted by created_at column
  static Future<DbResponse> findLimitedWords({
    String tableName = '${Constants.VOCAB_TABLE_NAME}',
    bool sort = false,
    int page = 0,
  }) async {
    try {
      final data = await _supabase
          .from(tableName)
          .select()
          .order(Constants.CREATED_AT_COLUMN, ascending: sort)
          .timeout(Constants.timeoutDuration, onTimeout: () {
        throw TimeoutException(NETWORK_ERROR);
      });
      return DbResponse(status: 200, data: data);
    } on TimeoutException {
      return const DbResponse(
        status: 500,
        error: DbError(message: NETWORK_ERROR),
      );
    } catch (error) {
      return _errorResponse(error);
    }
  }

  static Future<DbResponse> findRecentlyUpdatedRow(
    String innerJoinColumn,
    String value, {
    String table1 = '${Constants.EDIT_HISTORY_TABLE}',
    bool ascending = false,
    String table2 = '${Constants.USER_TABLE_NAME}',
  }) async {
    return _run(() async {
      return await _supabase
          .from(table1)
          .select('*, $table2!inner(*)')
          .order('created_at', ascending: ascending)
          .timeout(Constants.timeoutDuration);
    });
  }

  static Future<DbResponse> findSingleRowByColumnValue(
    String columnValue, {
    String columnName = '${Constants.ID_COLUMN}',
    String tableName = '${Constants.VOCAB_TABLE_NAME}',
  }) async {
    try {
      final data = await _supabase
          .from(tableName)
          .select()
          .eq(columnName, columnValue)
          .maybeSingle()
          .timeout(Constants.timeoutDuration, onTimeout: () {
        throw TimeoutException(NETWORK_ERROR);
      });
      if (data == null) {
        return const DbResponse(
          status: 406,
          error: DbError(message: 'No rows found'),
        );
      }
      return DbResponse(status: 200, data: data);
    } on TimeoutException {
      return const DbResponse(
        status: 500,
        error: DbError(message: NETWORK_ERROR),
      );
    } catch (error) {
      return _errorResponse(error);
    }
  }

  static Future<DbResponse> insertIntoTable(
    Map<String, dynamic> data, {
    String table = '${Constants.VOCAB_TABLE_NAME}',
  }) async {
    return _run(() async {
      return await _supabase
          .from(table)
          .insert(data)
          .select()
          .timeout(Constants.timeoutDuration, onTimeout: () {
        throw TimeoutException(NETWORK_ERROR);
      });
    }, successStatus: 201);
  }

  /// Upsert will update the data if it exists, otherwise it will insert it.
  /// conflict column refers to the columns which should be unique across all the rows
  /// it is responsible to determine whether insert or update is called.
  static Future<DbResponse> upsertIntoTable(
    Map<String, dynamic> data, {
    String table = '${Constants.VOCAB_TABLE_NAME}',
    String conflictColumn = '${Constants.ID_COLUMN}',
  }) async {
    return _run(() async {
      return await _supabase
          .from(table)
          .upsert(data, onConflict: conflictColumn)
          .select()
          .timeout(Constants.timeoutDuration);
    }, successStatus: 201);
  }

  /// updates a row in the table
  /// update `tableName` where `columnName` = `colValue`
  /// with `data`
  static Future<DbResponse> updateRow<T extends Object>({
    required T colValue,
    required Map<String, dynamic> data,
    String columnName = '${Constants.ID_COLUMN}',
    String tableName = '${Constants.VOCAB_TABLE_NAME}',
  }) async {
    return _run(() async {
      return await _supabase
          .from(tableName)
          .update(data)
          .eq(columnName, colValue)
          .select()
          .timeout(Constants.timeoutDuration);
    });
  }

  /// updates a value in a column
  /// update `ColumnName` to `columnValue` in `tableName where
  /// `searchColumn` = `searchValue`
  static Future<DbResponse> updateByColumn({
    required String searchColumn,
    required String searchValue,
    required Map<String, dynamic> data,
    required String tableName,
  }) async {
    return _run(() async {
      return await _supabase
          .from(tableName)
          .update(data)
          .eq(searchColumn, searchValue)
          .select()
          .timeout(Constants.timeoutDuration);
    });
  }

  static Future<DbResponse> upsertRow(
    Map<String, dynamic> data, {
    String tableName = '${Constants.VOCAB_TABLE_NAME}',
  }) async {
    return _run(() async {
      return await _supabase
          .from(tableName)
          .upsert(data)
          .select()
          .timeout(Constants.timeoutDuration);
    }, successStatus: 201);
  }

  static Future<DbResponse> deleteRow(
    String columnValue, {
    String columnName = '${Constants.ID_COLUMN}',
    String tableName = '${Constants.VOCAB_TABLE_NAME}',
  }) async {
    return _run(() async {
      return await _supabase
          .from(tableName)
          .delete()
          .eq(columnName, columnValue)
          .select()
          .timeout(Constants.timeoutDuration);
    });
  }
}
