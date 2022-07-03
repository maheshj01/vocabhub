import 'package:flutter/material.dart';
import 'package:vocabhub/widgets/responsive.dart';

class Dashboard extends StatelessWidget {
  static String route = '/';
  const Dashboard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ResponsiveBuilder(
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
      appBar: AppBar(),
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
