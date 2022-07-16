// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditHistory _$EditHistoryFromJson(Map<String, dynamic> json) => EditHistory(
      edit_id: json['edit_id'] as String?,
      word_id: json['word_id'] as String,
      user_email: json['user_email'] as String,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      state: $enumDecodeNullable(_$WordEditStateEnumMap, json['state']) ??
          WordEditState.pending,
      created_at: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      synonyms: (json['synonyms'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      examples: (json['examples'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      mnemonics: (json['mnemonics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EditHistoryToJson(EditHistory instance) =>
    <String, dynamic>{
      'edit_id': instance.edit_id,
      'user_email': instance.user_email,
      'word_id': instance.word_id,
      'word': instance.word,
      'meaning': instance.meaning,
      'synonyms': instance.synonyms,
      'examples': instance.examples,
      'mnemonics': instance.mnemonics,
      'created_at': instance.created_at?.toIso8601String(),
      'state': _$WordEditStateEnumMap[instance.state]!,
    };

const _$WordEditStateEnumMap = {
  WordEditState.approved: 'approved',
  WordEditState.rejected: 'rejected',
  WordEditState.pending: 'pending',
};
