import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/pages/home.dart';
import 'package:logger/logger.dart' as log;
import 'package:vocabhub/pages/splashscreen.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'constants/constants.dart';
import 'utils/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  analytics = FirebaseAnalytics.instance;
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  Settings.init();
  runApp(VocabApp());
}

final logger = log.Logger();
final ValueNotifier<bool> darkNotifier = ValueNotifier<bool>(false);
final ValueNotifier<int> totalNotifier = ValueNotifier<int>(0);
final ValueNotifier<List<Word>?> listNotifier = ValueNotifier<List<Word>>([]);

late FirebaseAnalytics analytics;
FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

class VocabApp extends StatefulWidget {
  @override
  _VocabAppState createState() => _VocabAppState();
}

class _VocabAppState extends State<VocabApp> {
  Future<void> initatializeApp() async {
    firebaseAnalytics = Analytics();
    firebaseAnalytics.appOpen();
    final email = await Settings.email;
    if (email.isNotEmpty) {
      final response =
          await AuthService.updateLogin(email: email, isLoggedIn: true);
      print(response.status);
    }
  }

  late Analytics firebaseAnalytics;
  @override
  void dispose() {
    darkNotifier.dispose();
    totalNotifier.dispose();
    searchController.dispose();
    listNotifier.dispose();
    logger.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    initatializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return AppStateWidget(
      child: AnimatedBuilder(
          animation: Settings(),
          builder: (BuildContext context, Widget? child) {
            return MaterialApp(
              title: '$APP_TITLE',
              debugShowCheckedModeBanner: !kDebugMode,
              darkTheme: VocabTheme.darkThemeData,
              theme: VocabTheme.lightThemeData,
              themeMode: VocabTheme.isDark ? ThemeMode.dark : ThemeMode.light,
              home: SplashScreen(),
            );
          }),
    );
  }
}
