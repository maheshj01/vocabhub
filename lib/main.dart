import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:vocabhub/controller/auth_controller.dart';
import 'package:vocabhub/controller/controllers.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/navbar/profile/webview.dart';
import 'package:vocabhub/pages/notifications/notifications.dart';
import 'package:vocabhub/pages/splashscreen.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/services/services/local_service.dart';
import 'package:vocabhub/utils/firebase_options.dart';
import 'package:vocabhub/utils/logger.dart';

import 'constants/constants.dart';
import 'utils/settings.dart';

final userNotifierProvider = Provider<UserModel>((ref) {
  return UserModel.init();
});
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  firebaseAnalytics = FirebaseAnalytics.instance;
  usePathUrlStrategy();
  dashboardController = DashboardController();
  settingsController = SettingsController();
  exploreController = ExploreController();
  localService = LocalService();
  authController = AuthController();
  searchController = SearchFieldController(controller: TextEditingController());
  await dashboardController.initService();
  // pushNotificationService = PushNotificationService(_firebaseMessaging);
  searchController.initService();
  exploreController.initService();
  // pushNotificationService.initService();
  localService.initService();
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  Settings.init();
  settingsController.loadSettings();
  runApp(ProviderScope(
    child: VocabApp(),
  ));
}

class AppScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  // ignore: avoid_print
  print('notification(${notificationResponse.id}) action tapped: '
      '${notificationResponse.actionId} with'
      ' payload: ${notificationResponse.payload}');
  if (notificationResponse.input?.isNotEmpty ?? false) {
    // ignore: avoid_print
    logger.d('notification action tapped with input: ${notificationResponse.input}');
  }
}

late SettingsController settingsController;
late SearchFieldController searchController;
late ExploreController exploreController;
// late PushNotificationService pushNotificationService;
late DashboardController dashboardController;
late AuthController authController;
Logger logger = Logger('main.dart');
late LocalService localService;
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
late FirebaseAnalytics firebaseAnalytics;
final InitializationSettings initializationSettings = InitializationSettings(
    android: AndroidInitializationSettings(
      'app_icon',
    ),
    iOS: null,
    macOS: null);

class VocabApp extends ConsumerStatefulWidget {
  @override
  _VocabAppState createState() => _VocabAppState();
}

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//     FlutterLocalNotificationsPlugin();

class _VocabAppState extends ConsumerState<VocabApp> {
  Future<void> initializeApp() async {
    firebaseAnalytics.logAppOpen();
    await authController.initService();
    final localUser = authController.user;
    final user = ref.watch(userNotifierProvider);
    if (localUser.email.isNotEmpty) {
      if (localUser.isLoggedIn) {
        await autoLogin(localUser);
      }
    }

    /// user details not found locally
    /// set default user to local state
    user.setUser(localUser);
  }

  Future<void> autoLogin(UserModel localUser) async {
    final resp = await AuthService.updateLogin(email: localUser.email, isLoggedIn: true);
    final userProvider = ref.watch(userNotifierProvider);

    /// if login success, update local user details
    if (resp.status == Status.success) {
      final user = await UserService.findByEmail(email: localUser.email, cache: true);
      userProvider.setUser(user);
    } else {
      userProvider.setUser(localUser);
    }
  }

  FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(analytics: firebaseAnalytics);
  @override
  void dispose() {
    searchController.disposeService();
    dashboardController.disposeService();
    exploreController.disposeService();
    // pushNotificationService.disposeService();

    super.dispose();
  }

  @override
  void initState() {
    initializeApp();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateWidget(
      child: AnimatedBuilder(
          animation: settingsController,
          builder: (BuildContext context, Widget? child) {
            final colorScheme = ColorScheme.fromSeed(seedColor: settingsController.themeSeed);
            return MaterialApp(
              title: Constants.APP_TITLE,
              scrollBehavior: AppScrollBehavior(),
              navigatorObservers: [_observer],
              debugShowCheckedModeBanner: !kDebugMode,
              darkTheme: ThemeData.dark(
                useMaterial3: true,
              ).copyWith(
                  scaffoldBackgroundColor: colorScheme.background,
                  colorScheme: ColorScheme.fromSeed(
                      seedColor: settingsController.themeSeed, brightness: Brightness.dark)),
              theme: ThemeData(
                  useMaterial3: true,
                  scaffoldBackgroundColor: colorScheme.background,
                  colorScheme: ColorScheme.fromSeed(seedColor: settingsController.themeSeed)),
              routes: {
                Notifications.route: (context) => Notifications(),
                WebViewPage.routeName: (context) => WebViewPage(
                      title: Constants.PRIVACY_POLICY_TITLE,
                      url: Constants.PRIVACY_POLICY,
                    ),
              },
              themeMode: settingsController.theme,
              home: SplashScreen(),
            );
          }),
    );
  }
}
