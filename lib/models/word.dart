import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
part 'word.g.dart';

///
///
/// define a schema for your class and annotate
/// and then run
/// ```flutter pub run build_runner build --delete-conflicting-outputs```
/// to watch the file changes and generate the outpur
/// ```flutter pub run build_runner watch```

@JsonSerializable()
class Word {
  final String id;
  String word;
  String meaning;
  List<String>? synonyms;
  List<String>? examples;
  List<String>? mnemonics;
  DateTime? created_at;

  Word(this.id, this.word, this.meaning,
      {this.synonyms = const [],
      this.mnemonics = const [],
      this.created_at,
      this.examples = const []});

  factory Word.fromJson(Map<String, dynamic> json) => _$WordFromJson(json);

  factory Word.init() {
    return Word('', '', '', created_at: DateTime.now());
  }

  factory Word.fromEditHistoryJson(Map<String, dynamic> json) {
    return Word(
      json['word_id'] as String,
      json['word'] as String,
      json['meaning'] as String,
      synonyms: (json['synonyms'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      mnemonics:
          (json['mnemonics'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      created_at: json['created_at'] == null ? null : DateTime.parse(json['created_at'] as String),
      examples: (json['examples'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
    );
  }

  /// TODO: Doesn't seem to work for iterables
  Word copyWith(
      {String? id,
      String? word,
      String? meaning,
      List<String>? synonyms = const [],
      List<String>? examples = const [],
      List<String>? mnemonics = const [],
      DateTime? created_at}) {
    return Word(
      id ?? this.id,
      word ?? this.word,
      meaning ?? this.meaning,
      examples: examples!.isEmpty ? this.examples : examples,
      synonyms: synonyms!.isEmpty ? this.synonyms : synonyms,
      mnemonics: mnemonics!.isEmpty ? this.mnemonics : mnemonics,
      created_at: created_at ?? this.created_at,
    );
  }

  Word deepCopy() => Word(id, word, meaning,
      synonyms: synonyms!.toList(),
      examples: examples!.toList(),
      mnemonics: mnemonics!.toList(),
      created_at: created_at);

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'id': id});
    result.addAll({'word': word});
    result.addAll({'meaning': meaning});
    if (synonyms != null) {
      result.addAll({'synonyms': synonyms});
    }
    if (examples != null) {
      result.addAll({'examples': examples});
    }
    if (mnemonics != null) {
      result.addAll({'mnemonics': mnemonics});
    }
    if (created_at != null) {
      result.addAll({'created_at': created_at!.millisecondsSinceEpoch});
    }

    return result;
  }

  String toJson() => json.encode(toMap());

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      map['id'] ?? '',
      map['word'] ?? '',
      map['meaning'] ?? '',
      synonyms: (map['synonyms'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      examples: (map['examples'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      mnemonics: (map['mnemonics'] as List<dynamic>?)?.map((e) => e as String).toList() ?? const [],
      created_at:
          map['created_at'] != null ? DateTime.fromMillisecondsSinceEpoch(map['created_at']) : null,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Word &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          word == other.word &&
          meaning == other.meaning &&
          listEquals(synonyms, other.synonyms) &&
          listEquals(examples, other.examples) &&
          listEquals(mnemonics, other.mnemonics) &&
          created_at == other.created_at;

  @override
  int get hashCode => id.hashCode ^ word.hashCode;

  Map<String, dynamic> toMapJson() => _$WordToJson(this);
}
