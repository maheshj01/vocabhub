import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class AppController {
  final int index;
  final bool showFAB;
  final bool extended;
  final bool hasUpdate;
  final String version;

  AppController({
    this.index = 0,
    this.showFAB = true,
    this.extended = true,
    this.hasUpdate = false,
    this.version = '1.0.0 1',
  });

  AppController copyWith({
    int? index,
    bool? showFAB,
    bool? extended,
    bool? hasUpdate,
    String? version,
  }) {
    return AppController(
      index: index ?? this.index,
      showFAB: showFAB ?? this.showFAB,
      extended: extended ?? this.extended,
      hasUpdate: hasUpdate ?? this.hasUpdate,
      version: version ?? this.version,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'index': index});
    result.addAll({'showFAB': showFAB});
    result.addAll({'extended': extended});
    result.addAll({'hasUpdate': hasUpdate});
    result.addAll({'version': version});
    return result;
  }

  factory AppController.fromMap(Map<String, dynamic> map) {
    return AppController(
      index: map['index']?.toInt() ?? 0,
      showFAB: map['showFAB'] ?? false,
      extended: map['extended'] ?? false,
      hasUpdate: map['hasUpdate'] ?? false,
      version: map['version'] ?? '1.0.0 1',
    );
  }

  String toJson() => json.encode(toMap());

  factory AppController.fromJson(String source) => AppController.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AppController(index: $index, showFAB: $showFAB, extended: $extended, hasUpdate: $hasUpdate, version: $version)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AppController &&
        other.index == index &&
        other.showFAB == showFAB &&
        other.extended == extended &&
        other.hasUpdate == hasUpdate &&
        other.version == version;
  }

  @override
  int get hashCode {
    return index.hashCode ^
        showFAB.hashCode ^
        extended.hashCode ^
        hasUpdate.hashCode ^
        version.hashCode;
  }
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

  void setUpdate(bool update) {
    state = state.copyWith(hasUpdate: update);
  }

  void setVersion(String version) {
    state = state.copyWith(version: version);
  }

  void copyWith(AppController appController) {
    state = state.copyWith(
        index: appController.index,
        showFAB: appController.showFAB,
        extended: appController.extended,
        hasUpdate: appController.hasUpdate,
        version: appController.version);
  }
}
