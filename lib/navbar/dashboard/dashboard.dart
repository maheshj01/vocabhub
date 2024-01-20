import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dashboardState = ref.watch(dashboardNotifierProvider);
    final dashboardNotifier = ref.watch(dashboardNotifierProvider.notifier);
    return Material(
        child: dashboardState.when(
            loading: LoadingWidget.new,
            error: (error, x) => ErrorPage(
                  onRetry: () async {
                    await dashboardNotifier.init();
                  },
                  errorMessage: error.toString(),
                ),
            data: (dashboard) {
              return ResponsiveBuilder(
                desktopBuilder: (context) => DashboardDesktop(),
                mobileBuilder: (context) {
                  return RefreshIndicator(onRefresh: () async {
                    await dashboardNotifier.init();
                  }, child: DashboardMobile(
                    onRefresh: () async {
                      await dashboardNotifier.init();
                    },
                  ));
                },
              );
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
    final user = ref.watch(userNotifierProvider).value;
    final dashboardState = ref.watch(dashboardNotifierProvider).value;
    final wod = dashboardState!.wordOfTheDay;
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
                user!.isLoggedIn && SizeUtils.isMobile
                    ? IconButton(
                        onPressed: () {
                          Navigate.pushNamed(context, Notifications.route, isRootNavigator: true);
                        },
                        icon: Icon(
                          Icons.notifications_on,
                          color: Theme.of(context).colorScheme.surfaceTint,
                        ))
                    : SizedBox.shrink(),
                !user.isLoggedIn
                    ? TextButton(
                        onPressed: () async {
                          await Navigate.pushAndPopAll(context, AppSignIn());
                        },
                        child: Text('Sign In',
                            style: Theme.of(context)
                                .textTheme
                                .bodyLarge!
                                .copyWith(color: Theme.of(context).colorScheme.primary)))
                    : SizedBox.shrink()
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
                  wod!.word.isEmpty
                      ? GestureDetector(
                          onTap: () {
                            onRefresh!();
                          },
                          child: WoDCard(
                              title: 'Tap to Retry',
                              description: 'Something went wrong!',
                              color: Colors.red.shade300,
                              word: wod,
                              height: 180,
                              fontSize: 42),
                        )
                      : GestureDetector(
                          onTap: () {
                            Navigate.push(
                                context,
                                WordDetail(
                                  word: wod,
                                  isWod: true,
                                  title: 'Word of the Day',
                                ));
                          },
                          child: WoDCard(
                            word: wod,
                            height: 180,
                            color: Colors.green.shade300,
                            title: '${wod.word}'.toUpperCase(),
                          ),
                        ),
                  Padding(
                    padding: 6.0.verticalPadding,
                  ),
                  !user.isLoggedIn
                      ? SizedBox.shrink()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: 12.0.verticalPadding,
                              child: heading('Progress'),
                            ),
                            DashboardCollections(),
                            16.0.vSpacer(),
                            wod.word.isEmpty
                                ? SizedBox.shrink()
                                : GestureDetector(
                                    onTap: () {
                                      Navigate.push(
                                          context,
                                          BookmarksPage(
                                            isBookMark: true,
                                            user: user,
                                          ));
                                    },
                                    child: WoDCard(
                                      word: wod,
                                      height: 180,
                                      fontSize: 42,
                                      color: Colors.amber.shade600,
                                      title: 'Bookmarks',
                                    ),
                                  ),
                            Padding(
                              padding: 6.0.verticalPadding,
                            ),
                            GestureDetector(
                                onTap: () {
                                  Navigate.push(
                                      context,
                                      BookmarksPage(
                                        isBookMark: false,
                                        user: user,
                                      ));
                                },
                                child: WoDCard(
                                  word: wod,
                                  height: 180,
                                  fontSize: 42,
                                  color: Colors.black,
                                  image: 'assets/dart.jpg',
                                  title: 'Mastered\nWords',
                                ))
                          ],
                        ),
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
    final collectionsProvider = ref.watch(collectionNotifierProvider);
    final collectionsNotifier = ref.watch(collectionNotifierProvider.notifier);
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    return collectionsProvider.when(
        data: (collections) {
          return !hasPinned(collections)
              ? SizedBox.shrink()
              : Container(
                  padding: 8.0.allPadding,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [colorScheme.background, colorScheme.surfaceVariant]),
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
                                                borderRadius: BorderRadius.vertical(
                                                    top: Radius.circular(28.0)),
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
                                                          await collectionsNotifier
                                                              .removeFromCollection(title, x);
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
                                                          await collectionsNotifier
                                                              .removeFromCollection(title, x);
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
                                            collectionsNotifier.togglePin(title);
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
        },
        error: (e, y) {
          return Center(child: Text("Failed to load collections"));
        },
        loading: SizedBox.shrink);
  }
}

class WoDCard extends StatelessWidget {
  final Word? word;
  final String title;
  final Color? color;
  final double? height;
  final double? width;
  final String? image;
  final String? description;
  final double fontSize;

  const WoDCard(
      {super.key,
      this.word,
      this.height,
      this.width,
      required this.title,
      this.color,
      this.description,
      this.fontSize = 40,
      this.image});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: height ?? size.height / 3,
      width: width ?? size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: this.color,
          image: image != null
              ? DecorationImage(
                  fit: BoxFit.fill, opacity: 0.9, image: AssetImage('assets/dart.jpg'))
              : null),
      child: Align(
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$title',
                textAlign: TextAlign.center,
                style: Theme.of(context)
                    .textTheme
                    .displaySmall!
                    .copyWith(color: Theme.of(context).colorScheme.onPrimary, fontSize: fontSize),
              ),
              description != null
                  ? Text(
                      '$description',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium!
                          .copyWith(color: Theme.of(context).colorScheme.onPrimary),
                    )
                  : SizedBox.shrink()
            ],
          )),
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
    final dashboardState = ref.read(dashboardNotifierProvider.notifier);
    final wod = dashboardState.stateValue.wordOfTheDay;
    final user = ref.watch(userNotifierProvider).value;
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Padding(
        padding: 16.0.horizontalPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 3,
                child: ScrollConfiguration(
                  behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                  child: ListView(children: [
                    Padding(
                      padding: 16.0.verticalPadding,
                      child: heading('Word of the day'),
                    ),
                    OpenContainer<bool>(
                        openBuilder: (BuildContext context, VoidCallback openContainer) {
                          return WordDetail(
                            word: wod!,
                            isWod: true,
                            title: 'Word of the Day',
                          );
                        },
                        tappable: true,
                        middleColor: Colors.transparent,
                        openColor: Colors.transparent,
                        closedColor: Colors.transparent,
                        closedShape: 16.0.rounded,
                        transitionType: ContainerTransitionType.fadeThrough,
                        closedBuilder: (BuildContext context, VoidCallback openContainer) {
                          return WoDCard(
                            word: wod,
                            color: Colors.green.shade300,
                            title: '${wod!.word}'.toUpperCase(),
                          );
                        }),
                    Padding(
                      padding: 12.0.verticalPadding,
                      child: heading('Progress'),
                    ),
                    Padding(
                      padding: 6.0.verticalPadding + 8.0.bottomPadding,
                      child: DashboardCollections(),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OpenContainer<bool>(
                              openBuilder: (BuildContext context, VoidCallback openContainer) {
                                return BookmarksPage(
                                  isBookMark: false,
                                  user: user!,
                                );
                              },
                              tappable: true,
                              closedColor: Colors.transparent,
                              openColor: Colors.transparent,
                              middleColor: Colors.transparent,
                              closedShape: 16.0.rounded,
                              transitionType: ContainerTransitionType.fadeThrough,
                              closedBuilder: (BuildContext context, VoidCallback openContainer) {
                                return WoDCard(
                                  word: wod,
                                  height: 180,
                                  fontSize: 42,
                                  image: 'assets/dart.jpg',
                                  title: 'Mastered\nWords',
                                );
                              }),
                        ),
                        16.0.hSpacer(),
                        Expanded(
                          child: OpenContainer<bool>(
                              closedColor: Colors.transparent,
                              openColor: Colors.transparent,
                              middleColor: Colors.transparent,
                              openBuilder: (BuildContext context, VoidCallback openContainer) {
                                return BookmarksPage(
                                  isBookMark: true,
                                  user: user!,
                                );
                              },
                              closedShape: 16.0.rounded,
                              tappable: true,
                              transitionType: ContainerTransitionType.fadeThrough,
                              closedBuilder: (BuildContext context, VoidCallback openContainer) {
                                return WoDCard(
                                  word: wod,
                                  height: 180,
                                  fontSize: 42,
                                  color: Colors.amberAccent.shade400,
                                  title: 'Bookmarks',
                                );
                              }),
                        ),
                      ],
                    ),
                    16.0.vSpacer()
                  ]),
                )
                //  Container(
                //   alignment: Alignment.center,
                //   child: SizedBox(
                //     width: 600,
                //     child: DashboardMobile(),
                //   ),
                ),
            Expanded(flex: 2, child: NotificationsMobile()),
          ],
        ),
      ),
    );
  }
}
