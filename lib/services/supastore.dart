import 'package:supabase/supabase.dart';
import 'package:logger/logger.dart' as log;
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/secrets.dart';
import 'package:postgrest/postgrest.dart';

class SupaStore {
  static String tableName = 'vocabhub';
  final _logger = log.Logger();
  final SupabaseClient _supabase = SupabaseClient("$CONFIG_URL", "$APIkey");

  Future<PostgrestResponse> findById(String id) async {
    final response = await _supabase
        .from(tableName)
        .select()
        .eq('id', id)
        .single()
        .execute();
    return response;
  }

  Future<PostgrestResponse> findByWord(String word) async {
    final response =
        await _supabase.from(tableName).select().eq('words', word).execute();
    return response;
  }

  /// ```Select * from words;```
  Future<PostgrestResponse> findAll() async {
    final response = await _supabase.from(tableName).select("*").execute();
    return response;
  }

  Future<PostgrestResponse> insert(Map<String, dynamic> json) async {
    final response = await _supabase.from(tableName).insert(json).execute();
    return response;
  }

  Future<PostgrestResponse> update({
    required String id,
    required Map<String, dynamic> json,
  }) async {
    final response =
        await _supabase.from(tableName).update(json).eq('id', id).execute();
    _logger.i(response.toJson());
    return response;
  }

  Future<PostgrestResponse> deleteById(String id) async {
    _logger.i(tableName);
    final response =
        await _supabase.from(tableName).delete().eq('id', id).execute();
    _logger.i(response.toJson());
    return response;
  }
}
