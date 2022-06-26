import 'dart:math';

import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/navbar/navbar.dart';
import 'package:vocabhub/utils/utils.dart';

const appBarDesktopHeight = 128.0;

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

class AdaptiveNavbar extends StatefulWidget {
  const AdaptiveNavbar({Key? key}) : super(key: key);

  @override
  State<AdaptiveNavbar> createState() => _AdaptiveNavbarState();
}

class _AdaptiveNavbarState extends State<AdaptiveNavbar> {
  List<NavbarItem> items = [
    NavbarItem(Icons.dashboard, 'Home', backgroundColor: colors[0]),
    NavbarItem(Icons.search, 'Search', backgroundColor: colors[1]),
    NavbarItem(Icons.explore, 'Explore', backgroundColor: colors[2]),
    NavbarItem(Icons.notifications_active_sharp, 'Notifications',
        backgroundColor: colors[2]),
    NavbarItem(Icons.person, 'Me', backgroundColor: colors[2]),
  ];

  final Map<int, Map<String, Widget>> _routes = {
    0: {
      DashboardMobile.route: DashboardMobile(),
    },
    1: {
      Search.route: Search(),
    },
    2: {ExploreWordsMobile.route: ExploreWordsMobile()},
    3: {Notifications.route: Notifications()},
    4: {UserProfileMobile.route: UserProfileMobile()}
  };

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    SizeUtils.size = MediaQuery.of(context).size;
    return NavbarRouter(
      errorBuilder: (context) {
        return const Center(child: Text('Error 404'));
      },
      onBackButtonPressed: (isExiting) {
        return isExiting;
      },
      isDesktop: !SizeUtils.isMobile(),
      destinationAnimationCurve: Curves.fastOutSlowIn,
      destinationAnimationDuration: 600,
      decoration: NavbarDecoration(
          isExtended: SizeUtils.isDesktop(),
          navbarType: BottomNavigationBarType.shifting),
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
    );
  }
}
