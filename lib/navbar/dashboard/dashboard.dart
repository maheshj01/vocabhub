import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/navbar/dashboard/bookmarks.dart';
import 'package:vocabhub/navbar/error_page.dart';
import 'package:vocabhub/pages/collections/collections.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/pages/notifications/notifications.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/worddetail.dart';

class Dashboard extends ConsumerStatefulWidget {
  static String route = '/';
  const Dashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends ConsumerState<Dashboard> {
  @override
  void initState() {
    _dashBoardNotifier = ValueNotifier(response);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      publishWordOfTheDay();
      final collectionRef = ref.watch(collectionNotifier);
      collectionRef.initService();
    });
    super.initState();
  }

  /// get latest word of the day sort by descending order of created_at
  /// check current DateTime UTC and compare with the latest word of the day
  /// if the date is same, then don't publish a new word of the day
  /// else publish a new word of the day

  /// todo word of the day
  Future<void> publishWordOfTheDay({bool isRefresh = false}) async {
    _dashBoardNotifier.value = response.copyWith(state: RequestState.active, message: "Loading...");
    try {
      // If word of the day already published then get word of the day
      if (dashboardController.isWodPublishedToday) {
        if (isRefresh) {
          final word = await dashboardController.getLastPublishedWord();
          dashboardController.wordOfTheDay = word;
          _dashBoardNotifier.value = response.copyWith(data: word, state: RequestState.done);
          return;
        }
        final publishedWod = dashboardController.wordOfTheDay;
        _dashBoardNotifier.value = response.copyWith(data: publishedWod, state: RequestState.done);
        return;
      }
      final allWords = dashboardController.words;
      final random = Random();
      final randomWord = allWords[random.nextInt(allWords.length)];
      final success = await dashboardController.publishWod(randomWord);
      if (success) {
        _dashBoardNotifier.value = response.copyWith(state: RequestState.done);
        pushNotificationService.sendNotificationToTopic(PushNotificationService.wordOfTheDayTopic,
            'Word of the Day: ${randomWord.word} ', 'Tap to see word of the day');
      } else {
        NavbarNotifier.showSnackBar(context, "Something went wrong!");
        _dashBoardNotifier.value =
            response.copyWith(state: RequestState.error, message: "Something went wrong!");
      }
    } catch (e) {
      NavbarNotifier.showSnackBar(context, NETWORK_ERROR, bottom: 0);
      _dashBoardNotifier.value =
          response.copyWith(state: RequestState.error, message: e.toString());
    }
  }

  late final ValueNotifier<Response> _dashBoardNotifier;
  final response = Response.init();

  @override
  void dispose() {
    _dashBoardNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: ValueListenableBuilder<Response>(
            valueListenable: _dashBoardNotifier,
            builder: (context, response, child) {
              if (response.state == RequestState.error) {
                return ErrorPage(
                  onRetry: () async {
                    await publishWordOfTheDay(isRefresh: true);
                  },
                  errorMessage: response.message,
                );
              }
              return AnimatedBuilder(
                  animation: dashboardController,
                  builder: (context, child) {
                    return ResponsiveBuilder(
                      desktopBuilder: (context) => DashboardDesktop(),
                      mobileBuilder: (context) {
                        if (response.state == RequestState.active ||
                            dashboardController.isLoading) {
                          return LoadingWidget();
                        }
                        return RefreshIndicator(onRefresh: () async {
                          await publishWordOfTheDay(isRefresh: true);
                        }, child: DashboardMobile(
                          onRefresh: () async {
                            await publishWordOfTheDay(isRefresh: true);
                          },
                        ));
                      },
                    );
                  });
            }));
  }
}

class DashboardMobile extends ConsumerWidget {
  static String route = '/';
  final Function? onRefresh;
  DashboardMobile({Key? key, this.onRefresh}) : super(key: key);
  final analytics = Analytics.instance;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userNotifierProvider);
    final word = dashboardController.wordOfTheDay;
    return Padding(
      padding: (kNavbarHeight * 1.2).bottomPadding,
      child: CustomScrollView(
        scrollBehavior: const MaterialScrollBehavior().copyWith(overscroll: true),
        physics: BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: <Widget>[
          SliverAppBar(
              pinned: false,
              expandedHeight: 80.0,
              backgroundColor: Colors.transparent,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                background: Container(
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 16, top: 16),
                  child: Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              actions: [
                user.isLoggedIn && SizeUtils.isMobile
                    ? IconButton(
                        onPressed: () {
                          Navigate.pushNamed(context, Notifications.route, isRootNavigator: true);
                        },
                        icon: Icon(
                          Icons.notifications_on,
                          color: Theme.of(context).colorScheme.surfaceTint,
                        ))
                    : SizedBox.shrink(),
              ]),
          SliverToBoxAdapter(
            child: Padding(
              padding: 16.0.horizontalPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: 16.0.verticalPadding,
                    child: heading('Word of the day'),
                  ),
                  WordOfTheDayCard(
                    word: word,
                    isError: word.word.isEmpty,
                    onTap: () {
                      if (word.word.isEmpty) {
                        onRefresh?.call();
                      } else {
                        Navigate.push(
                          context,
                          WordDetail(word: word, isWod: true, title: 'Word of the Day'),
                        );
                      }
                    },
                  ),
                  Padding(
                    padding: 12.0.verticalPadding,
                    child: heading('Progress'),
                  ),
                  if (user.isLoggedIn) ...[
                    DashboardCollections(),
                    16.0.vSpacer(),
                  ],
                  _StatTilesRow(user: user),
                  if (!user.isLoggedIn) ...[
                    16.0.vSpacer(),
                    const _SyncBanner(),
                  ],
                  100.0.vSpacer()
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class DashboardCollections extends ConsumerStatefulWidget {
  const DashboardCollections({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _DashboardCollectionsState();
}

class _DashboardCollectionsState extends ConsumerState<DashboardCollections> {
  bool hasPinned(List<VHCollection> collections) {
    for (final collection in collections) {
      if (collection.isPinned) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final collections = ref.watch(collectionNotifier).collections;
    final _collectionNotifier = ref.watch(collectionNotifier);
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    return !hasPinned(collections)
        ? SizedBox.shrink()
        : Container(
            padding: 8.0.allPadding,
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [colorScheme.surface, colorScheme.surfaceContainerHighest]),
                border: Border.all(color: colorScheme.surfaceTint, width: 1.0),
                borderRadius: BorderRadius.circular(16.0)),

            // height: size.height / 3.5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: 12.0.verticalPadding + 8.0.leftPadding,
                  child: Row(
                    children: [
                      Expanded(child: heading('Collections', color: colorScheme.primary)),
                      IconButton(
                          onPressed: () async {
                            // to hide fab
                            ref.read(appProvider.notifier).setUpdate(true);
                            if (size.width < 600) {
                              NavbarNotifier.hideBottomNavBar = true;
                            }
                            await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (context) {
                                  return DraggableScrollableSheet(
                                      maxChildSize: 0.7,
                                      initialChildSize: 0.7,
                                      expand: false,
                                      builder: (context, controller) {
                                        return ClipRRect(
                                          borderRadius:
                                              BorderRadius.vertical(top: Radius.circular(28.0)),
                                          child: NewCollection(
                                            isPinned: true,
                                          ),
                                        );
                                      });
                                });
                            ref.read(appProvider.notifier).setUpdate(false);
                            NavbarNotifier.hideBottomNavBar = false;
                          },
                          icon: Icon(
                            Icons.add,
                            color: colorScheme.primary,
                          ))
                    ],
                  ),
                ),
                collections.isEmpty
                    ? SizedBox.shrink()
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        padding: 2.0.verticalPadding,
                        itemCount: collections.length,
                        itemBuilder: (context, index) {
                          final title = collections[index].title;
                          final words = collections[index].words;
                          final bool isPinned = collections[index].isPinned;
                          final Color color = collections[index].color;
                          if (!isPinned) return SizedBox.shrink();
                          return Card(
                            color: color,
                            child: ListTile(
                                title: Text('$title (${words.length})',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(color: Colors.white)),
                                onTap: () {
                                  Navigate.push(
                                      context,
                                      ResponsiveBuilder(desktopBuilder: (x) {
                                        return Material(
                                          color: Colors.transparent,
                                          child: Column(
                                            children: [
                                              AppBar(
                                                backgroundColor: Colors.transparent,
                                                title: Text('$title'),
                                              ),
                                              Expanded(
                                                child: WordListBuilder(
                                                  words: words,
                                                  hasTrailing: true,
                                                  iconData: Icons.close,
                                                  onTrailingTap: (x) async {
                                                    await _collectionNotifier.removeFromCollection(
                                                        title, x);
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }, mobileBuilder: (x) {
                                        return Material(
                                          color: Colors.transparent,
                                          child: Column(
                                            children: [
                                              AppBar(
                                                backgroundColor: Colors.transparent,
                                                title: Text('$title'),
                                              ),
                                              Expanded(
                                                child: WordListBuilder(
                                                  words: words,
                                                  hasTrailing: true,
                                                  iconData: Icons.close,
                                                  onTrailingTap: (x) async {
                                                    await _collectionNotifier.removeFromCollection(
                                                        title, x);
                                                    setState(() {});
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }));
                                },
                                trailing: IconButton(
                                    onPressed: () {
                                      _collectionNotifier.togglePin(title);
                                    },
                                    icon: Icon(
                                      Icons.push_pin,
                                      color: Colors.white54,
                                    ))),
                          );
                        }),
              ],
            ),
          );
  }
}

/// Shared rounded, tappable card surface — consistent radius, ink ripple,
/// and padding across the dashboard cards.
class _CardShell extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  final Gradient? gradient;
  final Color? color;
  final BoxBorder? border;

  const _CardShell({
    required this.child,
    required this.onTap,
    this.gradient,
    this.color,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: gradient,
            color: color,
            border: border,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(padding: const EdgeInsets.all(18), child: child),
        ),
      ),
    );
  }
}

/// Hero card: the current word of the day with a preview of its meaning.
class WordOfTheDayCard extends StatelessWidget {
  final Word word;
  final VoidCallback onTap;
  final bool isError;

  const WordOfTheDayCard({
    super.key,
    required this.word,
    required this.onTap,
    this.isError = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasWord = word.word.isNotEmpty && !isError;
    return _CardShell(
      onTap: onTap,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isError
            ? const [Color(0xFF7A2E2E), Color(0xFF4A1414)]
            : const [Color(0xFF2E7D5B), Color(0xFF14382A)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                'WORD OF THE DAY',
                style: GoogleFonts.quicksand(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              const Spacer(),
              Icon(Icons.north_east_rounded, size: 18, color: Colors.white.withValues(alpha: 0.75)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hasWord ? word.word.toUpperCase() : 'Tap to retry',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.quicksand(
                fontSize: 30, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            hasWord ? word.meaning : 'Something went wrong. Pull down to refresh or tap to retry.',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.quicksand(
              fontSize: 14,
              height: 1.35,
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compact stat tile: an accent icon, a live count, and a label. Used for
/// Bookmarks and Mastered words.
class DashboardTile extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final int count;
  final VoidCallback onTap;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _CardShell(
      onTap: onTap,
      color: colorScheme.surfaceContainerHighest,
      border: Border.all(color: colorScheme.outlineVariant),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            '$count',
            style: GoogleFonts.quicksand(
              fontSize: 30,
              height: 1.0,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.quicksand(
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// The Bookmarks + Mastered stat tiles, side by side and equal height. Counts
/// come from [wordTrackingProvider] so they're live for guests (local) and
/// members (Supabase) alike.
class _StatTilesRow extends ConsumerWidget {
  final UserModel user;
  final bool useOpenContainer;
  const _StatTilesRow({required this.user, this.useOpenContainer = false});

  Widget _tile({
    required BuildContext context,
    required IconData icon,
    required Color accent,
    required String title,
    required int count,
    required Widget destination,
  }) {
    if (useOpenContainer) {
      return OpenContainer<bool>(
        tappable: false,
        closedElevation: 0,
        middleColor: Colors.transparent,
        openColor: Colors.transparent,
        closedColor: Colors.transparent,
        closedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        transitionType: ContainerTransitionType.fadeThrough,
        openBuilder: (context, _) => destination,
        closedBuilder: (context, open) =>
            DashboardTile(icon: icon, accent: accent, title: title, count: count, onTap: open),
      );
    }
    return DashboardTile(
      icon: icon,
      accent: accent,
      title: title,
      count: count,
      onTap: () => Navigate.push(context, destination),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(wordTrackingProvider);
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _tile(
              context: context,
              icon: Icons.bookmark_rounded,
              accent: const Color(0xFFF0A202),
              title: 'Bookmarks',
              count: tracking.bookmarkedCount,
              destination: BookmarksPage(isBookMark: true, user: user),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _tile(
              context: context,
              icon: Icons.workspace_premium_rounded,
              accent: const Color(0xFF6C63FF),
              title: 'Mastered',
              count: tracking.masteredCount,
              destination: BookmarksPage(isBookMark: false, user: user),
            ),
          ),
        ],
      ),
    );
  }
}

/// Guest-only nudge: surfaces how many words are tracked on-device and invites
/// sign-in to sync. Shown once the user has something worth saving (or a gentle
/// prompt otherwise).
class _SyncBanner extends ConsumerWidget {
  const _SyncBanner();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tracking = ref.watch(wordTrackingProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final total = tracking.bookmarkedCount + tracking.masteredCount;
    final message = total > 0
        ? "You're tracking $total ${total == 1 ? 'word' : 'words'} on this device — sign in to sync everywhere."
        : 'Sign in to save your progress across devices.';
    return _CardShell(
      onTap: () => Navigate.push(context, AppSignIn()),
      color: colorScheme.primaryContainer,
      child: Row(
        children: [
          Icon(Icons.cloud_sync_rounded, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.quicksand(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Sign in',
            style: GoogleFonts.quicksand(
              fontWeight: FontWeight.w700,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class DashboardDesktop extends ConsumerWidget {
  static String route = '/';
  const DashboardDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final dashBoardRef = ref.watch(dashBoardNotifier);
    final colorScheme = Theme.of(context).colorScheme;
    final word = dashboardController.wordOfTheDay;
    final user = ref.watch(userNotifierProvider);
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Padding(
        padding: 16.0.horizontalPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 3,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 680),
                      child: ListView(children: [
                        Padding(
                          padding: 16.0.verticalPadding,
                          child: heading('Word of the day'),
                        ),
                        OpenContainer<bool>(
                          tappable: false,
                          closedElevation: 0,
                          middleColor: Colors.transparent,
                          openColor: Colors.transparent,
                          closedColor: Colors.transparent,
                          closedShape:
                              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          transitionType: ContainerTransitionType.fadeThrough,
                          openBuilder: (context, _) =>
                              WordDetail(word: word, isWod: true, title: 'Word of the Day'),
                          closedBuilder: (context, open) => WordOfTheDayCard(
                            word: word,
                            isError: word.word.isEmpty,
                            onTap: open,
                          ),
                        ),
                        Padding(
                          padding: 12.0.verticalPadding,
                          child: heading('Progress'),
                        ),
                        Padding(
                          padding: 6.0.verticalPadding + 8.0.bottomPadding,
                          child: DashboardCollections(),
                        ),
                        _StatTilesRow(user: user, useOpenContainer: true),
                        if (!user.isLoggedIn) ...[
                          16.0.vSpacer(),
                          const _SyncBanner(),
                        ],
                        16.0.vSpacer()
                      ]),
                    ),
                  ),
                )),
            // Nested navigator so tapping a notification opens its detail
            // *inside* this panel (same width) instead of over the whole app.
            Expanded(
              flex: 2,
              child: Navigator(
                onGenerateRoute: (_) =>
                    MaterialPageRoute(builder: (_) => const NotificationsMobile()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
