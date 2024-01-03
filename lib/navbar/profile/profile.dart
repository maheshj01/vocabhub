import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/models/notification.dart';
import 'package:vocabhub/navbar/error_page.dart';
import 'package:vocabhub/navbar/pageroute.dart';
import 'package:vocabhub/navbar/profile/edit.dart';
import 'package:vocabhub/navbar/profile/settings.dart';
import 'package:vocabhub/pages/collections/collections.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/icon.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class UserProfileNavigator extends StatefulWidget {
  static const String route = '/';
  const UserProfileNavigator({super.key});

  @override
  State<UserProfileNavigator> createState() => _UserProfileNavigatorState();
}

class _UserProfileNavigatorState extends State<UserProfileNavigator> {
  @override
  Widget build(BuildContext context) {
    return Navigator(
      initialRoute: UserProfile.route,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case UserProfile.route:
            return MaterialPageRoute(builder: (context) => UserProfile());
          case EditProfile.route:
            return MaterialPageRoute(
                builder: (context) => EditProfile(
                      onClose: () {},
                    ));
          case SettingsPage.route:
            return MaterialPageRoute(builder: (context) => SettingsPage());

          default:
            return MaterialPageRoute(
                builder: (context) => ErrorPage(
                    onRetry: () {}, errorMessage: 'Oh no! You have landed on an unknown planet '));
        }
      },
    );
  }
}

/// when specidying readOnly as true, email must be provided
class UserProfile extends ConsumerStatefulWidget {
  static const String route = '/profile';
  final bool isReadOnly;
  final String email;
  UserProfile({Key? key, this.isReadOnly = false, this.email = ''}) : super(key: key);

  @override
  _UserProfileState createState() => _UserProfileState();
}

class _UserProfileState extends ConsumerState<UserProfile> {
  @override
  void initState() {
    super.initState();
    userProfileNotifier = ValueNotifier<Response>(response);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchUser();
    });
  }

  late final ValueNotifier<Response> userProfileNotifier;
  final response = Response.init();

  @override
  void dispose() {
    userProfileNotifier.dispose();
    super.dispose();
  }

  Future<void> _fetchUser() async {
    userProfileNotifier.value =
        response.copyWith(state: RequestState.active, message: "Loading...");
    try {
      if (!widget.isReadOnly) {
        final user = ref.watch(userNotifierProvider);
        final updatedUser = await UserService.findByEmail(email: user.email, cache: true);
        user.setUser(updatedUser);
        userProfileNotifier.value = response.copyWith(
            state: RequestState.done, message: "Success", data: updatedUser, didSucced: true);
      } else {
        final user = await UserService.findByEmail(email: widget.email, cache: false);
        userProfileNotifier.value = response.copyWith(
            state: RequestState.done, message: "Success", data: user, didSucced: true);
      }
    } catch (_) {
      if (_.runtimeType == TimeoutException) {
        NavbarNotifier.showSnackBar(context, NETWORK_ERROR);
        userProfileNotifier.value = response.copyWith(
            state: RequestState.error, message: NETWORK_ERROR, data: null, didSucced: false);
      } else {
        NavbarNotifier.showSnackBar(context, SOMETHING_WENT_WRONG);
        userProfileNotifier.value = response.copyWith(
            state: RequestState.error, message: SOMETHING_WENT_WRONG, data: null, didSucced: false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ValueListenableBuilder<Response>(
          valueListenable: userProfileNotifier,
          builder: (context, response, child) {
            if (response.state == RequestState.error) {
              return ErrorPage(
                onRetry: _fetchUser,
                errorMessage: response.message,
              );
            }
            return ResponsiveBuilder(
                desktopBuilder: (context) => UserProfileDesktop(),
                mobileBuilder: (context) {
                  if (response.state == RequestState.active || response.data == null) {
                    return LoadingWidget();
                  }
                  return UserProfileMobile(
                    user: response.data as UserModel,
                    isReadOnly: widget.isReadOnly,
                    onRefresh: () async {
                      await _fetchUser();
                    },
                  );
                });
          }),
    );
  }
}

class UserProfileMobile extends ConsumerStatefulWidget {
  const UserProfileMobile({Key? key, this.onRefresh, required this.user, this.isReadOnly = false})
      : super(key: key);
  final VoidCallback? onRefresh;
  final UserModel user;
  final bool isReadOnly;

  @override
  _UserProfileMobileState createState() => _UserProfileMobileState();
}

class _UserProfileMobileState extends ConsumerState<UserProfileMobile> {
  Future<void> getEditStats() async {
    final user = widget.user;
    try {
      final resp = await EditHistoryService.getUserContributions(user);
      stats = [0, 0, 0];
      if (resp.didSucced && resp.data != null) {
        final editHistory = resp.data as List<NotificationModel>;
        for (var history in editHistory) {
          if (history.edit.state == EditState.approved) {
            if (history.edit.edit_type == EditType.add) {
              stats[0]++;
            } else if (history.edit.edit_type == EditType.edit) {
              stats[1]++;
            }
          } else if (history.edit.state == EditState.pending) {
            stats[2]++;
          }
        }
        if (mounted) {
          _statsNotifier.value = stats;
        }
      }
    } catch (_) {
      if (_.runtimeType == TimeoutException) {
        NavbarNotifier.showSnackBar(context, NETWORK_ERROR);
      } else {
        NavbarNotifier.showSnackBar(context, SOMETHING_WENT_WRONG);
      }
    }
  }

  List<int> stats = [0, 0, 0];

  @override
  void initState() {
    _statsNotifier = ValueNotifier<List<int>>(stats);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getEditStats();
    });
    super.initState();
  }

  @override
  void dispose() {
    _statsNotifier.dispose();
    super.dispose();
  }

  late ValueNotifier<List<int>> _statsNotifier;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    final user = widget.user;
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    Widget headLine(String title, {double padding = 16.0}) {
      return Container(
          padding: padding.horizontalPadding,
          alignment: Alignment.centerLeft,
          child: heading('$title'));
    }

    return ValueListenableBuilder<List<int>>(
        valueListenable: _statsNotifier,
        builder: (BuildContext context, List<int> stats, Widget? child) {
          return RefreshIndicator(
            key: _refreshIndicatorKey,
            onRefresh: () async {
              await getEditStats();
              if (widget.onRefresh != null) {
                widget.onRefresh!();
              }
              setState(() {});
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: ListView(
                children: [
                  Container(
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: 18.0.verticalPadding,
                        child: Column(
                          children: [
                            Padding(
                              padding: 8.0.horizontalPadding,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 20,
                                  ),
                                  RichText(
                                      text: TextSpan(children: [
                                    TextSpan(
                                        text: 'Joined ',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall!
                                            .copyWith(fontWeight: FontWeight.w600, fontSize: 12)),
                                    TextSpan(
                                      text: user.created_at!.formatDate(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ])),
                                  size.width > 600 || widget.isReadOnly
                                      ? SizedBox.shrink()
                                      : VHIcon(
                                          Icons.settings,
                                          size: 38,
                                          onTap: () {
                                            Navigator.of(context, rootNavigator: true).push(
                                                PageRoutes.sharedAxis(const SettingsPage(),
                                                    SharedAxisTransitionType.horizontal));
                                          },
                                        ),
                                ],
                              ),
                            ),
                            Stack(
                              children: [
                                Padding(
                                  padding: 16.0.allPadding,
                                  child: CircleAvatar(
                                      radius: 46,
                                      backgroundColor: colorScheme.primary.withOpacity(0.2),
                                      child: CircularAvatar(
                                        url: '${user.avatarUrl}',
                                        name: '${user.name.initals()}',
                                        radius: 40,
                                      )),
                                ),
                                widget.isReadOnly
                                    ? SizedBox.shrink()
                                    : Positioned(
                                        right: 8,
                                        bottom: 16,
                                        child: VHIcon(
                                          Icons.edit,
                                          size: 30,
                                          onTap: () {
                                            Navigator.of(context, rootNavigator: true)
                                                .push(PageRoutes.sharedAxis(EditProfile(
                                              onClose: () async {
                                                setState(() {});
                                              },
                                            ), SharedAxisTransitionType.scaled));
                                          },
                                        ))
                              ],
                            ),
                            Padding(
                                padding: 8.0.horizontalPadding,
                                child: Text(
                                    '@${user.username} ${!user.isAdmin ? ' (User)' : '(Admin)'}',
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                        ))),
                            Text(
                              '${user.name.capitalize()}',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                  fontSize: user.name.length > 20 ? 20 : 26,
                                  fontWeight: FontWeight.w500),
                            ),
                            10.0.vSpacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // hLine(height: 1),
                  // 4.0.vSpacer(),
                  Container(
                    padding: 8.0.verticalPadding,
                    decoration: BoxDecoration(
                        borderRadius: 16.0.allRadius,
                        border: Border.all(color: colorScheme.secondary)),
                    child: Column(
                      children: [
                        headLine('Contributions'),
                        SizedBox(
                          height: 80,
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
                                            .headlineMedium!
                                            .copyWith(fontSize: 28, fontWeight: FontWeight.w600),
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
                                            .titleSmall!
                                            .copyWith(fontSize: 12, fontWeight: FontWeight.w800),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  16.0.vSpacer(),
                  widget.isReadOnly
                      ? SizedBox.shrink()
                      : Container(
                          decoration: BoxDecoration(
                              borderRadius: 16.0.allRadius,
                              border: Border.all(color: colorScheme.secondary)),
                          child: ListTile(
                            title: headLine('My Collections', padding: 0),
                            contentPadding: 8.0.allPadding + 8.0.horizontalPadding,
                            shape:
                                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                            trailing: VHIcon(Icons.bookmarks),
                            onTap: () async {
                              // ref.read(appProvider.notifier).setShowFAB(false);
                              if (size.width < 600) {
                                NavbarNotifier.hideBottomNavBar = true;
                              }
                              await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return DraggableScrollableSheet(
                                        maxChildSize: 0.9,
                                        initialChildSize: 0.9,
                                        expand: false,
                                        builder: (context, controller) {
                                          return CollectionsNavigator(
                                            controller: controller,
                                            word: Word.init(),
                                          );
                                        });
                                  });
                              // ref.read(appProvider.notifier).setShowFAB(true);
                              NavbarNotifier.hideBottomNavBar = false;
                            },
                          ),
                        ),
                ],
              ),
            ),
          );
        });
  }
}

class UserProfileDesktop extends ConsumerWidget {
  const UserProfileDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: Row(
        children: [
          Expanded(
              child: UserProfileMobile(
            user: user,
          )),
          Expanded(
              child: SettingsPageMobile(
            onThemeChanged: () {},
          )),
        ],
      ),
    );
  }
}
