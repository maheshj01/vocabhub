import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
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

  Map<String, dynamic> toJson() => _$WordToJson(this);
}
