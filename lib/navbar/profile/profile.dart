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

  static const Color _accentAdded = Color(0xFF57A96E);
  static const Color _accentEdited = Color(0xFF6C63FF);
  static const Color _accentReview = Color(0xFFF0A202);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    BoxDecoration cardDecoration() => BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
        );

    Widget sectionTitle(String title) => Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(title, style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w700)),
        );

    Widget roleChip() {
      final color = user.isAdmin ? _accentReview : colorScheme.primary;
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(user.isAdmin ? 'Admin' : 'User',
            style: textTheme.labelMedium!.copyWith(color: color, fontWeight: FontWeight.w700)),
      );
    }

    Widget header() {
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primaryContainer.withValues(alpha: 0.55),
              colorScheme.surfaceContainerHighest,
            ],
          ),
        ),
        child: Column(
          children: [
            SizedBox(
              height: 36,
              child: (!isReadOnly && size.width <= 600)
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: VHIcon(
                        Icons.settings,
                        size: 38,
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(PageRoutes.sharedAxis(
                              const SettingsPage(), SharedAxisTransitionType.horizontal));
                        },
                      ),
                    )
                  : null,
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: colorScheme.primary.withValues(alpha: 0.18),
                  child: CircularAvatar(
                    url: '${user.avatarUrl}',
                    name: user.name.initals(),
                    radius: 42,
                  ),
                ),
                if (!isReadOnly)
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: VHIcon(
                      Icons.edit,
                      size: 32,
                      onTap: () {
                        Navigator.of(context, rootNavigator: true).push(PageRoutes.sharedAxis(
                            // Re-fetch the profile when edit closes so saved
                            // changes (e.g. username) show.
                            EditProfile(onClose: () => onRefresh?.call()),
                            SharedAxisTransitionType.scaled));
                      },
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              user.name.isEmpty ? 'Guest' : (user.name.capitalize() ?? user.name),
              textAlign: TextAlign.center,
              style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (user.username.isNotEmpty) ...[
                  Flexible(
                    child: Text('@${user.username}',
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium!.copyWith(color: colorScheme.onSurfaceVariant)),
                  ),
                  const SizedBox(width: 8),
                ],
                roleChip(),
              ],
            ),
            if (user.created_at != null) ...[
              const SizedBox(height: 8),
              Text('Joined ${user.created_at!.formatDate()}',
                  style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
      );
    }

    Widget contributionStat(IconData icon, Color color, int value, String label) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text('$value', style: textTheme.headlineSmall!.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant),
          ),
        ],
      );
    }

    Widget contributionsCard() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: cardDecoration(),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: contributionStat(Icons.add_circle_outline_rounded, _accentAdded,
                    stats.wordsAdded, 'Words Added')),
            Expanded(
                child: contributionStat(
                    Icons.edit_outlined, _accentEdited, stats.wordsEdited, 'Words Edited')),
            Expanded(
                child: contributionStat(Icons.hourglass_bottom_rounded, _accentReview,
                    stats.underReview, 'Under Review')),
          ],
        ),
      );
    }

    Widget collectionsTile() {
      return Container(
        decoration: cardDecoration(),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.bookmarks_rounded, color: colorScheme.primary, size: 22),
          ),
          title: Text('My Collections',
              style: textTheme.titleMedium!.copyWith(fontWeight: FontWeight.w600)),
          subtitle: Text('Your saved word lists',
              style: textTheme.bodySmall!.copyWith(color: colorScheme.onSurfaceVariant)),
          trailing: Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
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
                        return CollectionsNavigator(controller: controller, word: Word.init());
                      });
                });
            NavbarNotifier.hideBottomNavBar = false;
          },
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh?.call(),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              header(),
              const SizedBox(height: 24),
              sectionTitle('Contributions'),
              contributionsCard(),
              if (!isReadOnly) ...[
                const SizedBox(height: 20),
                sectionTitle('Library'),
                collectionsTile(),
              ],
            ],
          ),
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
      // Profile is a root tab, not a pushed route — no back button.
      appBar: AppBar(title: const Text('Profile'), automaticallyImplyLeading: false),
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
