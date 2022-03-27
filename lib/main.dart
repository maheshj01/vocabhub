import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabhub/base_home.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/pages/home.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:logger/logger.dart' as log;
import 'package:vocabhub/pages/splashscreen.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/themes/vocab_theme_data.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'constants/constants.dart';
import 'models/user.dart';
import 'utils/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  analytics = FirebaseAnalytics();

  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  runApp(VocabApp());
}

final logger = log.Logger();
final ValueNotifier<bool> darkNotifier = ValueNotifier<bool>(false);
final ValueNotifier<int> totalNotifier = ValueNotifier<int>(0);
final ValueNotifier<List<Word>?> listNotifier = ValueNotifier<List<Word>>([]);

late FirebaseAnalytics analytics;
//  = FirebaseAnalytics();

// FirebaseAnalyticsObserver observer =
//     FirebaseAnalyticsObserver(analytics: analytics);

class VocabApp extends StatefulWidget {
  @override
  _VocabAppState createState() => _VocabAppState();
}

class _VocabAppState extends State<VocabApp> {
  Future<bool> initatializeApp() async {
    firebaseAnalytics = Analytics();
    firebaseAnalytics.appOpen();
    final isDark = await Settings().isDark;
    isSignedIn = await Settings().isSignedIn;
    count = await Settings().skipCount;
    return isDark;
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

  late bool isSignedIn;
  late int count;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UserModel>(create: (context) => UserModel()),
      ],
      child: FutureBuilder<bool>(
          future: initatializeApp(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            return ValueListenableBuilder<bool>(
                valueListenable: darkNotifier,
                builder: (context, bool isDark, Widget? child) {
                  if (snapshot.data == null) return LoadingWidget();
                  return MaterialApp(
                    title: '$APP_TITLE',
                    debugShowCheckedModeBanner: !kDebugMode,
                    darkTheme: ThemeData.dark().copyWith(
                      appBarTheme:
                          AppBarTheme(backgroundColor: Colors.grey[800]),
                      primaryColor: VocabThemeData.primaryDark,
                      textTheme: VocabThemeData.googleFontsTextTheme(context),
                    ),
                    color: VocabThemeData.primaryColor,
                    theme: ThemeData(
                      primaryColor: VocabThemeData.primaryColor,
                      appBarTheme: AppBarTheme(backgroundColor: Colors.white),
                      iconTheme: IconThemeData(
                          color: darkNotifier.value
                              ? Colors.white
                              : VocabThemeData.primaryColor),
                      textTheme: VocabThemeData.googleFontsTextTheme(context),
                      cupertinoOverrideTheme: CupertinoThemeData(
                        primaryColor: VocabThemeData.primaryColor,
                      ),
                      textSelectionTheme: TextSelectionThemeData(
                          cursorColor: VocabThemeData.primaryColor),
                    ),
                    themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                    home: Builder(builder: (BuildContext _) {
                      if (kIsWeb &&
                          MediaQuery.of(_).size.width > MOBILE_WIDTH) {
                        if (isSignedIn) {
                          return BaseHome(); //MyHomePage(title: '$APP_TITLE');
                        } else {
                          logger.i('count=$count');
                          if (count > 0) {
                            Settings().setSkipCount = count - 1;
                            return BaseHome(); //MyHomePage(title: APP_TITLE);
                          } else {
                            return AppSignIn();
                          }
                        }
                      } else {
                        return SplashScreen();
                      }
                    }),
                    // navigatorObservers: [
                    //   FirebaseAnalyticsObserver(analytics: analytics),
                    // ]
                  );
                });
          }),
    );
  }
}
