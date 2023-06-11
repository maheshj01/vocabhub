import 'package:animations/animations.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/navbar/navbar.dart';
import 'package:vocabhub/navbar/profile/about.dart';
import 'package:vocabhub/navbar/profile/settings.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/utils/utils.dart';

import 'pages/notifications/notifications.dart';

const appBarDesktopHeight = 128.0;

class AdaptiveLayout extends StatefulWidget {
  const AdaptiveLayout({Key? key}) : super(key: key);

  @override
  State<AdaptiveLayout> createState() => _AdaptiveLayoutState();
}

class _AdaptiveLayoutState extends State<AdaptiveLayout> {
  @override
  void initState() {
    super.initState();
    getWords();
    isUpdateAvailable();
  }

  Future<void> getWords() async {
    final words = await VocabStoreService.getAllWords();
    if (words.isNotEmpty) {
      AppStateWidget.of(context).setWords(words);
      // updateWord(words);
    }
  }

  Future<void> isUpdateAvailable() async {
    // TODO: check only once on app launch not on every page load
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
      hasUpdate = true;
    } else {
      hasUpdate = false;
    }
    setState(() {});
  }

  late AppState state;

  bool animatePageOnce = false;
  DateTime oldTime = DateTime.now();
  DateTime newTime = DateTime.now();
  ValueNotifier<int> _selectedIndexNotifier = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selectedIndexNotifier.dispose();
    super.dispose();
  }

  double bannerHeight = 0;
  bool hasUpdate = false;
  List<NavbarItem> items = [
    NavbarItem(Icons.dashboard, 'Dashboard'),
    NavbarItem(Icons.search, 'Search'),
    NavbarItem(Icons.explore, 'Explore'),
  ];
  bool showBanner = true;
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
            setState(() {
              showBanner = true;
            });
          },
        )
      },
    };

    final user = AppStateScope.of(context).user;
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
    if (showBanner) {
      if (!user.isLoggedIn || hasUpdate) {
        bannerHeight = kNotchedNavbarHeight;
      } else {
        bannerHeight = 0;
        showBanner = false;
      }
    }
    final colorScheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<int>(
        valueListenable: _selectedIndexNotifier,
        builder: (context, int currentIndex, Widget? child) {
          bannerHeight = kNotchedNavbarHeight;
          return Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButton: showBanner || currentIndex > 1 || !user.isLoggedIn
                ? null
                : Padding(
                    padding: (bannerHeight * 0.9).bottomPadding,
                    child: OpenContainer<bool>(
                        openBuilder: (BuildContext context, VoidCallback openContainer) {
                          return AddWordForm(
                            isEdit: false,
                          );
                        },
                        tappable: true,
                        closedColor: colorScheme.primaryContainer ,
                        closedShape: 22.0.rounded,
                        transitionType: ContainerTransitionType.fadeThrough,
                        closedBuilder: (BuildContext context, VoidCallback openContainer) {
                          return FloatingActionButton.extended(
                              backgroundColor: colorScheme.primaryContainer,
                              heroTag: "addword",
                              elevation: 3.5,
                              isExtended: true,
                              icon:
                                  Icon(Icons.add, color: colorScheme.onPrimaryContainer, size: 28),
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
                        showToast('Press back button to exit');
                        return false;
                      }
                    } else {
                      return isExiting;
                    }
                  },
                  isDesktop: !SizeUtils.isMobile,
                  destinationAnimationCurve: Curves.fastOutSlowIn,
                  destinationAnimationDuration: 0,
                  onChanged: (x) {
                    /// Simulate DragGesture on pageView
                    if (EXPLORE_INDEX == x && !animatePageOnce) {
                      if (pageController.hasClients && user.isLoggedIn) {
                        Future.delayed(Duration(seconds: 3), () {
                          if (NavbarNotifier.currentIndex == EXPLORE_INDEX) {
                            pageController.animateTo(200,
                                duration: Duration(milliseconds: 600), curve: Curves.easeIn);
                            animatePageOnce = true;
                          }
                        });
                      }
                    }
                    _selectedIndexNotifier.value = x;
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
                if (!user.isLoggedIn && showBanner)
                  AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      bottom: bannerHeight,
                      left: 0,
                      right: 0,
                      child: VocabBanner(
                        description: 'Sign in for better experience',
                        actions: [
                          TextButton(
                            onPressed: () async {
                              NavbarNotifier.clear();
                              await Navigate.pushAndPopAll(context, AppSignIn());
                            },
                            child: Text('Sign In',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                )),
                          ),
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  showBanner = false;
                                });
                              },
                              icon: Icon(
                                Icons.close,
                                color: colorScheme.primary,
                                size: 24,
                              ))
                        ],
                      )),
                if (showBanner && hasUpdate)
                  AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      bottom: bannerHeight,
                      left: 0,
                      right: 0,
                      child: VocabBanner(
                        description: 'New update available',
                        actions: [
                          TextButton(
                            onPressed: () {
                              launchUrl(Uri.parse(Constants.PLAY_STORE_URL),
                                  mode: LaunchMode.externalApplication);
                            },
                            child: Text('Update',
                                style: TextStyle(
                                  color: colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                )),
                          ),
                          IconButton(
                              onPressed: () {
                                /// if user is not loggedin and there is a update
                                /// hiding update banner should still show sign in banner
                                if (!user.isLoggedIn) {
                                  setState(() {
                                    hasUpdate = false;
                                  });
                                } else {
                                  setState(() {
                                    showBanner = false;
                                  });
                                }
                              },
                              icon: Icon(
                                Icons.close,
                                color: colorScheme.primary,
                                size: 24,
                              ))
                        ],
                      )),
              ],
            ),
          );
        });
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
