import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/controller/app_controller.dart';
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
              return ResponsiveBuilder(
                desktopBuilder: (context) => DashboardDesktop(),
                mobileBuilder: (context) {
                  if (response.state == RequestState.active) {
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
    return CustomScrollView(
      scrollBehavior: const MaterialScrollBehavior().copyWith(overscroll: true),
      physics: BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      slivers: <Widget>[
        SliverAppBar(
            pinned: false,
            expandedHeight: 80.0,
            flexibleSpace: FlexibleSpaceBar(
              centerTitle: true,
              background: Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(left: 16, top: 16),
                child: Text(
                  'Dashboard',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w400),
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
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.6),
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
                OpenContainer<bool>(
                    openBuilder: (BuildContext context, VoidCallback openContainer) {
                      return WordDetail(
                        word: word,
                        isWod: true,
                        title: 'Word of the Day',
                      );
                    },
                    tappable: true,
                    closedShape: 16.0.rounded,
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedBuilder: (BuildContext context, VoidCallback openContainer) {
                      return word.word.isEmpty
                          ? GestureDetector(
                              onTap: () {
                                onRefresh!();
                              },
                              child: WoDCard(
                                  title: 'Tap to Retry',
                                  description: 'Something went wrong!',
                                  color: Colors.red.shade300,
                                  word: word,
                                  height: 180,
                                  fontSize: 42),
                            )
                          : WoDCard(
                              word: word,
                              color: Colors.green.shade300,
                              title: '${word.word}'.toUpperCase(),
                            );
                    }),
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
                          word.word.isEmpty
                              ? SizedBox.shrink()
                              : OpenContainer<bool>(
                                  openBuilder: (BuildContext context, VoidCallback openContainer) {
                                    return BookmarksPage(
                                      isBookMark: true,
                                      user: user,
                                    );
                                  },
                                  closedShape: 16.0.rounded,
                                  tappable: true,
                                  transitionType: ContainerTransitionType.fadeThrough,
                                  closedBuilder:
                                      (BuildContext context, VoidCallback openContainer) {
                                    return WoDCard(
                                      word: word,
                                      height: 180,
                                      fontSize: 42,
                                      color: Colors.amber.shade600,
                                      title: 'Bookmarks',
                                    );
                                  }),
                          Padding(
                            padding: 6.0.verticalPadding,
                          ),
                          OpenContainer<bool>(
                              openBuilder: (BuildContext context, VoidCallback openContainer) {
                                return BookmarksPage(
                                  isBookMark: false,
                                  user: user,
                                );
                              },
                              tappable: true,
                              closedShape: 16.0.rounded,
                              transitionType: ContainerTransitionType.fadeThrough,
                              closedBuilder: (BuildContext context, VoidCallback openContainer) {
                                return WoDCard(
                                  word: word,
                                  height: 180,
                                  fontSize: 42,
                                  color: Colors.black,
                                  image: 'assets/dart.jpg',
                                  title: 'Mastered\nWords',
                                );
                              })
                        ],
                      ),
                100.0.vSpacer()
              ],
            ),
          ),
        )
      ],
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
        : Card(
            borderOnForeground: true,
            color: colorScheme.surfaceTint,
            child: Container(
              padding: 8.0.allPadding,
              // height: size.height / 3.5,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: 12.0.verticalPadding + 8.0.leftPadding,
                    child: Row(
                      children: [
                        Expanded(
                            child: heading('Pinned Collections', color: colorScheme.onPrimary)),
                        IconButton(
                            onPressed: () async {
                              final AppController state = ref.read(appNotifier.notifier).state;
                              ref.watch(appNotifier.notifier).state =
                                  state.copyWith(showFAB: false);
                              NavbarNotifier.hideBottomNavBar = true;
                              await showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return DraggableScrollableSheet(
                                        maxChildSize: 0.6,
                                        initialChildSize: 0.6,
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
                              ref.watch(appNotifier.notifier).state = state.copyWith(showFAB: true);
                              NavbarNotifier.hideBottomNavBar = false;
                            },
                            icon: Icon(
                              Icons.add,
                              color: colorScheme.onPrimary,
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
                                        Scaffold(
                                          backgroundColor:
                                              Theme.of(context).colorScheme.surfaceVariant,
                                          appBar: AppBar(
                                            title: Text('$title'),
                                          ),
                                          body: WordListBuilder(
                                            words: words,
                                            hasTrailing: true,
                                            iconData: Icons.close,
                                            onTrailingTap: (x) async {
                                              await _collectionNotifier.removeFromCollection(
                                                  title, x);
                                              setState(() {});
                                            },
                                          ),
                                        ));
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
            ),
          );
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
    final word = dashboardController.wordOfTheDay;
    final user = ref.watch(userNotifierProvider);
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: Padding(
        padding: 16.0.horizontalPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                flex: 3,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: 16.0.verticalPadding,
                    child: heading('Word of the day'),
                  ),
                  OpenContainer<bool>(
                      openBuilder: (BuildContext context, VoidCallback openContainer) {
                        return WordDetail(
                          word: word,
                          isWod: true,
                          title: 'Word of the Day',
                        );
                      },
                      tappable: true,
                      closedShape: 16.0.rounded,
                      transitionType: ContainerTransitionType.fadeThrough,
                      closedBuilder: (BuildContext context, VoidCallback openContainer) {
                        return WoDCard(
                          word: word,
                          color: Colors.green.shade300,
                          title: '${word.word}'.toUpperCase(),
                        );
                      }),
                  Padding(
                    padding: 12.0.verticalPadding,
                    child: heading('Progress'),
                  ),
                  Padding(
                    padding: 6.0.verticalPadding,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: OpenContainer<bool>(
                            openBuilder: (BuildContext context, VoidCallback openContainer) {
                              return BookmarksPage(
                                isBookMark: false,
                                user: user,
                              );
                            },
                            tappable: true,
                            closedShape: 16.0.rounded,
                            transitionType: ContainerTransitionType.fadeThrough,
                            closedBuilder: (BuildContext context, VoidCallback openContainer) {
                              return WoDCard(
                                word: word,
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
                            openBuilder: (BuildContext context, VoidCallback openContainer) {
                              return BookmarksPage(
                                isBookMark: true,
                                user: user,
                              );
                            },
                            closedShape: 16.0.rounded,
                            tappable: true,
                            transitionType: ContainerTransitionType.fadeThrough,
                            closedBuilder: (BuildContext context, VoidCallback openContainer) {
                              return WoDCard(
                                word: word,
                                height: 180,
                                fontSize: 42,
                                color: Colors.amberAccent.shade400,
                                title: 'Bookmarks',
                              );
                            }),
                      ),
                    ],
                  )
                ])
                //  Container(
                //   alignment: Alignment.center,
                //   child: SizedBox(
                //     width: 600,
                //     child: DashboardMobile(),
                //   ),
                ),
            Expanded(flex: 2, child: Notifications()),
          ],
        ),
      ),
    );
  }
}
