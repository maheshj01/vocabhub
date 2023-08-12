import 'dart:async';

import 'package:animations/animations.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/controller/app_controller.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/navbar/navbar.dart';
import 'package:vocabhub/navbar/profile/about.dart';
import 'package:vocabhub/navbar/profile/settings.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/utils/utils.dart';
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
      final packageInfo = await PackageInfo.fromPlatform();
      final String appVersion = packageInfo.version;
      final int appBuildNumber = int.parse(packageInfo.buildNumber);
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(seconds: 1),
      ));
      await remoteConfig.fetchAndActivate();
      final version = remoteConfig.getString('${Constants.VERSION_KEY}');
      final buildNumber = remoteConfig.getInt('${Constants.BUILD_NUMBER_KEY}');
      if (appVersion != version || buildNumber > appBuildNumber) {
        showSnackBar("New Update Available", action: 'Update', persist: true, onActionPressed: () {
          analytics.logAppUpdate(settingsController.version!);
          launchUrl(Uri.parse(Constants.PLAY_STORE_URL), mode: LaunchMode.externalApplication);
        });
      }
    } catch (_) {
      setState(() {});
    }
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
    AppController state = ref.read(appNotifier.notifier).state;
    ref.watch(appNotifier.notifier).state = state.copyWith(showFAB: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      NavbarNotifier.showSnackBar(context, message,
          actionLabel: action,
          onActionPressed: onActionPressed,
          duration: persist ? Duration(days: 1) : Duration(seconds: 3), onClosed: () {
        if (mounted) {
          ref.watch(appNotifier.notifier).state = state.copyWith(showFAB: true);
        }
      });
    });
  }

  List<NavbarItem> items = [
    NavbarItem(Icons.dashboard, 'Dashboard'),
    NavbarItem(Icons.search, 'Search'),
    NavbarItem(Icons.explore, 'Explore'),
  ];
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
        AddWordForm.route: AddWordForm(),
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

    user = ref.watch(userNotifierProvider);
    if (user!.isLoggedIn) {
      _routes.addAll({
        3: {
          UserProfile.route: UserProfile(),
          SettingsPage.route: SettingsPage(),
          AboutVocabhub.route: AboutVocabhub(),
        }
      });
      if (items.length < 4) {
        items.add(NavbarItem(Icons.person, 'Me'));
      }
    } else {
      if (items.length > 3) {
        items.removeLast();
      }
    }
    final colorScheme = Theme.of(context).colorScheme;
    final appController = ref.watch(appNotifier);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: !appController.showFAB || (appController.index > 1 || !user!.isLoggedIn)
          ? null
          : Padding(
              padding: (kM3NavbarHeight * 0.9).bottomPadding,
              child: OpenContainer<bool>(
                  openBuilder: (BuildContext context, VoidCallback openContainer) {
                    return AddWordForm(
                      isEdit: false,
                    );
                  },
                  tappable: true,
                  closedColor: colorScheme.primaryContainer,
                  closedShape: 22.0.rounded,
                  transitionType: ContainerTransitionType.fadeThrough,
                  closedBuilder: (BuildContext context, VoidCallback openContainer) {
                    return FloatingActionButton.extended(
                        backgroundColor: colorScheme.primaryContainer,
                        heroTag: "addword${DateTime.now().millisecondsSinceEpoch}",
                        elevation: 3.5,
                        isExtended: true,
                        icon: Icon(Icons.add, color: colorScheme.onPrimaryContainer, size: 28),
                        onPressed: null,
                        label: Text(
                          'Add Word',
                          style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                          ),
                        ));
                  }),
            ),
      body: Stack(
        children: [
          NavbarRouter(
            errorBuilder: (context) {
              return const Center(child: Text('Error 404'));
            },
            type: NavbarType.material3,
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
            isDesktop: !SizeUtils.isMobile,
            destinationAnimationCurve: Curves.fastOutSlowIn,
            destinationAnimationDuration: 0,
            onCurrentTabClicked: () {
              exploreController.scrollToIndex = 0;
            },
            onChanged: (x) async {
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
              ref.read(appNotifier.notifier).state = ref.watch(appNotifier).copyWith(index: x);
            },
            decoration: M3NavbarDecoration(),
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
