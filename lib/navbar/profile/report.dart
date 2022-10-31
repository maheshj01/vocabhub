import 'package:flutter/material.dart';
import 'package:vocabhub/widgets/responsive.dart';

class ReportABug extends StatefulWidget {
  static const String route = '/report';

  const ReportABug({
    Key? key,
  }) : super(key: key);

  @override
  State<ReportABug> createState() => _ReportABugState();
}

class _ReportABugState extends State<ReportABug> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => ReportABugDesktop(),
        mobileBuilder: (context) => ReportABugMobile());
  }
}

class ReportABugDesktop extends StatefulWidget {
  const ReportABugDesktop({Key? key}) : super(key: key);

  @override
  State<ReportABugDesktop> createState() => _ReportABugDesktopState();
}

class _ReportABugDesktopState extends State<ReportABugDesktop> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red,
      ),
    );
  }
}

class ReportABugMobile extends StatefulWidget {
  const ReportABugMobile({Key? key}) : super(key: key);

  @override
  State<ReportABugMobile> createState() => _ReportABugMobileState();
}

class _ReportABugMobileState extends State<ReportABugMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report a bug'),
      ),
      body: Column(
        children: [
          Container(
            color: Colors.red,
          ),
        ],
      ),
    );
  }
}
