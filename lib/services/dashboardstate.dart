import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:vocabhub/models/models.dart';

class DashboardState {
  final Word? wordOfTheDay;
  final List<Word>? words;
  final List<Word>? bookMarks;
  DashboardState({
    this.wordOfTheDay,
    this.words,
    this.bookMarks,
  });

  DashboardState copyWith({
    Word? wordOfTheDay,
    List<Word>? words,
    List<Word>? bookMarks,
  }) {
    return DashboardState(
      wordOfTheDay: wordOfTheDay ?? this.wordOfTheDay,
      words: words ?? this.words,
      bookMarks: bookMarks ?? this.bookMarks,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    if (wordOfTheDay != null) {
      result.addAll({'wordOfTheDay': wordOfTheDay!.toMap()});
    }
    if (words != null) {
      result.addAll({'words': words!.map((x) => x.toMap()).toList()});
    }
    if (bookMarks != null) {
      result.addAll({'bookMarks': bookMarks!.map((x) => x.toMap()).toList()});
    }

    return result;
  }

  factory DashboardState.fromMap(Map<String, dynamic> map) {
    return DashboardState(
      wordOfTheDay: map['wordOfTheDay'] != null ? Word.fromMap(map['wordOfTheDay']) : null,
      words:
          map['words'] != null ? List<Word>.from(map['words']?.map((x) => Word.fromMap(x))) : null,
      bookMarks: map['bookMarks'] != null
          ? List<Word>.from(map['bookMarks']?.map((x) => Word.fromMap(x)))
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DashboardState.fromJson(String source) => DashboardState.fromMap(json.decode(source));

  @override
  String toString() =>
      'DashboardState(wordOfTheDay: $wordOfTheDay, words: $words, bookMarks: $bookMarks)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is DashboardState &&
        other.wordOfTheDay == wordOfTheDay &&
        listEquals(other.words, words) &&
        listEquals(other.bookMarks, bookMarks);
  }

  @override
  int get hashCode => wordOfTheDay.hashCode ^ words.hashCode ^ bookMarks.hashCode;
}
