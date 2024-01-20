import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
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
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/whats_new.dart';
import 'package:vocabhub/widgets/widgets.dart';

import 'pages/notifications/notifications.dart';

const appBarDesktopHeight = 128.0;

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
    Future.wait([
      isUpdateAvailable(),
    ]);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      if (!user!.isLoggedIn) {
        showSnackBar("Sign in for better experience", action: 'Sign In', persist: true,
            onActionPressed: () async {
          NavbarNotifier.clear();
          await Navigate.pushAndPopAll(context, AppSignIn());
        });
      }
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
          bottom: kNavbarHeight * 1.2,
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
    final selectedColor = colorScheme.surfaceTint;
    List<NavbarItem> items = [
      NavbarItem(Icons.dashboard_outlined, 'Dashboard',
          selectedIcon: Icon(Icons.dashboard, color: selectedColor, size: 26)),
      NavbarItem(Icons.search_outlined, 'Search',
          selectedIcon: Icon(Icons.search, color: selectedColor, size: 26)),
      NavbarItem(Icons.explore_outlined, 'Explore',
          selectedIcon: Icon(Icons.explore, color: selectedColor, size: 26)),
    ];
    user = ref.read(userNotifierProvider).value!;
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
            padding: (kNavbarHeight * 1.2).bottomPadding,
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
              height: kNavbarHeight * 1.2,
              backgroundColor: SizeUtils.isDesktop
                  ? colorScheme.surfaceVariant
                  : colorScheme.scrim.withOpacity(0.2),
              margin: EdgeInsets.zero,
              showSelectedLabels: false,
              borderRadius: BorderRadius.zero,
              // backgroundColor: (colorScheme.surfaceVariant.withOpacity(0.4)),
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
  }
}

class VocabBanner extends StatelessWidget {
  final String description;
  final List<Widget> actions;

  const VocabBanner({Key? key, required this.description, required this.actions}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      color: Colors.grey.shade800,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            '$description',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          Spacer(),
          for (int i = 0; i < actions.length; i++) actions[i]
        ],
      ),
    );
  }
}

class DesktopHome extends StatefulWidget {
  const DesktopHome({Key? key}) : super(key: key);

  @override
  State<DesktopHome> createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: Colors.red,
              child: Center(
                child: Text('Desktop Home'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
