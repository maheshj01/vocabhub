// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) {
  return User(
    name: json['name'] as String,
    email: json['email'] as String,
    avatarUrl: json['avatarUrl'] as String?,
    idToken: json['idToken'] as String?,
    accessToken: json['accessToken'] as String?,
    bookmarks: (json['bookmarks'] as List<dynamic>)
        .map((e) => Word.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'idToken': instance.idToken,
      'accessToken': instance.accessToken,
      'bookmarks': instance.bookmarks,
      'email': instance.email,
      'name': instance.name,
      'avatarUrl': instance.avatarUrl,
    };
