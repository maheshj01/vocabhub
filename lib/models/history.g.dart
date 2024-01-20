// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EditHistory _$EditHistoryFromJson(Map<String, dynamic> json) => EditHistory(
      edit_id: json['edit_id'] as String?,
      word_id: json['word_id'] as String,
      email: json['email'] as String,
      word: json['word'] as String,
      meaning: json['meaning'] as String,
      comments: json['comments'] as String? ?? '',
      state: $enumDecodeNullable(_$EditStateEnumMap, json['state']) ??
          EditState.pending,
      edit_type: $enumDecodeNullable(_$EditTypeEnumMap, json['edit_type']) ??
          EditType.edit,
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
      users_mobile: json['users_mobile'] == null
          ? null
          : UserModel.fromJson(json['users_mobile'] as String),
      mnemonics: (json['mnemonics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$EditHistoryToJson(EditHistory instance) =>
    <String, dynamic>{
      'edit_id': instance.edit_id,
      'email': instance.email,
      'word_id': instance.word_id,
      'word': instance.word,
      'meaning': instance.meaning,
      'synonyms': instance.synonyms,
      'examples': instance.examples,
      'mnemonics': instance.mnemonics,
      'created_at': instance.created_at?.toUtc(),
      'state': _$EditStateEnumMap[instance.state],
      'edit_type': _$EditTypeEnumMap[instance.edit_type],
      'comments': instance.comments,
      'users_mobile': instance.users_mobile,
    };

const _$EditStateEnumMap = {
  EditState.approved: 'approved',
  EditState.rejected: 'rejected',
  EditState.pending: 'pending',
  EditState.cancelled: 'cancelled',
};

const _$EditTypeEnumMap = {
  EditType.add: 'add',
  EditType.edit: 'edit',
  EditType.delete: 'delete',
};
