import 'dart:math';

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
    Widget heading(String title) {
      return Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      );
    }

    if (word == null) {
      return LoadingWidget();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
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
              : SizedBox(),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: 16.0.horizontalPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: 16.0.verticalPadding,
                child: heading('Word of the day'),
              ),
              WoDCard(
                word: word,
                onTap: () {
                  Navigate.push(context, WordDetail(word: word));
                },
                title: '${word.word}',
              ),
              Padding(
                padding: 6.0.verticalPadding,
              ),
              !user.isLoggedIn
                  ? SizedBox.shrink()
                  : Column(
                      children: [
                        WoDCard(
                          word: word,
                          height: 180,
                          color: Colors.blue.shade400,
                          onTap: () {
                            Navigate.push(
                                context,
                                BookmarksPage(
                                  isBookMark: true,
                                  user: user,
                                ));
                          },
                          title: 'Bookmarks',
                        ),
                        Padding(
                          padding: 6.0.verticalPadding,
                        ),
                        WoDCard(
                          word: word,
                          height: 180,
                          color: Colors.blue.shade400,
                          onTap: () {
                            Navigate.push(
                                context,
                                BookmarksPage(
                                  isBookMark: false,
                                  user: user,
                                ));
                          },
                          title: 'Mastered Words',
                        ),
                      ],
                    ),
              SizedBox(
                height: 100,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WoDCard extends StatelessWidget {
  final Word? word;
  final String title;
  final Color? color;
  final Function? onTap;
  final double? height;

  const WoDCard(
      {super.key,
      this.word,
      this.height,
      required this.title,
      this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Card(
      elevation: 2.0,
      shape: 16.0.rounded,
      color: this.color ?? Colors.green.shade300,
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!();
          }
        },
        child: Container(
          height: height ?? size.height / 3,
          width: size.width,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Align(
              alignment: Alignment.center,
              child: Text(
                '$title',
                textAlign: TextAlign.center,
                style: VocabTheme.googleFontsTextTheme.headline2,
              )),
        ),
      ),
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
