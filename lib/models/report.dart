import 'package:json_annotation/json_annotation.dart';

part '../generated/models/report.g.dart';

@JsonSerializable()
class ReportModel {
  final String id;
  final String email;
  final String name;
  final String feedback;
  final DateTime created_at;

  ReportModel({
    required this.id,
    required this.email,
    required this.name,
    required this.feedback,
    required this.created_at,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) => _$ReportModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReportModelToJson(this);
}
