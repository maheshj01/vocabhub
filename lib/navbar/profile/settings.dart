import 'package:flutter/material.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/widgets/drawer.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class SettingsPage extends StatefulWidget {
  static const String route = '/';

  const SettingsPage({
    Key? key,
  }) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => SettingsPageDesktop(),
        mobileBuilder: (context) => SettingsPageMobile());
  }
}

class SettingsPageMobile extends StatefulWidget {
  const SettingsPageMobile({Key? key}) : super(key: key);

  @override
  State<SettingsPageMobile> createState() => _SettingsPageMobileState();
}

class _SettingsPageMobileState extends State<SettingsPageMobile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: 16.0.allPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading('About'),
            const SizedBox(height: 16),
            Text(
              'VocabHub is a free and open source app for learning and managing your vocabulary. It is developed by Mahesh Jamdade with Love and is available on Android and iOS.',
            ),
            const SizedBox(height: 16),
            heading('Theme'),
            const SizedBox(height: 16),
            heading('Report a bug'),
            const SizedBox(height: 16),
            heading('terms of service'),
            const SizedBox(height: 16),
            heading('privacy policy'),
            const SizedBox(height: 16),
            heading('contact us'),
            Expanded(child: SizedBox.shrink()),
            VersionBuilder(),
            60.0.vSpacer()
          ],
        ),
      ),
    );
  }
}

class SettingsPageDesktop extends StatefulWidget {
  const SettingsPageDesktop({Key? key}) : super(key: key);

  @override
  State<SettingsPageDesktop> createState() => _SettingsPageDesktopState();
}

class _SettingsPageDesktopState extends State<SettingsPageDesktop> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red,
      ),
    );
  }
}
