import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AppController {
  final int index;
  final bool showFAB;
  final bool extended;

  AppController({
    this.index = 0,
    this.showFAB = true,
    this.extended = true,
  });

  AppController copyWith({
    int? index,
    bool? showFAB,
    bool? extended,
  }) {
    return AppController(
      index: index ?? this.index,
      showFAB: showFAB ?? this.showFAB,
      extended: extended ?? this.extended,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'index': index});
    result.addAll({'showFAB': showFAB});
    result.addAll({'extended': extended});

    return result;
  }

  factory AppController.fromMap(Map<String, dynamic> map) {
    return AppController(
      index: map['index']?.toInt() ?? 0,
      showFAB: map['showFAB'] ?? false,
      extended: map['extended'] ?? false,
    );
  }

  String toJson() => json.encode(toMap());

  factory AppController.fromJson(String source) => AppController.fromMap(json.decode(source));

  @override
  String toString() => 'AppController(index: $index, showFAB: $showFAB, extended: $extended)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppController &&
        other.index == index &&
        other.showFAB == showFAB &&
        other.extended == extended;
  }

  @override
  int get hashCode => index.hashCode ^ showFAB.hashCode ^ extended.hashCode;
}

class AppNotifier extends StateNotifier<AppController> {
  AppNotifier(super.state);

  void setIndex(int index) {
    state = state.copyWith(index: index);
  }

  void setShowFAB(bool showFAB) {
    state = state.copyWith(showFAB: showFAB);
  }

  void setExtended(bool extended) {
    state = state.copyWith(extended: extended);
  }
}
