import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/navbar/profile/about.dart';
import 'package:vocabhub/navbar/profile/report.dart';
import 'package:vocabhub/navbar/profile/webview.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/themes/theme_selector.dart';
import 'package:vocabhub/widgets/button.dart';
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
  void initState() {
    analytics.logRouteView(SettingsPage.route);
    super.initState();
  }

  final analytics = Analytics.instance;
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => SettingsPageDesktop(),
        mobileBuilder: (context) => SettingsPageMobile());
  }
}

class SettingsPageMobile extends ConsumerStatefulWidget {
  const SettingsPageMobile({Key? key}) : super(key: key);

  @override
  _SettingsPageMobileState createState() => _SettingsPageMobileState();
}

class _SettingsPageMobileState extends ConsumerState<SettingsPageMobile> {
  Widget settingTile(String label, {String? description, Function? onTap, IconData? trailingIcon}) {
    return ListTile(
      minVerticalPadding: 24.0,
      title: Text(
        '$label',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w400,
        ),
      ),
      subtitle: description != null
          ? Text(
              '$description',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
            )
          : null,
      onTap: () {
        if (onTap != null) {
          onTap();
        }
      },
      trailing: trailingIcon != null ? Icon(trailingIcon) : null,
    );
  }

  void showLicensePage({
    required BuildContext context,
    String? applicationName,
    String? applicationVersion,
    Widget? applicationIcon,
    String? applicationLegalese,
    bool useRootNavigator = false,
  }) {
    Navigator.of(context, rootNavigator: useRootNavigator).push(MaterialPageRoute<void>(
      builder: (BuildContext context) => LicensePage(
        applicationName: applicationName,
        applicationVersion: applicationVersion,
        applicationIcon: applicationIcon,
        applicationLegalese: applicationLegalese,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final user = ref.watch(userNotifierProvider);
    ref.listen<UserModel>(userNotifierProvider, (UserModel? userOld, UserModel? userNew) {
      if (userNew != null) {
        user.setUser(userNew);
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          settingTile(
            'About',
            onTap: () {
              Navigate.push(context, AboutVocabhub());
            },
          ),
          hLine(),
          10.0.vSpacer(),
          Padding(
            padding: 16.0.horizontalPadding,
            child: Row(
              children: [
                Text('Theme',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    )),
                Spacer(),
                Icon(
                  settingsController.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: colorScheme.primary,
                ),
                10.0.hSpacer(),
                AnimatedBuilder(
                    animation: settingsController,
                    builder: (context, child) {
                      return Switch(
                          value: settingsController.isDark,
                          onChanged: (x) {
                            settingsController.setTheme(x ? ThemeMode.dark : ThemeMode.light);
                          });
                    }),
              ],
            ),
          ),
          AnimatedBuilder(
              animation: settingsController,
              builder: (context, child) {
                return ThemeSelector(
                    value: settingsController.themeSeed,
                    onThemeChanged: (val) {
                      settingsController.themeSeed = val;
                    });
              }),
          20.0.vSpacer(),
          hLine(),
          Stack(
            children: [
              settingTile(
                'Hide Explore Words',
                description: 'When enabled, words will be hidden in explore page',
              ),
              Positioned(
                top: 10,
                right: 16,
                child: Switch(
                    value: exploreController.isHidden,
                    onChanged: (x) {
                      setState(() {
                        exploreController.toggleHiddenExplore();
                      });
                    }),
              )
            ],
          ),
          hLine(),
          settingTile(
            'Report a bug',
            onTap: () {
              Navigate.push(context, ReportABug());
            },
          ),
          hLine(),
          !user.isAdmin
              ? const SizedBox.shrink()
              : settingTile(
                  'Reports and Feedbacks',
                  onTap: () {
                    Navigate.push(context, const ViewBugReports());
                  },
                ),
          !user.isAdmin ? const SizedBox.shrink() : hLine(),
          user.isAdmin
              ? const SizedBox.shrink()
              : settingTile(
                  'My Bug Reports',
                  onTap: () {
                    Navigate.push(
                        context,
                        ViewReportsByUser(
                          email: user.email,
                          reports: [],
                          shouldFetchReport: true,
                          title: 'My Bug Reports',
                        ));
                  },
                ),
          !user.isAdmin ? const SizedBox.shrink() : hLine(),
          settingTile(Constants.PRIVACY_POLICY_TITLE, onTap: () {
            Navigate.pushNamed(context, WebViewPage.routeName, isRootNavigator: true);
          }),
          hLine(),
          settingTile('Contact Us', onTap: () {
            launchUrl(Uri.parse('mailto:${Constants.FEEDBACK_EMAIL_TO}'),
                mode: LaunchMode.externalApplication);
          }),
          hLine(),
          settingTile('Licenses', onTap: () {
            showLicensePage(
              context: context,
              applicationLegalese: "© 2022 ${Constants.ORGANIZATION}",
              applicationName: Constants.APP_TITLE,
            );
          }),
          hLine(),
          settingTile('Logout', trailingIcon: Icons.logout, onTap: () async {
            authController.logout(context);
            Navigate.pushAndPopAll(context, AppSignIn());
          }),
          hLine(),
          30.0.vSpacer(),
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

class RatingsPage extends StatefulWidget {
  const RatingsPage({super.key});

  @override
  State<RatingsPage> createState() => _RatingsPageState();
}

class _RatingsPageState extends State<RatingsPage> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: 16.0.horizontalPadding,
      child: Column(
        children: [
          20.0.vSpacer(),
          Text(
            "Rate Us",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          20.0.vSpacer(),
          Text(
            "Are you enjoying ${Constants.APP_TITLE}?",
            style: Theme.of(context).textTheme.titleLarge,
          ),
          8.0.vSpacer(),
          Text(
            '$ratingDescription',
            textAlign: TextAlign.justify,
          ),
          20.0.vSpacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  settingsController.ratedOnPlaystore = false;
                  Navigate.popView(context);
                },
                child: Text('No, Thanks'),
              ),
              16.0.hSpacer(),
              VHButton(
                height: 50,
                onTap: () async {
                  settingsController.ratedOnPlaystore = true;
                  launchUrl(Uri.parse(Constants.PLAY_STORE_URL),
                      mode: LaunchMode.externalApplication);
                },
                label: 'Rate Us',
              ),
            ],
          ),
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
    return FutureBuilder<List<LicenseEntry>>(
        future: LicenseRegistry.licenses.toList(),
        builder: (context, snapshot) {
          final licenses = snapshot.data;
          if (licenses == null) return const Center(child: CircularProgressIndicator());
          return Material(
            child: Container(
                child: ListView.builder(
                    itemBuilder: (context, index) {
                      final license = licenses[index];
                      return ListTile(
                        title: Text(license.packages.join(', ')),
                        subtitle: Text(license.paragraphs.first.text),
                        onTap: () {
                          // show license page
                          Navigate.push(
                              context,
                              LicenseDetail(
                                text: license.paragraphs.map((e) => e.text).join('\n'),
                              ));
                        },
                      );
                    },
                    itemCount: licenses.length)),
          );
        });
  }
}

class LicenseDetail extends StatefulWidget {
  final String text;
  const LicenseDetail({super.key, required this.text});

  @override
  State<LicenseDetail> createState() => _LicenseDetailState();
}

class _LicenseDetailState extends State<LicenseDetail> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('License'),
      ),
      body: SingleChildScrollView(
        child: Text(widget.text),
      ),
    );
  }
}
