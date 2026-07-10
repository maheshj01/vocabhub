import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:vocabhub/models/word.dart';

part '../generated/models/collection.g.dart';

@JsonSerializable()
class VHCollection {
  bool isPinned;
  List<Word> words;
  String title;
  @JsonKey(fromJson: colorFromJson, toJson: colorToJson)
  Color color;

  VHCollection({
    required this.isPinned,
    required this.words,
    required this.title,
    required this.color,
  });

  VHCollection.init({bool pinned = false, String title = '', Color? color})
      : isPinned = pinned,
        words = [],
        color = color ?? Colors.primaries[0],
        title = title;

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
        other.color == color &&
        other.hashCode == hashCode;
  }
}

Color colorFromJson(int value) => Color(value);

int colorToJson(Color color) => color.value;
