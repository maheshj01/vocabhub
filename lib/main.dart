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
import 'package:supabase/supabase.dart' as sp;
import 'package:vocabhub/controller/app_controller.dart';
import 'package:vocabhub/controller/controllers.dart';
import 'package:vocabhub/models/collection.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/navbar/profile/about.dart';
import 'package:vocabhub/navbar/profile/report.dart';
import 'package:vocabhub/navbar/profile/settings.dart';
import 'package:vocabhub/navbar/profile/webview.dart';
import 'package:vocabhub/pages/notifications/notifications.dart';
import 'package:vocabhub/pages/splashscreen.dart';
import 'package:vocabhub/services/dashboardstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/themes/theme_utils.dart';
import 'package:vocabhub/themes/vocabtheme_controller.dart';
import 'package:vocabhub/utils/app_utils.dart';
import 'package:vocabhub/utils/collection_notifier.dart';
import 'package:vocabhub/utils/dashboard_notifier.dart';
import 'package:vocabhub/utils/firebase_options.dart';
import 'package:vocabhub/utils/logger.dart';
import 'package:vocabhub/utils/user_notifier.dart';
import 'package:vocabhub/widgets/whats_new.dart';

import 'constants/constants.dart';

// final userControllerProvider = Provider<UserController>((ref) {
//   final sharedPrefs = ref.watch(sharedPreferencesProvider);
//   final userService = UserService();
//   return UserController(sharedPrefs, userService);
// });

final appProvider = StateNotifierProvider<AppNotifier, AppController>(AppNotifier.new);

final appThemeProvider =
    StateNotifierProvider<VocabThemeNotifier, VocabThemeController>(VocabThemeNotifier.new);

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final supabaseClientProvider = Provider<sp.SupabaseClient>((ref) {
  final sp.SupabaseClient _supabase =
      sp.SupabaseClient("${Constants.SUPABASE_URL}", "${Constants.SUPABASE_API_KEY}}");
  return _supabase;
});

final themeUtilityProvider = Provider<ThemeUtility>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return ThemeUtility(sharedPreferences: sharedPrefs);
});

final appUtilityProvider = Provider<AppUtility>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return AppUtility(sharedPreferences: sharedPrefs);
});

final collectionNotifierProvider =
    StateNotifierProvider<CollectionStateNotifier, AsyncValue<List<VHCollection>>>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  return CollectionStateNotifier(sharedPrefs, ref);
});

final dashboardNotifierProvider =
    StateNotifierProvider<DashboardStateNotifier, AsyncValue<DashboardState>>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  final supabaseClient = ref.watch(supabaseClientProvider);
  final vocabStoreService = new VocabStoreService(supabaseClient);
  return DashboardStateNotifier(sharedPrefs, vocabStoreService, ref);
});

final userNotifierProvider = StateNotifierProvider<UserStateNotifier, AsyncValue<UserModel>>((ref) {
  final sharedPrefs = ref.watch(sharedPreferencesProvider);
  final supabaseClient = ref.watch(supabaseClientProvider);
  final userService = new UserService(supabaseClient);
  return UserStateNotifier(sharedPrefs, userService, ref);
});

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final sharedPreferences = await SharedPreferences.getInstance();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  firebaseAnalytics = FirebaseAnalytics.instance;
  usePathUrlStrategy();
  settingsController = SettingsController();
  exploreController = ExploreController();
  addWordController = AddWordController();
  searchController = SearchFieldController(controller: TextEditingController());
  settingsController.loadSettings();
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      final localUser = ref.watch(userNotifierProvider);
      localUser.whenData((user) async {
        if (user.email.isNotEmpty) {
          if (user.isLoggedIn) {
            await autoLogin(user);
          }
        }
      });
    });
  }

  Future<void> autoLogin(UserModel localUser) async {
    try {
      final authService = ref.watch(authServiceProvider);
      final resp = await authService.updateLogin(
        data: {
          Constants.USER_LOGGEDIN_COLUMN: true,
        },
        email: localUser.email,
      );
      final userProvider = ref.watch(userNotifierProvider.notifier);

      /// if login success, update local user details
      if (resp.status == Status.success) {
        final user = await userProvider.findUserByEmail(email: localUser.email);
        userProvider.setUser(user);
      } else {
        userProvider.setUser(localUser);
      }
    } catch (e) {
      logger.e(e.toString());
    }
  }

  FirebaseAnalyticsObserver _observer = FirebaseAnalyticsObserver(analytics: firebaseAnalytics);
  @override
  void dispose() {
    searchController.disposeService();
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
    return AnimatedBuilder(
        animation: settingsController,
        builder: (BuildContext context, Widget? child) {
          final appThemeController = ref.watch(appThemeProvider);
          final colorScheme = ColorScheme.fromSeed(seedColor: appThemeController.themeSeed);
          //  calling this here will initialize the dashboard state
          // and fetch words for words animation
          // final user = ref.watch(userNotifierProvider);̉
          // final dashboardState = ref.watch(dashboardNotifierProvider);

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
        });
  }
}
