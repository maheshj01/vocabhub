import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/controller/tab_refresh_controller.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/navbar/error_page.dart';
import 'package:vocabhub/navbar/pageroute.dart';
import 'package:vocabhub/navbar/profile/edit.dart';
import 'package:vocabhub/navbar/profile/settings.dart';
import 'package:vocabhub/pages/collections/collections.dart';
import 'package:vocabhub/profile/domain/contribution_stats.dart';
import 'package:vocabhub/profile/presentation/profile_controller.dart';
import 'package:vocabhub/profile/presentation/profile_providers.dart';
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
            return MaterialPageRoute(builder: (context) => EditProfile(onClose: () {}));
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

/// Profile screen. Owns a per-view [ProfileController] (clean-architecture
/// island under `lib/profile/`) that loads the profile + contribution stats.
/// When [isReadOnly] is true, [email] must identify the user to display.
class UserProfile extends ConsumerStatefulWidget {
  static const String route = '/profile';
  final bool isReadOnly;
  final String email;
  UserProfile({Key? key, this.isReadOnly = false, this.email = ''}) : super(key: key);

  @override
  ConsumerState<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends ConsumerState<UserProfile> {
  late final ProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ProfileController(
      loadProfile: ref.read(loadProfileProvider),
      loadContributions: ref.read(loadContributionsProvider),
      session: ref.read(userNotifierProvider),
      isReadOnly: widget.isReadOnly,
      email: widget.email,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _controller.load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('UserProfile build called with isReadOnly=${widget.isReadOnly}, email=${widget.email}');
    // Silently re-fetch when this tab is (re)selected. General per-tab signal;
    // only refresh once we already have data, so first open isn't double-loaded.
    ref.listen<int>(
      tabRefreshProvider.select((ticks) => ticks[AppTabs.profile] ?? 0),
      (_, __) {
        if (_controller.state.hasUser) _controller.refresh();
      },
    );
    return Material(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final state = _controller.state;

          // Only block the whole screen on a hard failure with nothing to show.
          if (state.error != null && !state.hasUser) {
            return ErrorPage(onRetry: _controller.load, errorMessage: state.error!);
          }

          final loading = state.isLoading && !state.hasUser;
          return ResponsiveBuilder(
            desktopBuilder: (context) => loading
                ? const LoadingWidget()
                : UserProfileDesktop(
                    user: state.user!,
                    stats: state.stats,
                    onRefresh: _controller.refresh,
                  ),
            mobileBuilder: (context) => loading
                ? const LoadingWidget()
                : UserProfileMobile(
                    user: state.user!,
                    stats: state.stats,
                    isReadOnly: widget.isReadOnly,
                    onRefresh: _controller.refresh,
                  ),
          );
        },
      ),
    );
  }
}

/// Presentational profile card. Holds no fetching logic — [user] and [stats]
/// come from the controller; pull-to-refresh delegates to [onRefresh].
class UserProfileMobile extends StatelessWidget {
  const UserProfileMobile({
    Key? key,
    required this.user,
    required this.stats,
    this.onRefresh,
    this.isReadOnly = false,
  }) : super(key: key);

  final Future<void> Function()? onRefresh;
  final UserModel user;
  final ContributionStats stats;
  final bool isReadOnly;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;

    Widget headLine(String title, {double padding = 16.0}) {
      return Container(
        padding: padding.horizontalPadding,
        alignment: Alignment.centerLeft,
        child: heading(title),
      );
    }

    final contributions = <({String label, int value})>[
      (label: 'Words Added', value: stats.wordsAdded),
      (label: 'Words Edited', value: stats.wordsEdited),
      (label: 'Under Review', value: stats.underReview),
    ];

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: ListView(
          children: [
            Align(
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
                          const SizedBox(width: 20),
                          RichText(
                            text: TextSpan(children: [
                              TextSpan(
                                text: 'Joined ',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(fontWeight: FontWeight.w600, fontSize: 12),
                              ),
                              TextSpan(
                                text: user.created_at?.formatDate() ?? '—',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(fontWeight: FontWeight.w600),
                              ),
                            ]),
                          ),
                          size.width > 600 || isReadOnly
                              ? const SizedBox.shrink()
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
                              name: user.name.initals(),
                              radius: 40,
                            ),
                          ),
                        ),
                        isReadOnly
                            ? const SizedBox.shrink()
                            : Positioned(
                                right: 8,
                                bottom: 16,
                                child: VHIcon(
                                  Icons.edit,
                                  size: 30,
                                  onTap: () {
                                    Navigator.of(context, rootNavigator: true).push(
                                        PageRoutes.sharedAxis(EditProfile(onClose: () async {}),
                                            SharedAxisTransitionType.scaled));
                                  },
                                )),
                      ],
                    ),
                    Padding(
                      padding: 8.0.horizontalPadding,
                      child: Text(
                        '@${user.username} ${!user.isAdmin ? ' (User)' : '(Admin)'}',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall!
                            .copyWith(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                    ),
                    Text(
                      '${user.name.capitalize()}',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                          fontSize: user.name.length > 20 ? 20 : 26, fontWeight: FontWeight.w500),
                    ),
                    10.0.vSpacer(),
                  ],
                ),
              ),
            ),
            Container(
              padding: 8.0.verticalPadding,
              decoration: BoxDecoration(
                  borderRadius: 16.0.allRadius, border: Border.all(color: colorScheme.secondary)),
              child: Column(
                children: [
                  headLine('Contributions'),
                  SizedBox(
                    height: 80,
                    child: Row(
                      children: [
                        for (final item in contributions)
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  '${item.value}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium!
                                      .copyWith(fontSize: 28, fontWeight: FontWeight.w600),
                                ),
                                4.0.vSpacer(),
                                Text(
                                  item.label,
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
            isReadOnly
                ? const SizedBox.shrink()
                : Container(
                    decoration: BoxDecoration(
                        borderRadius: 16.0.allRadius,
                        border: Border.all(color: colorScheme.secondary)),
                    child: ListTile(
                      title: headLine('My Collections', padding: 0),
                      contentPadding: 8.0.allPadding + 8.0.horizontalPadding,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
                      trailing: VHIcon(Icons.bookmarks),
                      onTap: () async {
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
                                        controller: controller, word: Word.init());
                                  });
                            });
                        NavbarNotifier.hideBottomNavBar = false;
                      },
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}

class UserProfileDesktop extends StatelessWidget {
  const UserProfileDesktop({
    Key? key,
    required this.user,
    required this.stats,
    this.onRefresh,
  }) : super(key: key);

  final UserModel user;
  final ContributionStats stats;
  final Future<void> Function()? onRefresh;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Profile')),
      body: Row(
        children: [
          Expanded(
            child: UserProfileMobile(user: user, stats: stats, onRefresh: onRefresh),
          ),
          Expanded(
            child: SettingsPageMobile(onThemeChanged: () {}),
          ),
        ],
      ),
    );
  }
}
