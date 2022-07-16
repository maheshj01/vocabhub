import 'package:supabase/supabase.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/utils/secrets.dart';

class DatabaseService {
  static SupabaseClient _supabase = SupabaseClient("$CONFIG_URL", "$APIkey");

  static Future<PostgrestResponse> findRowByColumnValue(String columnValue,
      {String columnName = '$ID_COLUMN',
      String tableName = '$VOCAB_TABLE_NAME'}) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .eq('$columnName', columnValue)
        .execute();
    return response;
  }

  static Future<PostgrestResponse> findAll(
      {String tableName = '$VOCAB_TABLE_NAME'}) async {
    final response = await _supabase.from(tableName).select().execute();
    return response;
  }

  static Future<PostgrestResponse> findSingleRowByColumnValue(
      String columnValue,
      {String columnName = '$ID_COLUMN',
      String tableName = '$VOCAB_TABLE_NAME'}) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .eq('$columnName', columnValue)
        .single()
        .execute();
    return response;
  }

  static Future<PostgrestResponse> insertIntoTable(Map<String, dynamic> data,
      {String table = '$VOCAB_TABLE_NAME'}) async {
    final response = await _supabase.from(table).insert(data).execute();
    return response;
  }

  static Future<PostgrestResponse> updateRow(
      {required String columnValue,
      required Map<String, dynamic> data,
      String columnName = '$ID_COLUMN',
      String tableName = '$VOCAB_TABLE_NAME'}) async {
    final response = await _supabase
        .from(tableName)
        .update(data)
        .eq("$columnName", "$columnValue")
        .execute();
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
        .execute();
    return response;
  }

  static Future<PostgrestResponse> upsertRow(Map<String, dynamic> data,
      {String tableName = '$VOCAB_TABLE_NAME'}) async {
    final response = await _supabase.from(tableName).upsert(data).execute();
    return response;
  }

  static Future<PostgrestResponse> deleteRow(String columnValue,
      {String columnName = '$ID_COLUMN',
      String tableName = '$VOCAB_TABLE_NAME'}) async {
    final response = await _supabase
        .from(tableName)
        .delete()
        .eq('$columnName', columnValue)
        .execute();
    return response;
  }
}

class ResponseObject {
  final String message;
  final Object data;
  final Status status;

  ResponseObject(this.message, this.data, this.status);
}


class Response {
  bool didSucced;
  String message;
  int? status;
  Object? data;

  Response(
      {required this.didSucced, required this.message, this.status, this.data});
}