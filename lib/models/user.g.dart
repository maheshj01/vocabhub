// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return UserModel(
    name: json['name'] as String,
    email: json['email'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    idToken: json['idToken'] as String?,
    isAdmin: json['isAdmin'] as bool,
    accessToken: json['accessToken'] as String?,
    username: json['username'] as String,
    created_at: json['created_at'] == null
        ? null
        : DateTime.parse(json['created_at'] as String),
    isLoggedIn: json['isLoggedIn'] as bool,
    bookmarks: (json['bookmarks'] as List<dynamic>)
        .map((e) => Word.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'idToken': instance.idToken,
      'accessToken': instance.accessToken,
      'bookmarks': instance.bookmarks,
      'email': instance.email,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
      'isLoggedIn': instance.isLoggedIn,
      'isAdmin': instance.isAdmin,
      'username': instance.username,
      'created_at': instance.created_at?.toIso8601String(),
    };
