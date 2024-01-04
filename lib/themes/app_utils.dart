import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/controller/app_controller.dart';

class AppUtility {
  AppUtility({
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;

  final String kAppConfigKey = 'kAppConfigKey';

  void setAppUtils(AppController value) {
    final json = value.toJson();
    sharedPreferences.setString(kAppConfigKey, json);
  }

  AppController getAppController() {
    final String? config = sharedPreferences.getString(kAppConfigKey);
    if (config == null) {
      final defaultConfigController = AppController(
          extended: true, index: 0, hasUpdate: false, showFAB: false, version: "1.0.0 1");
      setAppUtils(defaultConfigController);
      return defaultConfigController;
    } else {
      final appConfig = AppController.fromJson(config);
      return appConfig;
    }
  }
}
