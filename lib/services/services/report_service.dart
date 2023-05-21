import 'package:supabase/supabase.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/report.dart';
import 'package:vocabhub/services/services/database.dart';

class ReportService {
  static final String _tableName = Constants.FEEDBACK_TABLE_NAME;
  static final Logger _logger = Logger('ReportService');
  static Future<List<ReportModel>>? getReports() async {
    final resp = await DatabaseService.findAll(tableName: _tableName);
    if (resp.status == 200) {
      return (resp.data as List).map((e) => ReportModel.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching reports');
    }
  }

  static Future<List<ReportModel>?>? getReportByEmail(String email) async {
    final resp = await DatabaseService.findRowByColumnValue(
      email,
      columnName: Constants.USER_EMAIL_COLUMN,
      tableName: _tableName,
    );
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


