import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
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
import 'package:vocabhub/pages/login.dart';
import 'package:logger/logger.dart' as log;
import 'package:vocabhub/pages/splashscreen.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/themes/vocab_theme_data.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'constants/constants.dart';
import 'models/user.dart';
import 'utils/settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  analytics = FirebaseAnalytics();
  GoRouter.setUrlPathStrategy(UrlPathStrategy.path);
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
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
  Future<bool> initatializeApp() async {
    firebaseAnalytics = Analytics();
    firebaseAnalytics.appOpen();
    isDark = await Settings().isDark;
    isSignedIn = await Settings.isSignedIn;
    count = await Settings().skipCount;
    return isDark;
  }

  late Analytics firebaseAnalytics;
  late bool isDark;

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

  final _router = GoRouter(
      navigatorBuilder: (context, state, Widget child) {
        return Navigator(
            key: state.pageKey,
            onGenerateRoute: (x) {
              return MaterialPageRoute(
                builder: (context) => child,
                settings: x,
              );
            },
            observers: [observer]);
      },
      routes: [
        GoRoute(
            path: '/',
            builder: (context, state) {
              bool isDesktop = isDisplayDesktop(context);
              if (kIsWeb && isDesktop) {
                if (isSignedIn) {
                  return BaseHome();
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
        GoRoute(
          path: '/home',
          builder: (context, state) => BaseHome(),
        ),
        GoRoute(
          path: '/signIn',
          builder: (context, state) => AppSignIn(),
        ),
      ],
      errorBuilder: (context, state) {
        return Material(
          child: Center(
            child: Text(
              'Error: ${state.error}',
              style: TextStyle(color: Colors.red),
            ),
          ),
        );
      });

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
                  return MaterialApp.router(
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
                    // builder:  (BuildContext _,Widget ? child) {
                    //   if (kIsWeb && isDisplayDesktop(context)) {
                    //     if (isSignedIn) {
                    //       return BaseHome();
                    //     } else {
                    //       logger.i('count=$count');
                    //       if (count > 0) {
                    //         Settings().setSkipCount = count - 1;
                    //         return BaseHome(); //MyHomePage(title: APP_TITLE);
                    //       } else {
                    //         return AppSignIn();
                    //       }
                    //     }
                    //   } else {
                    //     return SplashScreen();
                    //   }
                    // },
                    routeInformationParser: _router.routeInformationParser,
                    routerDelegate: _router.routerDelegate,
                  );
                });
          }),
    );
  }
}
