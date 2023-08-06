import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:vocabhub/models/word.dart';

part 'collection.g.dart';

@JsonSerializable()
class VHCollection {
  bool isPinned;
  List<Word> words;
  String title;

  VHCollection({
    required this.isPinned,
    required this.words,
    required this.title,
  });

  VHCollection.init({bool pinned = false})
      : isPinned = pinned,
        words = [],
        title = '';

  factory VHCollection.fromJson(Map<String, dynamic> json) => _$VHCollectionFromJson(json);

  /// Connect the generated [_$VHCollectionToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$VHCollectionToJson(this);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VHCollection &&
        other.isPinned == isPinned &&
        listEquals(other.words, words) &&
        other.title == title &&
        other.hashCode == hashCode;
  }
}
