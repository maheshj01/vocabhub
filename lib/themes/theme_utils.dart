import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/themes/vocabtheme_controller.dart';

class ThemeUtility {
  ThemeUtility({
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;

  final String kAppThemeKey = 'kAppThemeKey';

  void setThemeController(VocabThemeController value) {
    final json = value.toJson();
    sharedPreferences.setString(kAppThemeKey, json);
  }

  VocabThemeController getThemeController() {
    final String? theme = sharedPreferences.getString(kAppThemeKey);
    if (theme == null) {
      final defaultThemeController = VocabThemeController(
          themeSeed: VocabTheme.colorSeeds[1], isClassic: false, isDark: false);
      setThemeController(defaultThemeController);
      return defaultThemeController;
    } else {
      final ktheme = VocabThemeController.fromJson(theme);
      return ktheme;
    }
  }
}
