import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:restart_app/restart_app.dart';
import 'package:shorebird_code_push/shorebird_code_push.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/version.dart';
import 'package:vocabhub/navbar/navbar.dart';
import 'package:vocabhub/navbar/profile/edit.dart';
import 'package:vocabhub/navbar/search/search_view.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/whats_new.dart';
import 'package:vocabhub/widgets/widgets.dart';

import 'pages/notifications/notifications.dart';

const appBarDesktopHeight = 128.0;
const navbarBottomPaddingFactor = 1.5;

class AdaptiveLayout extends ConsumerStatefulWidget {
  const AdaptiveLayout({Key? key}) : super(key: key);

  @override
  _AdaptiveLayoutState createState() => _AdaptiveLayoutState();
}

class _AdaptiveLayoutState extends ConsumerState<AdaptiveLayout> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 5), askForRating);
    // Future.wait([
    //   isUpdateAvailable(),
    // ]);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkForShorebirdPatch();
    });
  }

  Future<void> askForRating() async {
    if (!settingsController.hasRatedOnPlaystore && !kIsWeb) {
      final lastRatedAskDate = await settingsController.getLastRatedShown();
      final now = DateTime.now();
      final diff = now.difference(lastRatedAskDate).inDays;
      if (diff > Constants.ratingAskInterval) {
        settingsController.lastRatedDate = DateTime.now();
        showRatingsBottomSheet(context);
      }
    }
  }

  Future<void> isUpdateAvailable() async {
    // TODO: check only once on app launch not on every page load
    if (SizeUtils.isDesktop) {
      return;
    }
    try {
      final appController = ref.read(appProvider);
      final appNotifier = ref.read(appProvider.notifier);
      final packageInfo = await PackageInfo.fromPlatform();
      final String appVersion = packageInfo.version;
      final int appBuildNumber = int.parse(packageInfo.buildNumber);

      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(seconds: 1),
      ));
      await remoteConfig.fetchAndActivate();
      final remoteVersion = remoteConfig.getString('${Constants.VERSION_KEY}');
      final remoteBuildNumber = remoteConfig.getInt('${Constants.BUILD_NUMBER_KEY}');
      final storedVersion = appController.version;
      final oldVersion = storedVersion!.oldVersion.version;
      final oldBuildNumber = storedVersion.oldVersion.buildNumber;
      final current = Version(
        version: packageInfo.version,
        buildNumber: int.parse(packageInfo.buildNumber),
        date: DateTime.now(),
      );
      final app_version = appController.version!.copyWith(
        version: current,
      );
      if (appVersion != remoteVersion || remoteBuildNumber > appBuildNumber) {
        appNotifier.copyWith(appController.copyWith(
            showFAB: false, extended: true, hasUpdate: true, version: app_version));
        showSnackBar("New Update Available", action: 'Update', persist: true, onActionPressed: () {
          analytics.logAppUpdate(settingsController.version!);
          launchUrl(Uri.parse(Constants.PLAY_STORE_URL), mode: LaunchMode.externalApplication);
        });
      } else {
        if (oldVersion != appVersion || oldBuildNumber < appBuildNumber) {
          Navigate.push(
            context,
            WhatsNew(
              showFullChangelog: false,
            ),
            transitionType: TransitionType.btt,
          );
          //  This is set only once when the user opens the app once after Update
          appNotifier.setVersion(app_version);
        }
      }
    } catch (_) {
      setState(() {});
    }
  }

  // --- Shorebird over-the-air (Dart-only) patches -------------------------
  final ShorebirdUpdater _shorebirdUpdater = ShorebirdUpdater();
  static const Duration _patchDownloadDuration = Duration(seconds: 15);
  bool _restartPromptShown = false;
  bool _patchFailed = false;

  static const MethodChannel _restartChannel = MethodChannel('com.vocabhub.app/restart');
  static const String _restartMethod = 'restart';

  /// Relaunches the app so a downloaded Shorebird patch takes effect. Android
  /// uses a native channel for a true process restart; other platforms fall
  /// back to the restart_app plugin.
  Future<void> restartApp() async {
    try {
      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        await _restartChannel.invokeMethod(_restartMethod);
      } else {
        await Restart.restartApp(
          notificationTitle: 'Restarting Vocabhub',
          notificationBody: 'Tap to reopen the app.',
        );
      }
    } catch (e) {
      debugPrint('Failed to restart app: $e');
    }
  }

  /// Checks for a Shorebird patch and surfaces it. No-op on web / non-Shorebird
  /// builds ([checkForUpdate] returns [UpdateStatus.unavailable] there), and any
  /// failure is swallowed so a bad check never disrupts the app.
  Future<void> _checkForShorebirdPatch() async {
    if (kIsWeb) return;
    try {
      final status = await _shorebirdUpdater.checkForUpdate();
      if (!mounted) return;
      if (status == UpdateStatus.outdated) {
        _showPatchAvailableSnackBar();
      } else if (status == UpdateStatus.restartRequired) {
        _showRestartSnackBar();
      }
    } catch (_) {
      // ignore: a failed patch check is non-fatal.
    }
  }

  /// Floating snack that clears the bottom navbar on mobile.
  SnackBar _patchSnack({
    required Widget content,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 500),
  }) {
    return SnackBar(
      content: content,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
          left: 10, right: 10, bottom: SizeUtils.isMobile ? kNavbarHeight * 1.2 : 16),
      duration: duration,
      action: action,
    );
  }

  Widget _downloadProgress() {
    return TweenAnimationBuilder<double>(
      duration: _patchDownloadDuration,
      tween: Tween(begin: 0.0, end: 1.0),
      onEnd: () {
        if (_patchFailed || !mounted) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        _showRestartSnackBar();
      },
      builder: (context, value, child) {
        return Row(
          children: [
            SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(value: value, strokeWidth: 2)),
            const SizedBox(width: 12),
            const Flexible(child: Text('Downloading update…')),
          ],
        );
      },
    );
  }

  void _showPatchAvailableSnackBar() {
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(_patchSnack(
      content: const Text('A new update is available.'),
      action: SnackBarAction(
        label: 'Update',
        onPressed: () async {
          messenger.hideCurrentSnackBar();
          // Show download progress while the patch downloads.
          messenger.showSnackBar(_patchSnack(
            content: _downloadProgress(),
            duration: _patchDownloadDuration,
            action: SnackBarAction(label: 'Hide', onPressed: messenger.hideCurrentSnackBar),
          ));
          try {
            await _shorebirdUpdater.update();
            // Prompt a restart even if the progress snack was dismissed early.
            Future.delayed(_patchDownloadDuration, () {
              if (mounted) _showRestartSnackBar();
            });
          } on UpdateException catch (error) {
            _patchFailed = true;
            if (!mounted) return;
            messenger.hideCurrentSnackBar();
            messenger.showSnackBar(_patchSnack(
              content: Text(error.message),
              action: SnackBarAction(label: 'Close', onPressed: messenger.hideCurrentSnackBar),
            ));
          }
        },
      ),
    ));
  }

  void _showRestartSnackBar() {
    if (_restartPromptShown || !mounted) return;
    _restartPromptShown = true;
    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(_patchSnack(
      content: const Text('Update ready — restart to apply.'),
      action: SnackBarAction(
        label: 'Restart',
        onPressed: restartApp,
      ),
    ));
  }

  late AppState state;

  DateTime oldTime = DateTime.now();
  DateTime newTime = DateTime.now();

  @override
  void dispose() {
    super.dispose();
  }

  void showSnackBar(String message,
      {String? action, bool persist = false, Function? onActionPressed}) {
    ref.read(appProvider.notifier).setShowFAB(false);
    final appController = ref.watch(appProvider);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavbarNotifier.showSnackBar(context, message,
          actionLabel: action,
          // Clear the floating bottom navbar on mobile; sit near the bottom on
          // the desktop side-rail layout.
          bottom: SizeUtils.isMobile ? kNavbarHeight * 1.2 : 24,
          onActionPressed: onActionPressed,
          duration: persist ? Duration(days: 1) : Duration(seconds: 3), onClosed: () {
        if (mounted) {
          ref.read(appProvider.notifier).copyWith(appController.copyWith(hasUpdate: false));
        }
      });
    });
  }

  final analytics = Analytics.instance;
  UserModel? user;
  @override
  Widget build(BuildContext context) {
    SizeUtils.size = MediaQuery.of(context).size;
    final Map<int, Map<String, Widget>> _routes = {
      0: {
        Dashboard.route: Dashboard(),
        Notifications.route: Notifications(),
      },
      1: {
        Search.route: Search(),
        AddWord.route: AddWord(),
        SearchView.route: SearchView(),
      },
      2: {
        ExploreWords.route: ExploreWords(
          onScrollThresholdReached: () {
            if (!user!.isLoggedIn) {
              showSnackBar("Sign in for better experience", action: 'Sign In', persist: true,
                  onActionPressed: () async {
                NavbarNotifier.clear();
                await Navigate.pushAndPopAll(context, AppSignIn());
              });
            }
          },
        )
      },
    };
    final colorScheme = Theme.of(context).colorScheme;
    final selectedColor = colorScheme.primary;
    List<NavbarItem> items = [
      NavbarItem(Icons.dashboard_outlined, 'Dashboard',
          selectedIcon: Icon(Icons.dashboard, color: selectedColor, size: 26)),
      NavbarItem(Icons.search_outlined, 'Search',
          selectedIcon: Icon(Icons.search, color: selectedColor, size: 26)),
      NavbarItem(Icons.explore_outlined, 'Explore',
          selectedIcon: Icon(Icons.explore, color: selectedColor, size: 26)),
    ];
    user = ref.watch(userNotifierProvider);
    if (user!.isLoggedIn) {
      _routes.addAll({
        3: {
          UserProfileNavigator.route: UserProfileNavigator(),
          EditProfile.route: EditProfile(),
        }
      });
      if (items.length < 4) {
        items.add(NavbarItem(Icons.person_outlined, 'Me',
            selectedIcon: Icon(Icons.person, color: selectedColor, size: 26)));
      }
    } else {
      if (items.length > 3) {
        items.removeLast();
      }
    }
    final appController = ref.watch(appProvider);
    final label = Text(
      'Add Word',
      style: TextStyle(
        fontSize: 14,
        color: colorScheme.onPrimaryContainer,
        fontWeight: FontWeight.w600,
      ),
    );

    Widget _buildFab() {
      final icon = Icon(Icons.add, color: colorScheme.onPrimaryContainer, size: 28);
      if (appController.showFAB || (appController.index < 2 && user!.isLoggedIn)) {
        return Padding(
            // The floating bottom navbar only exists on mobile; on the desktop
            // side-rail the FAB should sit at the normal bottom-right.
            padding: SizeUtils.isMobile ? (kNavbarHeight * 1.2).bottomPadding : EdgeInsets.zero,
            child: FloatingActionButton.extended(
                backgroundColor: colorScheme.primaryContainer,
                heroTag: "addword${DateTime.now().millisecondsSinceEpoch}",
                elevation: 3.5,
                isExtended: appController.extended,
                icon: icon,
                onPressed: () {
                  Navigate.push(
                      context,
                      AddWord(
                        isEdit: false,
                      ));
                },
                label: label));
      } else {
        return SizedBox.shrink();
      }
    }

    return AnimatedBuilder(
        animation: dashboardController,
        builder: (context, child) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButton: appController.hasUpdate ? null : _buildFab(),
            body: Stack(
              children: [
                NavbarRouter(
                  errorBuilder: (context) {
                    return const Center(child: Text('Error 404'));
                  },
                  type: NavbarType.floating,
                  onBackButtonPressed: (isExiting) {
                    if (isExiting) {
                      newTime = DateTime.now();
                      final int difference = newTime.difference(oldTime).inMilliseconds;
                      oldTime = newTime;
                      if (difference < 1000) {
                        hideToast();
                        return isExiting;
                      } else {
                        showToast('Press again to exit');
                        return false;
                      }
                    } else {
                      return isExiting;
                    }
                  },
                  initialIndex: 0,
                  shouldPopToBaseRoute: true,
                  isDesktop: !SizeUtils.isMobile,
                  // destinationAnimationCurve: Curves.fastOutSlowIn,
                  destinationAnimationDuration: SizeUtils.isDesktop ? 0 : 0,
                  onCurrentTabClicked: () {
                    exploreController.scrollToIndex = 0;
                  },
                  onChanged: (x) async {
                    ref.read(appProvider.notifier).copyWith(appController.copyWith(
                        index: x, showFAB: x < 2 && user!.isLoggedIn, extended: true));

                    /// Simulate DragGesture on pageView
                    final pageController = exploreController.pageController;
                    if (EXPLORE_INDEX == x && SizeUtils.isMobile) {
                      if (pageController.hasClients) {
                        if (exploreController.shouldShowScrollAnimation) {
                          Future.delayed(Duration(seconds: 3), () async {
                            if (NavbarNotifier.currentIndex == EXPLORE_INDEX) {
                              exploreController.showScrollAnimation();
                            }
                          });
                        }
                      }
                    }
                  },
                  decoration: FloatingNavbarDecoration(
                    height: kNavbarHeight * navbarBottomPaddingFactor,
                    backgroundColor: SizeUtils.isDesktop
                        ? colorScheme.surfaceContainerHighest
                        : colorScheme.secondaryContainer,
                    margin: EdgeInsets.zero,
                    // Show labels on the desktop/tablet side-rail (it has room);
                    // keep the mobile floating bar icon-only.
                    showSelectedLabels: !SizeUtils.isMobile,
                    borderRadius: BorderRadius.zero,
                    // backgroundColor: (colorScheme.surfaceContainerHighest.withOpacity(0.4)),
                  ),
                  destinations: [
                    for (int i = 0; i < items.length; i++)
                      DestinationRouter(
                        navbarItem: items[i],
                        destinations: [
                          for (int j = 0; j < _routes[i]!.keys.length; j++)
                            Destination(
                              route: _routes[i]!.keys.elementAt(j),
                              widget: _routes[i]!.values.elementAt(j),
                            ),
                        ],
                        initialRoute: _routes[i]!.keys.elementAt(0),
                      ),
                  ],
                ),
              ],
            ),
          );
        });
  }
}
