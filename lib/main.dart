import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/navbar/search/search.dart';
import 'package:vocabhub/pages/notifications/notifications.dart';
import 'package:vocabhub/pages/splashscreen.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/services/services/pushnotification_service.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/firebase_options.dart';

import 'constants/constants.dart';
import 'utils/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  analytics = FirebaseAnalytics.instance;
  usePathUrlStrategy();
  pushNotificationService = PushNotificationService(_firebaseMessaging);
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  Settings.init();
  runApp(VocabApp());
}

late PushNotificationService pushNotificationService;

// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   pushNotificationService = PushNotificationService(_firebaseMessaging);
//   await pushNotificationService!.setupFlutterNotifications();
//   pushNotificationService!.showFlutterNotification(message);
//   // If you're going to use other Firebase services in the background, such as Firestore,
//   // make sure you call `initializeApp` before using other Firebase services.
//   print('Handling a background message ${message.messageId}');
// }

final ValueNotifier<bool> darkNotifier = ValueNotifier<bool>(false);
final ValueNotifier<int> totalNotifier = ValueNotifier<int>(0);
final ValueNotifier<List<Word>?> listNotifier = ValueNotifier<List<Word>>([]);
final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
late FirebaseAnalytics analytics;
FirebaseAnalyticsObserver observer = FirebaseAnalyticsObserver(analytics: analytics);

class VocabApp extends StatefulWidget {
  @override
  _VocabAppState createState() => _VocabAppState();
}

class _VocabAppState extends State<VocabApp> {
  Future<void> initializeApp() async {
    firebaseAnalytics = Analytics();
    firebaseAnalytics.appOpen();
    final email = await Settings.email;
    if (email.isNotEmpty) {
      await AuthService.updateLogin(email: email, isLoggedIn: true);
    }
    // pushNotificationService!.showFlutterNotification(RemoteMessage(
    //     data: {'title': 'Welcome', 'body': 'Welcome to VocabHub'}));
  }

  late Analytics firebaseAnalytics;
  @override
  void dispose() {
    darkNotifier.dispose();
    totalNotifier.dispose();
    searchController.dispose();
    listNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateWidget(
      child: AnimatedBuilder(
          animation: Settings(),
          builder: (BuildContext context, Widget? child) {
            return MaterialApp(
              title: '$APP_TITLE',
              navigatorObservers: [observer],
              debugShowCheckedModeBanner: !kDebugMode,
              darkTheme: VocabTheme.darkThemeData,
              theme: VocabTheme.lightThemeData,
              routes: {
                Notifications.route: (context) => Notifications(),
              },
              themeMode: VocabTheme.isDark ? ThemeMode.dark : ThemeMode.light,
              home: SplashScreen(),
            );
          }),
    );
  }
}
