// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditHistory _$EditHistoryFromJson(Map<String, dynamic> json) => EditHistory(
      id: json['id'] as String,
      word: Word.fromJson(json['word'] as Map<String, dynamic>),
      created_at: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      state: $enumDecode(_$WordEditStateEnumMap, json['state']),
      user_id: json['user_id'] as String,
      word_id: json['word_id'] as String,
    );

Map<String, dynamic> _$EditHistoryToJson(EditHistory instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.user_id,
      'word_id': instance.word_id,
      'word': instance.word,
      'state': _$WordEditStateEnumMap[instance.state]!,
      'created_at': instance.created_at?.toIso8601String(),
    };

const _$WordEditStateEnumMap = {
  WordEditState.approved: 'approved',
  WordEditState.rejected: 'rejected',
  WordEditState.pending: 'pending',
};
