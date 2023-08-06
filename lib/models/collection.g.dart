// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'collection.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

VHCollection _$VHCollectionFromJson(Map<String, dynamic> json) => VHCollection(
      isPinned: json['isPinned'] as bool,
      words: (json['words'] as List<dynamic>)
          .map((e) => Word.fromJson(e as Map<String, dynamic>))
          .toList(),
      title: json['title'] as String,
    );

Map<String, dynamic> _$VHCollectionToJson(VHCollection instance) =>
    <String, dynamic>{
      'isPinned': instance.isPinned,
      'words': instance.words,
      'title': instance.title,
    };
