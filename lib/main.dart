import 'package:feature_discovery/feature_discovery.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/controller/app_controller.dart';
import 'package:vocabhub/controller/auth_controller.dart';
import 'package:vocabhub/controller/collections_controller.dart';
import 'package:vocabhub/controller/controllers.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/navbar/profile/about.dart';
import 'package:vocabhub/navbar/profile/report.dart';
import 'package:vocabhub/navbar/profile/settings.dart';
import 'package:vocabhub/navbar/profile/webview.dart';
import 'package:vocabhub/pages/notifications/notifications.dart';
import 'package:vocabhub/pages/splashscreen.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/themes/theme_utils.dart';
import 'package:vocabhub/themes/vocabtheme_controller.dart';
import 'package:vocabhub/utils/firebase_options.dart';
import 'package:vocabhub/utils/logger.dart';
import 'package:vocabhub/widgets/whats_new.dart';

import 'constants/constants.dart';

final userNotifierProvider = Provider<UserModel>((ref) {
  return UserModel.init();
});

final dashBoardNotifier = Provider<DashboardController>((ref) => DashboardController());
final appProvider =
    StateNotifierProvider<AppNotifier, AppController>((ref) => AppNotifier(AppController(
          extended: true,
          index: 0,
          showFAB: true,
          hasUpdate: false,
        )));

final appThemeProvider =
    StateNotifierProvider<VocabThemeNotifier, VocabThemeController>(VocabThemeNotifier.new);

final collectionNotifier = ChangeNotifierProvider((ref) => CollectionsNotifier());

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final themeUtilityProvider = Provider<ThemeUtility>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return ThemeUtility(sharedPreferences: sharedPrefs);
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  firebaseAnalytics = FirebaseAnalytics.instance;
  usePathUrlStrategy();
  dashboardController = DashboardController();
  settingsController = SettingsController();
  exploreController = ExploreController();
  authController = AuthController();
  addWordController = AddWordController();
  searchController = SearchFieldController(controller: TextEditingController());
  settingsController.loadSettings();
  dashboardController.initService();
  pushNotificationService = PushNotificationService(_firebaseMessaging);
  searchController.initService();
  exploreController.initService();
  pushNotificationService.initService();
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  addWordController.initService();
  runApp(ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPreferences),
    ],
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
  appKey.currentState!.pushNamed(Notifications.route);
}

final appKey = GlobalKey<NavigatorState>();

late SettingsController settingsController;
late SearchFieldController searchController;
late ExploreController exploreController;
late PushNotificationService pushNotificationService;
late DashboardController dashboardController;
late AuthController authController;
late AddWordController addWordController;
Logger logger = Logger('main.dart');
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

class _VocabAppState extends ConsumerState<VocabApp> {
  Future<void> initializeApp() async {
    firebaseAnalytics.logAppOpen();
    await authController.initService();
    final localUser = authController.user;
    final user = ref.watch(userNotifierProvider);
    if (localUser.email.isNotEmpty) {
      user.setUser(localUser);
      if (localUser.isLoggedIn) {
        await autoLogin(localUser);
      }
    }
    user.setUser(localUser);

    /// user details not found locally
    /// set default user to local state
  }

  Future<void> autoLogin(UserModel localUser) async {
    final resp = await AuthService.updateLogin(
      data: {
        Constants.USER_LOGGEDIN_COLUMN: true,
      },
      email: localUser.email,
    );
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
            final appThemeController = ref.watch(appThemeProvider);
            final colorScheme = ColorScheme.fromSeed(seedColor: appThemeController.themeSeed);
            return FeatureDiscovery(
              child: MaterialApp(
                title: Constants.APP_TITLE,
                key: appKey,
                scrollBehavior: AppScrollBehavior(),
                navigatorObservers: [_observer],
                debugShowCheckedModeBanner: !kDebugMode,
                darkTheme: ThemeData.dark(
                  useMaterial3: true,
                ).copyWith(
                    textTheme: GoogleFonts.quicksandTextTheme().apply(
                      bodyColor: Colors.white,
                      displayColor: Colors.white,
                    ),
                    scaffoldBackgroundColor: colorScheme.background,
                    colorScheme: ColorScheme.fromSeed(
                        background: Colors.transparent,
                        surface: appThemeController.isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white.withOpacity(0.3),
                        seedColor: appThemeController.themeSeed,
                        brightness: Brightness.dark)),
                theme: ThemeData(
                    useMaterial3: true,
                    textTheme: GoogleFonts.quicksandTextTheme(),
                    scaffoldBackgroundColor: colorScheme.background,
                    colorScheme: ColorScheme.fromSeed(seedColor: appThemeController.themeSeed)),
                routes: {
                  Notifications.route: (context) => Notifications(),
                  WebViewPage.routeName: (context) => WebViewPage(
                        title: Constants.PRIVACY_POLICY_TITLE,
                        url: Constants.PRIVACY_POLICY,
                      ),
                  ReportABug.route: (context) => ReportABug(),
                  AboutVocabhub.route: (context) => AboutVocabhub(),
                  SettingsPage.route: (context) => SettingsPage(),
                  ViewBugReports.route: (context) => ViewBugReports(),
                  WhatsNew.route: (context) => WhatsNew(),
                },
                themeMode: appThemeController.isDark ? ThemeMode.dark : ThemeMode.light,
                home: SplashScreen(),
              ),
            );
          }),
    );
  }
}
