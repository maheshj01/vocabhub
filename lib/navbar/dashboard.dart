import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/navbar/notifications.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
        ),
        actions: [
          IconButton(
              onPressed: () {
                navigate(context, Notifications.route, isRootNavigator: false);
              },
              icon: Icon(
                Icons.notifications_on,
                color: VocabTheme.primaryColor,
              )),
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
      appBar: AppBar(),
      body: Center(
        child: Text('Dashboard Desktop'),
      ),
    );
  }
}
