import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/pages/home.dart';
import 'package:logger/logger.dart' as log;
import 'package:vocabhub/pages/splashscreen.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'constants/constants.dart';
import 'models/user.dart';
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
    isSignedIn = await Settings.isSignedIn;
    count = await Settings.skipCount;
    firebaseAnalytics.appOpen();
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

  static late bool isSignedIn;
  static late int count;

  @override
  void initState() {
    super.initState();
    initatializeApp();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserModel>(create: (context) => UserModel()),
      ],
      child: AnimatedBuilder(
          animation: Settings(),
          builder: (BuildContext context, Widget? child) {
            return MaterialApp(
              title: '$APP_TITLE',
              debugShowCheckedModeBanner: !kDebugMode,
              darkTheme: ThemeData.dark().copyWith(
                appBarTheme: AppBarTheme(backgroundColor: Colors.grey[800]),
                primaryColor: VocabTheme.primaryDark,
                textTheme: VocabTheme.googleFontsTextTheme(context),
              ),
              color: VocabTheme.primaryColor,
              theme: ThemeData(
                primaryColor: VocabTheme.primaryColor,
                appBarTheme: AppBarTheme(backgroundColor: Colors.white),
                iconTheme: IconThemeData(
                    color: darkNotifier.value
                        ? Colors.white
                        : VocabTheme.primaryColor),
                textTheme: VocabTheme.googleFontsTextTheme(context),
                cupertinoOverrideTheme: CupertinoThemeData(
                  primaryColor: VocabTheme.primaryColor,
                ),
                textSelectionTheme: TextSelectionThemeData(
                    cursorColor: VocabTheme.primaryColor),
              ),
              themeMode: VocabTheme.isDark ? ThemeMode.dark : ThemeMode.light,
              home: SplashScreen(),
            );
          }),
    );
  }
}
