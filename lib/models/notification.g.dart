// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) =>
    NotificationModel(
      UserModel.fromJson(
          json['$USER_TABLE_NAME'] ??= json as Map<String, dynamic>),
      EditHistory.fromJson(json),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) =>
    <String, dynamic>{
      'user': instance.user,
      'edit': instance.edit,
    };
