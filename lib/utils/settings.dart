import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/main.dart';

class Settings {
  static SharedPreferences? _sharedPreferences;

  Settings() {
    init();
  }
  Future<void> init() async {
    _sharedPreferences = await SharedPreferences.getInstance();
  }

  set dark(bool value) {
    _sharedPreferences!.setBool('isDark', value);
  }

  Future<bool> isDark() async {
    if (_sharedPreferences == null) {
      _sharedPreferences = await SharedPreferences.getInstance();
    }
    bool _dark = _sharedPreferences!.getBool('isDark') ?? false;
    if (_dark) {
      darkNotifier.value = true;
    }
    return _dark;
  }
}
