import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/themes/vocab_theme.dart';

class SettingsService {
  late SharedPreferences _sharedPreferences;
  final String kThemeKey = 'kThemeKey';
  final String kThemeSeedKey = 'kThemeSeedKey';
  final String kRatedOnPlaystore = 'kRatedOnPlaystore';
  final String kLastRatedDate = 'kLastRatedDate';
  final String kOnboardedKey = 'kOnboardedKey';

  void setTheme(ThemeMode value) {
    _sharedPreferences.setBool(kThemeKey, value == ThemeMode.dark);
  }

  Future<ThemeMode> getTheme() async {
    final bool theme = _sharedPreferences.getBool(kThemeKey) ?? true;
    return theme == true ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setOnboarded(bool value) async {
    await _sharedPreferences.setBool(kOnboardedKey, value);
  }

  Future<bool> getOnboarded() async {
    return _sharedPreferences.getBool(kOnboardedKey) ?? false;
  }

  /// Returns the last rated sheet shown date
  /// this time does not indicate the user has rated the app
  /// it only indicates the last time the user was shown the rate sheet
  Future<DateTime> getLastRatedShownDate() async {
    final lastRatedDateTimeString =
        _sharedPreferences.getString(kLastRatedDate) ?? DateTime.now().toIso8601String();
    return DateTime.parse(lastRatedDateTimeString);
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

  Future<void> setRatedOnPlaystore(bool value) async {
    await _sharedPreferences.setBool(kRatedOnPlaystore, value);

    /// Rated Sheet was shown, so update the last rated date
    await _sharedPreferences.setString(kLastRatedDate, DateTime.now().toIso8601String());
  }

  bool getRatedOnPlaystore() {
    return _sharedPreferences.getBool(kRatedOnPlaystore) ?? false;
  }
}
