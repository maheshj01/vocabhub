import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/notification.dart';
import 'package:vocabhub/navbar/pageroute.dart';
import 'package:vocabhub/navbar/profile/edit.dart';
import 'package:vocabhub/navbar/profile/settings.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/icon.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class UserProfile extends StatefulWidget {
  static const String route = '/';
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  @override
  void initState() {
    super.initState();
    getUser();
  }

  Future<void> getUser() async {
    await Duration.zero;
    final userState = AppStateScope.of(context).user;
    if (userState!.isLoggedIn) {
      final user = await UserService.findByEmail(email: userState.email);
      if (user.email.isNotEmpty) {
        AppStateWidget.of(context).setUser(user);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => UserProfileMobile(),
        mobileBuilder: (context) => UserProfileMobile());
  }
}

class UserProfileMobile extends StatefulWidget {
  const UserProfileMobile({Key? key}) : super(key: key);

  @override
  State<UserProfileMobile> createState() => _UserProfileMobileState();
}

class _UserProfileMobileState extends State<UserProfileMobile> {
  Future<void> getEditStats() async {
    stats = [0, 0, 0];
    await Duration.zero;
    final user = AppStateScope.of(context).user;
    final resp = await EditHistoryService.getUserContributions(user!);
    if (resp.didSucced && resp.data != null) {
      final editHistory = resp.data as List<NotificationModel>;
      editHistory.forEach((history) {
        if (history.edit.state == EditState.approved) {
          if (history.edit.edit_type == EditType.add) {
            stats[0]++;
          } else if (history.edit.edit_type == EditType.edit) {
            stats[1]++;
          }
        } else if (history.edit.state == EditState.pending) {
          stats[2]++;
        }
      });
    }
    _statsNotifier.value = stats;
  }

  List<int> stats = [0, 0, 0];

  @override
  void initState() {
    super.initState();
    getEditStats();
  }

  @override
  void dispose() {
    _statsNotifier.dispose();
    super.dispose();
  }

  ValueNotifier<List<int>> _statsNotifier = ValueNotifier([0, 0, 0]);
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).user;
    return Scaffold(
        body: ValueListenableBuilder<List<int>>(
            valueListenable: _statsNotifier,
            builder: (BuildContext context, List<int> stats, Widget? child) {
              return RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: () async {
                  await getEditStats();
                  setState(() {});
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: ListView(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: 16.0.allRadius,
                            border: Border.all(
                                color:
                                    VocabTheme.primaryColor.withOpacity(0.5))),
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: 18.0.verticalPadding,
                            child: Column(
                              children: [
                                // TODO: implement dark theme
                                // Container(
                                //     alignment: Alignment.topRight,
                                //     padding: EdgeInsets.only(right: 16),
                                //     child: IconButton(
                                //       onPressed: () {
                                //         if (VocabTheme.isDark) {
                                //           Settings.setTheme(ThemeMode.light);
                                //         } else {
                                //           Settings.setTheme(ThemeMode.dark);
                                //         }
                                //       },
                                //       icon: VocabTheme.isDark
                                //           ? const Icon(Icons.light_mode)
                                //           : const Icon(Icons.dark_mode),
                                //     )),
                                Container(
                                  alignment: Alignment.topRight,
                                  child: Padding(
                                    padding: 16.0.horizontalPadding,
                                    child: VHIcon(
                                      Icons.settings,
                                      size: 38,
                                      onTap: () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .push(
                                                PageRoutes.sharedAxis(
                                                    const SettingsPageMobile(),
                                                    SharedAxisTransitionType
                                                        .horizontal));
                                      },
                                    ),
                                  ),
                                ),

                                Stack(
                                  children: [
                                    Padding(
                                      padding: 16.0.allPadding,
                                      child: CircleAvatar(
                                          radius: 46,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withOpacity(0.2),
                                          child: CircularAvatar(
                                            url: '${user!.avatarUrl}',
                                            radius: 40,
                                          )),
                                    ),
                                    Positioned(
                                        right: 8,
                                        bottom: 16,
                                        child: VHIcon(
                                          Icons.edit,
                                          size: 30,
                                          onTap: () {
                                             Navigator.of(context,
                                                rootNavigator: true)
                                            .push(
                                                PageRoutes.sharedAxis(
                                                   EditProfile(
                                                user: user,
                                                onClose: () async {
                                                  setState(() {});
                                                },
                                              ),
                                                    SharedAxisTransitionType
                                                        .scaled));
                                          },
                                        ))
                                  ],
                                ),
                                Padding(
                                    padding: 8.0.horizontalPadding,
                                    child: Text('@${user.username} ' +
                                        (!user.isAdmin
                                            ? ' (User)'
                                            : '(Admin)'))),
                                Text(
                                  '${user.name.capitalize()}',
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headline4!
                                      .copyWith(
                                          fontSize: 26,
                                          fontWeight: FontWeight.w500),
                                ),
                                10.0.vSpacer(),
                                RichText(
                                    text: TextSpan(children: [
                                  TextSpan(
                                      text: 'Joined ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12)),
                                  TextSpan(
                                    text: user.created_at!.formatDate(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .subtitle2!
                                        .copyWith(fontWeight: FontWeight.w600),
                                  ),
                                ])),
                              ],
                            ),
                          ),
                        ),
                      ),
                      16.0.vSpacer(),
                      Container(
                          alignment: Alignment.centerLeft,
                          child: heading('Contributions')),
                      16.0.vSpacer(),

                      /// rounded Container with border

                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: 16.0.allRadius,
                            border: Border.all(
                                color:
                                    VocabTheme.primaryColor.withOpacity(0.5))),
                        child: Row(
                          children: [
                            for (int i = 0; i < stats.length; i++)
                              Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '${stats[i]}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .headline4!
                                          .copyWith(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w500),
                                    ),
                                    4.0.vSpacer(),
                                    Text(
                                      i == 0
                                          ? 'Words Added'
                                          : i == 1
                                              ? 'Words Edited'
                                              : 'Under Review',
                                      style: Theme.of(context)
                                          .textTheme
                                          .subtitle2!
                                          .copyWith(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            }));
  }
}

class UserProfileDesktop extends StatelessWidget {
  const UserProfileDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Desktop'),
      ),
      body: ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: 20,
          itemBuilder: (BuildContext context, int x) {
            return ListTile(
              title: Text('item $x'),
            );
          }),
    );
  }
}
