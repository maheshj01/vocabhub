import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:vocabhub/services/services/settings_service.dart';
import 'package:vocabhub/themes/vocab_theme.dart';

class SettingsController extends ChangeNotifier {
  SettingsService? _settingsService;
  ThemeMode _theme = ThemeMode.light;
  ThemeMode get theme => _theme;
  bool _ratedOnPlayStore = false;
  DateTime _lastRatedDate = DateTime.now();

  bool get hasRatedOnPlaystore => _ratedOnPlayStore;

  bool get isDark => _theme == ThemeMode.dark;
  Color _themeSeed = VocabTheme.colorSeeds[1];
  String? version;

  Color get themeSeed => _themeSeed;

  set lastRatedDate(DateTime value) {
    _lastRatedDate = value;
    notifyListeners();
  }

  DateTime get lastRatedDate => _lastRatedDate;

  /// Returns the last rated sheet shown date
  /// this time does not indicate the user has rated the app
  /// it only indicates the last time the user was shown the rate sheet
  Future<DateTime> getLastRatedShown() async {
    _lastRatedDate = await _settingsService!.getLastRatedShownDate();
    return _lastRatedDate;
  }

  set themeSeed(Color value) {
    _themeSeed = value;
    notifyListeners();
    _settingsService!.setThemeSeed(value);
  }

  set ratedOnPlaystore(bool value) {
    _ratedOnPlayStore = value;
    notifyListeners();
    _settingsService!.setRatedOnPlaystore(value);
  }

  bool getRatedOnPlaystore() {
    _ratedOnPlayStore = _settingsService!.getRatedOnPlaystore();
    return _ratedOnPlayStore;
  }

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
    _ratedOnPlayStore = getRatedOnPlaystore();
    _lastRatedDate = await getLastRatedShown();
    final PackageInfo packageInfo = await PackageInfo.fromPlatform();
    version = packageInfo.version;
    notifyListeners();
  }
}
