import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/themes/vocab_theme.dart';

class SettingsService {
  late SharedPreferences _sharedPreferences;
  final String kThemeKey = 'kThemeKey';
  final String kThemeSeedKey = 'kThemeSeedKey';

  void setTheme(ThemeMode value) {
    _sharedPreferences.setBool(kThemeKey, value == ThemeMode.dark);
  }

  Future<ThemeMode> getTheme() async {
    final bool theme = _sharedPreferences.getBool(kThemeKey) ?? true;
    return theme == true ? ThemeMode.dark : ThemeMode.light;
  }

  void setThemeSeed(Color color) {
    _sharedPreferences.setInt(kThemeSeedKey, color.value);
  }

  Color getThemeSeed() {
    final int color = _sharedPreferences.getInt(kThemeSeedKey) ?? VocabTheme.colorSeeds[1].value;
    return Color(color);
  }

  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }
}
