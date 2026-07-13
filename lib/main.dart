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
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vocabhub/controller/app_controller.dart';
import 'package:vocabhub/controller/auth_controller.dart';
import 'package:vocabhub/controller/collections_controller.dart';
import 'package:vocabhub/controller/controllers.dart';
import 'package:vocabhub/controller/word_tracking_controller.dart';
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
import 'package:vocabhub/utils/app_utils.dart';
import 'package:vocabhub/utils/firebase_options.dart';
import 'package:vocabhub/utils/logger.dart';
import 'package:vocabhub/widgets/whats_new.dart';

import 'constants/constants.dart';

/// Exposes the [AuthController] session hub to the widget tree.
final authControllerProvider = ChangeNotifierProvider<AuthController>((ref) => authController);

/// The current signed-in user. Rebuilds whenever the session changes.
final userNotifierProvider = Provider<UserModel>((ref) => ref.watch(authControllerProvider).user);

final dashBoardNotifier = Provider<DashboardController>((ref) => DashboardController());
final appProvider = NotifierProvider<AppNotifier, AppController>(AppNotifier.new);

final appThemeProvider =
    StateNotifierProvider<VocabThemeNotifier, VocabThemeController>(VocabThemeNotifier.new);

final collectionNotifier = ChangeNotifierProvider((ref) => CollectionsNotifier());

/// Local-first word tracking (bookmarks + mastered). Guests are tracked
/// on-device; members are backed by Supabase.
final wordTrackingProvider =
    ChangeNotifierProvider<WordTrackingController>((ref) => wordTrackingController);

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final themeUtilityProvider = Provider<ThemeUtility>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return ThemeUtility(sharedPreferences: sharedPrefs);
});

final appUtilityProvider = Provider<AppUtility>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return AppUtility(sharedPreferences: sharedPrefs);
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
  if (!isIntegrationTest) pushNotificationService.initService();
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  addWordController.initService();
  wordTrackingController = WordTrackingController();
  await wordTrackingController.initService();
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
late WordTrackingController wordTrackingController;
Logger logger = Logger('main.dart');

/// When false, looping "ambient" animations (e.g. the splash aurora/shimmer)
/// are suppressed. Integration tests set this to false so `pumpAndSettle()` can
/// settle instead of spinning forever on an endless animation.
bool ambientAnimationsEnabled = true;

/// Set by integration tests to skip plugin-heavy startup that isn't backed in
/// the test environment (e.g. push-notification permission requests).
bool isIntegrationTest = false;
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

    /// Re-validate the cached session against Supabase (no-op if signed out).
    await authController.restoreSession();

    /// Load word tracking for the resolved session (local for guests).
    await wordTrackingController.load(authController.user);
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
                    scaffoldBackgroundColor: colorScheme.surface,
                    colorScheme: ColorScheme.fromSeed(
                        surface: appThemeController.isDark
                            ? Colors.black.withOpacity(0.3)
                            : Colors.white.withOpacity(0.3),
                        seedColor: appThemeController.themeSeed,
                        brightness: Brightness.dark)),
                theme: ThemeData(
                    useMaterial3: true,
                    textTheme: GoogleFonts.quicksandTextTheme(),
                    scaffoldBackgroundColor: colorScheme.surface,
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
