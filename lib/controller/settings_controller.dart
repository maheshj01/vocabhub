import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vocabhub/services/services/settings_service.dart';
import 'package:vocabhub/themes/vocab_theme.dart';

class SettingsController extends ChangeNotifier {
  SettingsService? _settingsService;
  ThemeMode _theme = ThemeMode.light;
  ThemeMode get theme => _theme;

  bool get isDark => _theme == ThemeMode.dark; 
  Color _themeSeed = VocabTheme.colorSeeds[1];

  Color get themeSeed => _themeSeed;

  set themeSeed(Color value) {
    _themeSeed = value;
    notifyListeners();
    _settingsService!.setThemeSeed(value);
  }

  String? version;

  void setTheme(ThemeMode value) {
    _theme = value;
    notifyListeners();
    _settingsService!.setTheme(value);
  }

  Future<ThemeMode> getTheme() async {
    _theme = await _settingsService!.getTheme();
    return _theme;
  }

  Future<Color> getThemeSeed() async {
    _themeSeed = _settingsService!.getThemeSeed();
    return _themeSeed;
  }

  Future<void> loadSettings() async {
    _settingsService = SettingsService();
    await _settingsService!.init();
    _theme = await getTheme();
    _themeSeed = await getThemeSeed();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    notifyListeners();
  }
}
