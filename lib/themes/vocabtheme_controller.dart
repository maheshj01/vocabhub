import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/themes/theme_utils.dart';

class VocabThemeController {
  final bool isDark;
  final Color themeSeed;
  final bool isClassic;

  /// Whether the animated mesh background drifts. When false the background is
  /// still drawn (unless [isClassic]) but painted once and held static, letting
  /// the engine idle — a battery/motion "Dynamic UI" toggle.
  final bool dynamicBackground;

  VocabThemeController({
    required this.isDark,
    required this.themeSeed,
    required this.isClassic,
    this.dynamicBackground = true,
  });

  VocabThemeController copyWith({
    bool? isDark,
    Color? themeSeed,
    bool? isClassic,
    bool? dynamicBackground,
  }) {
    return VocabThemeController(
      isDark: isDark ?? this.isDark,
      themeSeed: themeSeed ?? this.themeSeed,
      isClassic: isClassic ?? this.isClassic,
      dynamicBackground: dynamicBackground ?? this.dynamicBackground,
    );
  }

  Map<String, dynamic> toMap() {
    final result = <String, dynamic>{};

    result.addAll({'isDark': isDark});
    result.addAll({'themeSeed': themeSeed.value});
    result.addAll({'isClassic': isClassic});
    result.addAll({'dynamicBackground': dynamicBackground});

    return result;
  }

  factory VocabThemeController.fromMap(Map<String, dynamic> map) {
    return VocabThemeController(
      isDark: map['isDark'] ?? false,
      themeSeed: Color(map['themeSeed']),
      isClassic: map['isClassic'] ?? false,
      dynamicBackground: map['dynamicBackground'] ?? true,
    );
  }

  String toJson() => json.encode(toMap());

  factory VocabThemeController.fromJson(String source) =>
      VocabThemeController.fromMap(json.decode(source));

  @override
  String toString() =>
      'VocabThemeController(isDark: $isDark, themeSeed: $themeSeed, isClassic: $isClassic, dynamicBackground: $dynamicBackground)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VocabThemeController &&
        other.isDark == isDark &&
        other.themeSeed == themeSeed &&
        other.isClassic == isClassic &&
        other.dynamicBackground == dynamicBackground;
  }

  @override
  int get hashCode =>
      isDark.hashCode ^ themeSeed.hashCode ^ isClassic.hashCode ^ dynamicBackground.hashCode;
}

class VocabThemeNotifier extends StateNotifier<VocabThemeController> {
  VocabThemeNotifier(this.ref)
      : super(VocabThemeController(isDark: false, themeSeed: Colors.blue, isClassic: false)) {
    state = ref.watch(themeUtilityProvider).getThemeController();
  }

  Ref ref;

  final String kRatedOnPlaystore = 'kRatedOnPlaystore';
  final String kLastRatedDate = 'kLastRatedDate';
  final String kOnboardedKey = 'kOnboardedKey';
  static const skipCountKey = 'skipCount';
  final String kAutoScrollKey = 'kAutoScrollKey';

  void setDark(bool dark) {
    state = state.copyWith(isDark: dark);
    final ThemeUtility settings = ref.watch(themeUtilityProvider);
    settings.setThemeController(state);
  }

  void setThemeSeed(Color themeSeed) {
    state = state.copyWith(themeSeed: themeSeed);
    final ThemeUtility settings = ref.watch(themeUtilityProvider);
    settings.setThemeController(state);
  }

  void setClassic(bool isClassic) {
    state = state.copyWith(isClassic: isClassic);
    final ThemeUtility settings = ref.watch(themeUtilityProvider);
    settings.setThemeController(state);
  }

  void setDynamicBackground(bool value) {
    state = state.copyWith(dynamicBackground: value);
    final ThemeUtility settings = ref.watch(themeUtilityProvider);
    settings.setThemeController(state);
  }

  void copyWith(VocabThemeController themeController) {
    state = state.copyWith(
        isClassic: themeController.isClassic,
        isDark: themeController.isDark,
        themeSeed: themeController.themeSeed);
  }
}
