// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../../models/report.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReportModel _$ReportModelFromJson(Map<String, dynamic> json) => ReportModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      feedback: json['feedback'] as String,
      created_at: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ReportModelToJson(ReportModel instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'feedback': instance.feedback,
      'created_at': instance.created_at.toIso8601String(),
    };
