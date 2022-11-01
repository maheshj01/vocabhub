import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/report.dart';
import 'package:vocabhub/services/services/database.dart';

class ReportService {
  static final String _tableName = FEEDBACK_TABLE_NAME;

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
      columnName: USER_EMAIL_COLUMN,
      tableName: _tableName,
    );
    if (resp.status == 200) {
      return (resp.data as List).map((e) => ReportModel.fromJson(e)).toList();
    } else {
      throw Exception('Error fetching report');
    }
  }

  static Future<void> addReport(ReportModel report) async {
    final resp = await DatabaseService.insertIntoTable(
      report.toJson(),
      table: _tableName,
    );
    if (resp.status == 201) {
      print('Report added');
    } else {
      throw Exception('Error adding report');
    }
  }
}
