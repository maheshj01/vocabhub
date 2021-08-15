import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:vocabhub/pages/home.dart';
import 'package:vocabhub/pages/splashscreen.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'constants/colors.dart';
import 'constants/constants.dart';
import 'models/user.dart';
import 'utils/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  runApp(VocabApp());
}

final ValueNotifier<bool> darkNotifier = ValueNotifier<bool>(false);
final ValueNotifier<int> totalNotifier = ValueNotifier<int>(0);
final ValueNotifier<List<Word>?> listNotifier = ValueNotifier<List<Word>>([]);

FirebaseAnalytics analytics = FirebaseAnalytics();
FirebaseAnalyticsObserver observer =
    FirebaseAnalyticsObserver(analytics: analytics);

class VocabApp extends StatelessWidget {
  Future<bool> initatializeApp() async {
    firebaseAnalytics = Analytics();
    firebaseAnalytics.appOpen();
    final isDark = await Settings().isDark;
    return isDark;
  }

  late Analytics firebaseAnalytics;
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<User>(create: (context) => User()),
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
                        primaryColor: primaryDark,
                        textTheme: googleFontsTextTheme(context),
                      ),
                      color: primaryColor,
                      theme: ThemeData(
                        primaryColor: primaryColor,
                        appBarTheme: AppBarTheme(backgroundColor: Colors.white),
                        iconTheme: IconThemeData(
                            color: darkNotifier.value
                                ? Colors.white
                                : primaryColor),
                        textTheme: googleFontsTextTheme(context),
                        cupertinoOverrideTheme: CupertinoThemeData(
                          primaryColor: primaryColor,
                        ),
                        textSelectionTheme:
                            TextSelectionThemeData(cursorColor: primaryColor),
                      ),
                      themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                      home: Builder(
                          builder: (BuildContext _) => kIsWeb &&
                                  MediaQuery.of(_).size.width > MOBILE_WIDTH
                              ? MyHomePage(title: '$APP_TITLE')
                              : SplashScreen()),
                      navigatorObservers: [
                        FirebaseAnalyticsObserver(analytics: analytics),
                      ]);
                });
          }),
    );
  }
}
