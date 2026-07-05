// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NotificationModel _$NotificationModelFromJson(Map<String, dynamic> json) => NotificationModel(
      UserModel.fromJson(json['user'] as Map<String, dynamic>),
      EditHistory.fromJson(json['edit'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$NotificationModelToJson(NotificationModel instance) => <String, dynamic>{
      'user': instance.user,
      'edit': instance.edit,
    };
