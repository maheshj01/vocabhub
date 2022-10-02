import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/navbar/notifications/notifications.dart';
import 'package:vocabhub/pages/bookmarks.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services/database.dart';
import 'package:vocabhub/services/services/vocabstore.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/worddetail.dart';

class Dashboard extends StatefulWidget {
  static String route = '/';
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    super.initState();
    publishWordOfTheDay();
  }

  /// get latest word of the day sort by descending order of created_at
  /// check current DateTime UTC and compare with the latest word of the day
  /// if the date is same, then don't publish a new word of the day
  /// else publish a new word of the day

  /// todo word of the day
  Future<void> publishWordOfTheDay() async {
    final Word word = await VocabStoreService.getLastUpdatedRecord();
    final state = AppStateWidget.of(context);
    final now = DateTime.now().toUtc();
    if (now.difference(word.created_at!.toUtc()).inHours > 24) {
      final allWords = await VocabStoreService.getAllWords();
      final random = Random();
      final randomWord = allWords[random.nextInt(allWords.length)];
      if (randomWord != null) {
        final wordOfTheDay = {
          'word': randomWord.word,
          'id': randomWord.id,
          'created_at': now.toIso8601String()
        };
        final resp = await DatabaseService.insertIntoTable(
          wordOfTheDay,
          table: WORD_OF_THE_DAY_TABLE_NAME,
        );
        if (resp.status == 201) {
          print('word of the day published');
          state.setWordOfTheDay(randomWord);
        } else {
          throw Exception('word of the day not published');
        }
      }
    } else {
      state.setWordOfTheDay(word);
      print('word of the day already published');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
        child: ResponsiveBuilder(
      desktopBuilder: (context) => DashboardDesktop(),
      mobileBuilder: (context) => DashboardMobile(),
    ));
  }
}

class DashboardMobile extends StatelessWidget {
  static String route = '/';
  const DashboardMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = AppStateScope.of(context).user;
    final word = AppStateScope.of(context).wordOfTheDay;

    if (word == null) {
      return LoadingWidget();
    }

    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
            pinned: false,
            expandedHeight: 80.0,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Dashboard',
                style: VocabTheme.googleFontsTextTheme.subtitle2!
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            actions: [
              user!.isLoggedIn
                  ? IconButton(
                      onPressed: () {
                        navigate(context, Notifications.route,
                            isRootNavigator: false);
                      },
                      icon: Icon(
                        Icons.notifications_on,
                        color: VocabTheme.primaryColor,
                      ))
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
                    openBuilder:
                        (BuildContext context, VoidCallback openContainer) {
                      return WordDetail(word: word);
                    },
                    tappable: true,
                    closedShape: 16.0.rounded,
                    transitionType: ContainerTransitionType.fadeThrough,
                    closedBuilder:
                        (BuildContext context, VoidCallback openContainer) {
                      return WoDCard(
                        word: word,
                        color: Colors.green.shade300,
                        title: '${word.word}',
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
                          OpenContainer<bool>(
                              openBuilder: (BuildContext context,
                                  VoidCallback openContainer) {
                                return BookmarksPage(
                                  isBookMark: true,
                                  user: user,
                                );
                              },
                              closedShape: 16.0.rounded,
                              tappable: true,
                              transitionType:
                                  ContainerTransitionType.fadeThrough,
                              closedBuilder: (BuildContext context,
                                  VoidCallback openContainer) {
                                return WoDCard(
                                  word: word,
                                  height: 180,
                                  color: Colors.amberAccent.shade400,
                                  title: 'Bookmarks',
                                );
                              }),
                          Padding(
                            padding: 6.0.verticalPadding,
                          ),
                          OpenContainer<bool>(
                              openBuilder: (BuildContext context,
                                  VoidCallback openContainer) {
                                return BookmarksPage(
                                  isBookMark: false,
                                  user: user,
                                );
                              },
                              tappable: true,
                              closedShape: 16.0.rounded,
                              transitionType:
                                  ContainerTransitionType.fadeThrough,
                              closedBuilder: (BuildContext context,
                                  VoidCallback openContainer) {
                                return WoDCard(
                                  word: word,
                                  height: 180,
                                  image: 'assets/dart.jpg',
                                  title: 'Mastered Words',
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

class WoDCard extends StatelessWidget {
  final Word? word;
  final String title;
  final Color? color;
  final double? height;
  final String? image;

  const WoDCard(
      {super.key,
      this.word,
      this.height,
      required this.title,
      this.color,
      this.image});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Container(
      height: height ?? size.height / 3,
      width: size.width,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          color: this.color,
          image: image != null
              ? DecorationImage(
                  fit: BoxFit.fill,
                  opacity: 0.7,
                  image: AssetImage('assets/dart.jpg'))
              : null),
      child: Align(
          alignment: Alignment.center,
          child: Text(
            '$title',
            textAlign: TextAlign.center,
            style: VocabTheme.googleFontsTextTheme.headline2,
          )),
    );
  }
}

class DashboardDesktop extends StatelessWidget {
  static String route = '/';
  const DashboardDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              children: [
                Center(
                  child: Text('Dashboard Desktop'),
                ),
              ],
            ),
          ),
          SizedBox(
              height: SizeUtils.size.height * 0.5,
              width: 400,
              child: Column(
                children: [
                  Expanded(child: Notifications()),
                ],
              ))
        ],
      ),
    );
  }
}
