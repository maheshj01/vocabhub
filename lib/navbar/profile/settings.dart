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
  bool animate = false;
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        animationDuration: Duration(seconds: 4),
        animate: animate,
        repeatAnimation: false,
        onAnimateComplete: () {
          setState(() {
            animate = false;
          });
        },
        desktopBuilder: (context) => SettingsPageDesktop(),
        mobileBuilder: (context) => SettingsPageMobile(
              onThemeChanged: (value) {
                setState(() {
                  animate = true;
                });
              },
            ));
  }
}

class SettingsPageMobile extends ConsumerStatefulWidget {
  final Function onThemeChanged;

  const SettingsPageMobile({Key? key, required this.onThemeChanged}) : super(key: key);

  @override
  _SettingsPageMobileState createState() => _SettingsPageMobileState();
}

class _SettingsPageMobileState extends ConsumerState<SettingsPageMobile> {
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
    final appTheme = ref.watch(appThemeProvider);
    ref.listen<UserModel>(userNotifierProvider, (UserModel? userOld, UserModel? userNew) {
      if (userNew != null) {
        user.setUser(userNew);
      }
    });

    return Material(
      color: Colors.transparent,
      child: ListView(
        children: [
          AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('Settings'),
          ),
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
                Text('${appTheme.isDark ? 'Dark' : 'Light'} Theme',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    )),
                Spacer(),
                Icon(
                  appTheme.isDark ? Icons.dark_mode : Icons.light_mode,
                  color: colorScheme.primary,
                ),
                10.0.hSpacer(),
                VocabSwitch(
                    value: appTheme.isDark,
                    onChanged: (x) {
                      ref.read(appThemeProvider.notifier).setDark(x);
                      // widget.onThemeChanged(x ? ThemeMode.dark : ThemeMode.light);
                    })
              ],
            ),
          ),
          Padding(
            padding: 16.0.horizontalPadding,
            child: Row(
              children: [
                Text('Use Classic Theme',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    )),
                Spacer(),
                VocabSwitch(
                    value: appTheme.isClassic,
                    onChanged: (x) {
                      ref.read(appThemeProvider.notifier).setClassic(x);
                      widget.onThemeChanged(x);
                    })
              ],
            ),
          ),
          Padding(
            padding: 16.0.horizontalPadding,
            child: Row(
              children: [
                Text('Choose color scheme',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                    )),
                Spacer(),
              ],
            ),
          ),
          ThemeSelector(
              value: appTheme.themeSeed,
              onThemeChanged: (val) {
                ref.read(appThemeProvider.notifier).setThemeSeed(val);
                widget.onThemeChanged(val);
              }),
          20.0.vSpacer(),
          hLine(),
          AnimatedBuilder(
              animation: exploreController,
              builder: (context, child) {
                return ExpansionTile(
                    title: Text(
                      'Explore Settings',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    subtitle: Text(
                      'Settings for explore page',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    childrenPadding: 20.0.rightPadding,
                    children: [
                      ListTile(
                        title: Text('Hide Explore Words'),
                        subtitle: Text(
                          exploreController.isHidden
                              ? 'Words definition will be hidden from explore page'
                              : 'Words definition will be shown in explore page',
                        ),
                        trailing: VocabSwitch(
                            value: exploreController.isHidden,
                            onChanged: (x) {
                              exploreController.toggleHiddenExplore();
                            }),
                      ),
                      hLine(),
                      AnimatedBuilder(
                          animation: settingsController,
                          builder: (context, child) {
                            return Column(
                              children: [
                                ListTile(
                                  title: Text('Hands Free Mode'),
                                  subtitle: Text(
                                    'if enabled words will AutoScroll in explore page',
                                  ),
                                  trailing: VocabSwitch(
                                      value: settingsController.autoScroll.enabled,
                                      onChanged: (x) {
                                        settingsController.autoScroll = settingsController
                                            .autoScroll
                                            .copyWith(enabled: x, isPaused: !x);
                                      }),
                                ),
                                hLine(),
                                if (settingsController.autoScroll.enabled)
                                  ListTile(
                                    title: Text(
                                        'Auto scroll delay ${settingsController.autoScroll.durationInSeconds} seconds',
                                        style: TextStyle(fontSize: 18)),
                                    subtitle: Padding(
                                      padding: 16.0.horizontalPadding,
                                      child: Row(
                                        children: [
                                          Text(
                                            '10',
                                            style: TextStyle(
                                                fontSize: 20, fontWeight: FontWeight.w400),
                                          ),
                                          Flexible(
                                            child: Slider(
                                                min: 10,
                                                max: 30,
                                                value: settingsController
                                                            .autoScroll.durationInSeconds <
                                                        10
                                                    ? 10.0
                                                    : settingsController
                                                        .autoScroll.durationInSeconds
                                                        .toDouble(),
                                                inactiveColor: Colors.grey,
                                                onChanged: (x) {
                                                  settingsController.autoScroll = settingsController
                                                      .autoScroll
                                                      .copyWith(durationInSeconds: x.toInt());
                                                }),
                                          ),
                                          Text(
                                            '30',
                                            style: TextStyle(
                                                fontSize: 20, fontWeight: FontWeight.w400),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          })
                    ]);
              }),
          AnimatedBuilder(
              animation: pushNotificationService,
              builder: (context, child) {
                return Stack(
                  children: [
                    ExpansionTile(
                      title: Text(
                        'Notifications',
                      ),
                      subtitle: Text(
                        'Manage your notifications',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      childrenPadding: 20.0.rightPadding,
                      children: [
                        ListTile(
                          title: Text('Word of the day'),
                          subtitle: Text('Get notified for a new word everyday'),
                          trailing: VocabSwitch(
                              value: pushNotificationService.notifications[0],
                              onChanged: (x) {
                                pushNotificationService.subscribeToNotifications(0, x);
                              }),
                        ),
                        ListTile(
                            title: Text('Daily Reminder'),
                            subtitle: Text('Get notified to learn new words everyday'),
                            trailing: VocabSwitch(
                                value: pushNotificationService.notifications[1],
                                onChanged: (x) {
                                  pushNotificationService.subscribeToNotifications(1, x);
                                })),
                        ListTile(
                            title: Text('New Words on Vocabhub'),
                            subtitle: Text('Get notified for new word additions on Vocabhub'),
                            trailing: VocabSwitch(
                                value: pushNotificationService.notifications[2],
                                onChanged: (x) {
                                  pushNotificationService.subscribeToNotifications(2, x);
                                }))
                      ],
                    ),
                    //           // Positioned(
                    //           //   top: 10,
                    //           //   right: 16,
                    //           //   child: VocabSwitch(
                    //           //       value: pushNotificationService.notify,
                    //           //       onChanged: (x) {
                    //           //         pushNotificationService.subscribeToNotifications(x);
                    //           //       }),
                    //           // )
                  ],
                );
              }),
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
          // !user.isAdmin ? const SizedBox.shrink() : hLine(),
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
          hLine(),
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
            user.loggedIn = false;
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

class VocabSwitch extends StatelessWidget {
  final bool value;
  final Function(bool)? onChanged;
  const VocabSwitch({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Switch(
        inactiveThumbColor: colorScheme.primary,
        trackOutlineColor: MaterialStateColor.resolveWith((states) => colorScheme.primary),
        value: value,
        onChanged: onChanged);
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
    return Container(
      color: Theme.of(context).colorScheme.background,
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
