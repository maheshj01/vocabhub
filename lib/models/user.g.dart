// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    json['name'] as String,
    json['email'] as String,
    json['avatarUrl'] as String?,
    idToken: json['idToken'] as String?,
    accessToken: json['accessToken'] as String?,
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'idToken': instance.idToken,
      'accessToken': instance.accessToken,
      'email': instance.email,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
    };
