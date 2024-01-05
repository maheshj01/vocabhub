import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/models/version.dart';

class AppUtility {
  AppUtility({
    required this.sharedPreferences,
  });

  final SharedPreferences sharedPreferences;

  final String kOldAppVersionKey = 'kOldAppVersionKey';

  void setAppVersion(AppVersion value) {
    final String version = value.toJson();
    sharedPreferences.setString(kOldAppVersionKey, version);
  }

  /// Returns the last stored app version
  /// This is used to check if the app version has changed
  /// inorder to show the changelog
  AppVersion getVersion() {
    final String? version = sharedPreferences.getString(kOldAppVersionKey);
    if (version != null) {
      // TODO: to remove this condition in future
      print("stored version: $version");
      if (!version.startsWith('{')) {
        final appVersion = version.split(' ')[0];
        final buildNumber = version.split(' ')[1];
        final storedVersion = Version(
          version: appVersion,
          buildNumber: int.parse(buildNumber),
          date: DateTime.now(),
        );
        return AppVersion(version: storedVersion, oldVersion: storedVersion);
      } else {
        final appVer = AppVersion.fromJson(version);
        return appVer;
      }
    } else {
      final defaultVersion = Version(
        version: '1.0.0',
        buildNumber: 1,
        date: DateTime.now(),
      );
      return AppVersion(version: defaultVersion, oldVersion: defaultVersion);
    }
  }
}
