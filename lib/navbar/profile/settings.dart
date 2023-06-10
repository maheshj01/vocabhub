import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/navbar/profile/about.dart';
import 'package:vocabhub/navbar/profile/report.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/widgets/drawer.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class SettingsPage extends StatefulWidget {
  static const String route = '/settings';

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
  Widget settingTile(String label, {Function? onTap}) {
    return ListTile(
      minVerticalPadding: 24.0,
      title: Text(
        '$label',
        style: TextStyle(
          fontSize: 20,
          color: VocabTheme.lightblue,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          settingTile(
            'About',
            onTap: () {
              Navigate.push(context, AboutVocabhub());
            },
          ),
          hLine(),
          // heading('Theme'),
          // const SizedBox(height: 16),
          settingTile(
            'Report a bug',
            onTap: () {
              Navigate.push(context, ReportABug());
            },
          ),
          hLine(),
          !user!.isAdmin
              ? const SizedBox.shrink()
              : settingTile(
                  'Reports and Feedbacks',
                  onTap: () {
                    Navigate.push(context, const ViewBugReports());
                  },
                ),
          !user.isAdmin ? const SizedBox.shrink() : hLine(),
          settingTile('Privacy Policy', onTap: () {
            launchUrl(Uri.parse(Constants.PRIVACY_POLICY), mode: LaunchMode.externalApplication);
          }),
          hLine(),
          settingTile('Contact Us', onTap: () {
            launchUrl(Uri.parse('mailto:${Constants.FEEDBACK_EMAIL_TO}'),
                mode: LaunchMode.externalApplication);
          }),
          hLine(),
          settingTile('Logout', onTap: () async {
            await Settings.clear();
            await AuthService.updateLogin(email: user.email, isLoggedIn: false);
            Navigate.pushAndPopAll(context, AppSignIn());
          }),
          hLine(),
          Expanded(child: SizedBox.shrink()),
          VersionBuilder(),
          30.0.vSpacer(),
          !kIsWeb
              ? const SizedBox.shrink()
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    storeRedirect(
                      context,
                    ),
                    16.0.hSpacer(),
                    storeRedirect(context,
                        redirectUrl: Constants.AMAZON_APP_STORE_URL,
                        assetUrl: 'assets/amazonappstore.png'),
                  ],
                ),
          30.0.vSpacer(),
        ],
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
