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
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/navigator.dart';
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
    final packageInfo = await PackageInfo.fromPlatform();
    String appVersion = packageInfo.version;
    int appBuildNumber = int.parse(packageInfo.buildNumber);
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(minutes: 1),
      minimumFetchInterval: const Duration(seconds: 1),
    ));
    await remoteConfig.fetchAndActivate();
    final version = await remoteConfig.getString('$VERSION_KEY');
    final buildNumber = await remoteConfig.getInt('$BUILD_NUMBER_KEY');
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
  ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  @override
  void dispose() {
    _selectedIndex.dispose();
    super.dispose();
  }

  double bannerHeight = 0;
  bool hasUpdate = false;

  @override
  Widget build(BuildContext context) {
    SizeUtils.size = MediaQuery.of(context).size;
    List<NavbarItem> items = [
      NavbarItem(Icons.dashboard, 'Dashboard'),
      NavbarItem(Icons.search, 'Search'),
      NavbarItem(Icons.explore, 'Explore'),
    ];

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
      2: {ExploreWords.route: ExploreWords()},
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
      items.add(NavbarItem(Icons.person, 'Me'));
    }
    if (!user.isLoggedIn || hasUpdate) {
      bannerHeight =
          kBottomNavigationBarHeight + MediaQuery.of(context).padding.bottom;
    } else {
      bannerHeight = 0;
    }
    return ValueListenableBuilder<int>(
        valueListenable: _selectedIndex,
        builder: (context, int currentIndex, Widget? child) {
          bannerHeight = kBottomNavigationBarHeight +
              MediaQuery.of(context).padding.bottom;
          return Scaffold(
            resizeToAvoidBottomInset: false,
            floatingActionButton: !user.isLoggedIn ||
                    currentIndex > 1 ||
                    hasUpdate
                ? null
                : Padding(
                    padding: (kBottomNavigationBarHeight * 0.9).bottomPadding,
                    child: OpenContainer<bool>(
                        openBuilder:
                            (BuildContext context, VoidCallback openContainer) {
                          return AddWordForm(
                            isEdit: false,
                          );
                        },
                        tappable: true,
                        closedShape: 22.0.rounded,
                        transitionType: ContainerTransitionType.fadeThrough,
                        closedBuilder:
                            (BuildContext context, VoidCallback openContainer) {
                          return FloatingActionButton.extended(
                              heroTag: "addword",
                              elevation: 3.5,
                              isExtended: true,
                              icon: Icon(Icons.add,
                                  color: Colors.white, size: 28),
                              backgroundColor: VocabTheme.primaryColor,
                              onPressed: null,
                              label: Text(
                                'Add Word',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
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
                  type: NavbarType.notched,
                  onBackButtonPressed: (isExiting) {
                    if (isExiting) {
                      newTime = DateTime.now();
                      int difference =
                          newTime.difference(oldTime).inMilliseconds;
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
                  destinationAnimationDuration: 600,
                  onChanged: (x) {
                    /// Simulate DragGesture on pageView
                    if (EXPLORE_INDEX == x && !animatePageOnce) {
                      if (pageController.hasClients && user.isLoggedIn) {
                        Future.delayed(Duration(seconds: 3), () {
                          if (NavbarNotifier.currentIndex == EXPLORE_INDEX) {
                            pageController.animateTo(200,
                                duration: Duration(milliseconds: 600),
                                curve: Curves.easeIn);
                            animatePageOnce = true;
                          }
                        });
                      }
                    }
                    _selectedIndex.value = x;
                  },
                  decoration: NavbarDecoration(
                      backgroundColor: VocabTheme.surfaceGreen,
                      isExtended: SizeUtils.isExtendedDesktop,
                      // showUnselectedLabels: false,
                      selectedIconTheme: IconThemeData(
                          size: 24, color: VocabTheme.primaryColor),
                      selectedLabelTextStyle: TextStyle(fontSize: 12),
                      unselectedLabelTextStyle:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      navbarType: BottomNavigationBarType.fixed),
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
                if (hasUpdate || !user.isLoggedIn)
                  AnimatedPositioned(
                      duration: Duration(milliseconds: 300),
                      bottom: bannerHeight,
                      left: 0,
                      right: 0,
                      child: VocabBanner(
                        description: hasUpdate
                            ? 'New update available'
                            : 'Sign in for better experience',
                        actions: [
                          !hasUpdate
                              ? SizedBox.shrink()
                              : TextButton(
                                  onPressed: () {
                                    launchUrl(Uri.parse(PLAY_STORE_URL),
                                        mode: LaunchMode.externalApplication);
                                  },
                                  child: Text('Update',
                                      style: TextStyle(
                                        color: VocabTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      )),
                                ),
                          user.isLoggedIn
                              ? SizedBox.shrink()
                              : TextButton(
                                  onPressed: () async {
                                    await Navigate()
                                        .pushAndPopAll(context, AppSignIn());
                                  },
                                  child: Text('Sign In',
                                      style: TextStyle(
                                        color: VocabTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      )),
                                ),
                        ],
                      ))
              ],
            ),
          );
        });
  }
}

class VocabBanner extends StatelessWidget {
  final String description;
  final List<Widget> actions;

  const VocabBanner(
      {Key? key, required this.description, required this.actions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.grey.shade800,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$description',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          16.0.hSpacer(),
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
