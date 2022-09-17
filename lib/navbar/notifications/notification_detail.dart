import 'package:flutter/material.dart';
import 'package:vocabhub/widgets/responsive.dart';

class NotificationDetail extends StatefulWidget {
  static const String route = '/';
  const NotificationDetail({Key? key}) : super(key: key);

  @override
  State<NotificationDetail> createState() => _NotificationDetailState();
}

class _NotificationDetailState extends State<NotificationDetail> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => NotificationDetailDesktop(),
        mobileBuilder: (context) => NotificationDetailMobile());
  }
}

class NotificationDetailDesktop extends StatelessWidget {
  const NotificationDetailDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('NotificationDetailDesktop'),
      ),
    );
  }
}

class NotificationDetailMobile extends StatelessWidget {
  const NotificationDetailMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('NotificationDetailMobile'),
      ),
    );
  }
}
