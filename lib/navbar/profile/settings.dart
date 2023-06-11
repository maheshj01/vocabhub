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
          fontSize: 18,
          fontWeight: FontWeight.w400,
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
      backgroundColor: Theme.of(context).colorScheme.background,
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
          // heading('Theme'),
          // const SizedBox(height: 16),
          settingTile(
            'Report a bug',
            onTap: () {
              Navigate.push(context, ReportABug());
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
                  Icons.brightness_6,
                  color: settingsController.themeSeed,
                ),
                AnimatedBuilder(
                    animation: settingsController,
                    builder: (context, child) {
                      return Switch(
                          value: settingsController.theme == ThemeMode.dark,
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

/// Creates a [ThemeSelector] widget.
/// The [value] and [onThemeChanged] arguments must not be null.
/// The [value] must be one of the following colors:
/// [Colors.red], [Colors.green], [Colors.blue], [Colors.yellow], [Colors.purple]
class ThemeSelector extends StatefulWidget {
  ///  The color value for the theme.
  final Color value;

  /// The callback that is called when the theme is changed.
  final Function(Color color) onThemeChanged;

  final List<Color> colors;

  ThemeSelector({
    Key? key,
    required this.value,
    required this.onThemeChanged,
    this.colors = const [Colors.pink, Colors.green, Colors.blue, Colors.yellow, Colors.purple],
  }) : super(key: key);

  @override
  State<ThemeSelector> createState() => _ThemeSelectorState();
}

class _ThemeSelectorState extends State<ThemeSelector> {
  Widget circle(Color color, bool isSelected) {
    return AnimatedContainer(
        height: 30,
        width: 30,
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: isSelected
            ? Icon(
                Icons.check,
                color: Colors.white,
                size: 20,
              )
            : const SizedBox.shrink());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var color in widget.colors)
          GestureDetector(
            onTap: () {
              widget.onThemeChanged(color);
            },
            child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: circle(color, widget.value.value == color.value)),
          ),
      ],
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
