import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/navbar/notifications.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/widgets/responsive.dart';

class Dashboard extends StatelessWidget {
  static String route = '/';
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
        child: ResponsiveBuilder(
      desktopBuilder: (context) => DashboardDesktop(),
      mobileBuilder: (context) => DashboardMobile(),
    ));
  }
}

class DashboardMobile extends StatelessWidget {
  static String route = '/';
  const DashboardMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).user;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
        ),
        actions: [
          user!.isLoggedIn
              ? IconButton(
                  onPressed: () {
                    navigate(context, Notifications.route,
                        isRootNavigator: false);
                  },
                  icon: Icon(
                    Icons.notifications_on,
                    color: VocabTheme.primaryColor,
                  ))
              : SizedBox(),
        ],
      ),
      body: Center(
        child: Text('Dashboard Home'),
      ),
    );
  }
}

class DashboardDesktop extends StatelessWidget {
  static String route = '/';
  const DashboardDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Center(
                  child: Text('Dashboard Desktop'),
                ),
              ],
            ),
          ),
          SizedBox(
              height: SizeUtils.size.height * 0.5,
              width: 400,
              child: Column(
                children: [
                  Expanded(child: Notifications()),
                ],
              ))
        ],
      ),
    );
  }
}
