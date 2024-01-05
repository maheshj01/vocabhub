import 'package:shared_preferences/shared_preferences.dart';

class AppUtility {
  AppUtility({
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;

  final String kOldAppVersionKey = 'kOldAppVersionKey';

  void setAppVersion(String value) {
    sharedPreferences.setString(kOldAppVersionKey, value);
  }

  /// Returns the last stored app version
  /// This is used to check if the app version has changed
  /// inorder to show the changelog
  String getVersion() {
    return sharedPreferences.getString(kOldAppVersionKey) ?? '1.0.0 1';
  }
}
