import 'package:supabase/supabase.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/report.dart';
import 'package:vocabhub/services/services/database.dart';

class ReportService {
  static final String _tableName = Constants.FEEDBACK_TABLE_NAME;
  static final Logger _logger = Logger('ReportService');

  static Future<Map<String, List<ReportModel>>> getReports() async {
    final resp = await DatabaseService.findReports(tableName: _tableName, sort: true);
    final Map<String, List<ReportModel>> results = {};
    if (resp.status == 200) {
      List<ReportModel> list = (resp.data as List).map((e) => ReportModel.fromJson(e)).toList();
      for (var report in list) {
        if (results.containsKey(report.email.toLowerCase().trim())) {
          results[report.email]!.add(report);
        } else {
          results[report.email] = [report];
        }
      }
      return results;
    } else {
      throw Exception('Error fetching reports');
    }
  }

  static Future<List<ReportModel>?>? getReportByEmail(String email) async {
    final resp = await DatabaseService.findRowByColumnValue(email,
        columnName: Constants.USER_EMAIL_COLUMN, tableName: _tableName, sort: false);
    if (resp.status == 200) {
      return (resp.data as List).map((e) => ReportModel.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching report');
    }
  }

  static Future<PostgrestResponse> addReport(ReportModel report) async {
    try {
      final resp = await DatabaseService.insertIntoTable(
        report.toJson(),
        table: _tableName,
      );
      if (resp.status == 201) {
        _logger.i('Report added successfully');
      } else {
        _logger.e('Error adding report ${resp.data}');
      }
      return resp;
    } catch (_) {
      _logger.e('Error adding report ${_.toString()}');
      throw Exception('Error adding report');
    }
  }
}
