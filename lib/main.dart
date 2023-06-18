import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:vocabhub/controller/explore_controller.dart';
import 'package:vocabhub/controller/settings_controller.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/navbar/profile/webview.dart';
import 'package:vocabhub/pages/notifications/notifications.dart';
import 'package:vocabhub/pages/splashscreen.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/services/services/pushnotification_service.dart';
import 'package:vocabhub/utils/firebase_options.dart';

import 'constants/constants.dart';
import 'controller/searchfield_controller.dart';
import 'utils/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  firebaseAnalytics = FirebaseAnalytics.instance;
  usePathUrlStrategy();
  settingsController = SettingsController();
  exploreController = ExploreController();
  searchController = SearchFieldController(controller: TextEditingController());
  searchController.initService();
  exploreController.initService();
  pushNotificationService = PushNotificationService(_firebaseMessaging);
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  Settings.init();
  settingsController.loadSettings();
  runApp(VocabApp());
}

late SettingsController settingsController;
late SearchFieldController searchController;
late ExploreController exploreController;
late PushNotificationService pushNotificationService;

final ValueNotifier<int> totalNotifier = ValueNotifier<int>(0);
final ValueNotifier<List<Word>?> listNotifier = ValueNotifier<List<Word>>([]);
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
late FirebaseAnalytics firebaseAnalytics;

class VocabApp extends StatefulWidget {
  @override
  _VocabAppState createState() => _VocabAppState();
}

class _VocabAppState extends State<VocabApp> {
  Future<void> initializeApp() async {
    firebaseAnalytics.logAppOpen();
    final email = await Settings.email;
    if (email.isNotEmpty) {
      await AuthService.updateLogin(email: email, isLoggedIn: true);
    }
    // pushNotificationService!.showFlutterNotification(RemoteMessage(
    //     data: {'title': 'Welcome', 'body': 'Welcome to VocabHub'}));
  }

  FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(analytics: firebaseAnalytics);
  @override
  void dispose() {
    searchController.dispose();
    totalNotifier.dispose();
    listNotifier.dispose();
    exploreController.dispose();
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
                      title: 'Privacy Policy',
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
