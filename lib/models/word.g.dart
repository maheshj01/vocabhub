// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Word _$WordFromJson(Map<String, dynamic> json) {
  return Word(
    json['id'] as String,
    json['word'] as String,
    json['meaning'] as String,
    synonyms:
        (json['synonyms'] as List<dynamic>?)?.map((e) => e as String).toList(),
    mnemonics:
        (json['mnemonics'] as List<dynamic>?)?.map((e) => e as String).toList(),
    note: json['note'] as String?,
    examples:
        (json['examples'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$WordToJson(Word instance) => <String, dynamic>{
      'id': instance.id,
      'word': instance.word,
      'meaning': instance.meaning,
      'synonyms': instance.synonyms,
      'examples': instance.examples,
      'mnemonics': instance.mnemonics,
      'note': instance.note,
    };
