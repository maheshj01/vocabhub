import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/supastore.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/settings.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/drawer.dart';
import 'package:vocabhub/widgets/search.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/worddetail.dart';
import 'package:vocabhub/widgets/wordtile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

TextEditingController searchController = TextEditingController();

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String query = '';
  Word? selected;

  @override
  void initState() {
    super.initState();
    firebaseAnalytics = Analytics();
    SharedPreferences.getInstance().then((value) {
      sharedPreferences = value;
    });
    userProvider = Provider.of<User>(context, listen: false);
    if (userProvider.isLoggedIn) {
      actions.add('Logout');
      // TODO: fetch loggedIn user details
    } else {
      actions.add('Sign In');
    }
  }

  void _openCustomDialog() {
    showGeneralDialog(
        barrierColor: Colors.black.withOpacity(0.5),
        transitionBuilder: (context, a1, a2, widget) {
          return Transform.translate(
              offset: Offset(0, 100 * a1.value), child: AddWordForm());
        },
        transitionDuration: Duration(milliseconds: 500),
        barrierDismissible: true,
        barrierLabel: '',
        context: context,
        pageBuilder: (context, animation1, animation2) {
          return Container();
        });
  }

  Widget _buildNewTransition(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return Transform.translate(
      offset: Offset(0, animation.value * -50),
      child: child,
    );
  }

  Future<void> _select(String text) async {
    if (text.toLowerCase() == 'add word') {
      await Navigate().push(context, AddWordForm(),
          slideTransitionType: SlideTransitionType.btt);
    } else if (text.toLowerCase() == 'logout') {
      /// TODO : logout signed user

    } else if (text.toLowerCase() == 'sign in') {
      Navigate().pushAndPopAll(context, AppSignIn(),
          slideTransitionType: SlideTransitionType.btt);
    } else {
      String url = '';
      switch (text.toLowerCase()) {
        case 'source code':
          url = '$SOURCE_CODE_URL';
          break;
        case 'privacy policy':
          url = '$PRIVACY_POLICY';
          break;
        case 'report':
          url = '$REPORT_URL';
          break;
        default:
          url = '$SOURCE_CODE_URL';
      }
      await launchUrl(url);
    }
  }

  SupaStore supaStore = SupaStore();
  late Analytics firebaseAnalytics;
  late SharedPreferences sharedPreferences;
  List<String> actions = [
    'Add word',
    'Source code',
    'Privacy Policy',
    'Report',
  ];
  late User userProvider;
  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    return LayoutBuilder(builder: (_, constraints) {
      Widget actionWidget(String text, String url,
          {String toolTip = '', Function? onTap}) {
        return constraints.maxWidth <= MOBILE_WIDTH
            ? Container()
            : InkWell(
                onTap: onTap != null
                    ? () => onTap()
                    : () {
                        launchUrl(url);
                      },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth < TABLET_WIDTH ? 18 : 24,
                      vertical: 4),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Container(
                      alignment: Alignment.center,
                      child: Text(text,
                          style: Theme.of(context)
                              .textTheme
                              .headline5!
                              .copyWith(
                                  color: isDark ? Colors.white : primaryColor,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
              );
      }

      Settings.size = Size(constraints.maxWidth, constraints.minHeight);
      return Scaffold(
        drawer: constraints.maxWidth <= MOBILE_WIDTH
            ? Drawer(
                child: DrawerBuilder(),
              )
            : null,
        appBar: AppBar(
          iconTheme: Theme.of(context).iconTheme,
          centerTitle: constraints.maxWidth <= MOBILE_WIDTH ? true : false,
          title: Text('$APP_TITLE',
              style: Theme.of(context).textTheme.headline4!.copyWith(
                  color: isDark ? Colors.white : primaryColor,
                  fontWeight: FontWeight.bold)),
          actions: [
            constraints.maxWidth < DESKTOP_WIDTH &&
                    constraints.maxWidth > MOBILE_WIDTH
                ? PopupMenuButton<String>(
                    onSelected: (String x) {
                      _select(x);
                    },
                    itemBuilder: (BuildContext context) {
                      return actions.map((String action) {
                        return PopupMenuItem<String>(
                          value: action,
                          child: Text(action),
                        );
                      }).toList();
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Consumer<User>(
                          builder: (BuildContext _, User? user, Widget? child) {
                        if (user == null || user.email.isEmpty)
                          return CircularAvatar(
                            url: '$profileUrl',
                            radius: 25,
                          );
                        else
                          return CircularAvatar(
                            name: getInitial('${user.name}'),
                            radius: 25,
                            onTap: null,
                          );
                      }),
                    ),
                  )
                : Row(
                    children: [
                      actionWidget('Add word', '', toolTip: 'Add a word',
                          onTap: () async {
                        // _openCustomDialog();
                        await Navigate().push(context, AddWordForm(),
                            slideTransitionType: SlideTransitionType.btt);
                      }),
                      actionWidget('source code', SOURCE_CODE_URL,
                          toolTip: 'Source code'),
                      actionWidget('Privacy Policy', PRIVACY_POLICY,
                          toolTip: 'Privacy Policy'),
                      actionWidget('Report', REPORT_URL, toolTip: 'Report'),
                    ],
                  )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            darkNotifier.value = !darkNotifier.value;
            Settings().dark = darkNotifier.value;
          },
          backgroundColor: isDark ? Colors.cyanAccent : primaryColor,
          child: Icon(
              !isDark ? Icons.brightness_2_outlined : Icons.wb_sunny_rounded),
        ),
        body: Row(
          children: [
            constraints.maxWidth > MOBILE_WIDTH
                ? Expanded(
                    flex: constraints.maxWidth < TABLET_WIDTH ? 4 : 3,
                    child: Container(
                      decoration: BoxDecoration(
                          color: isDark
                              ? Colors.grey.withOpacity(0.5)
                              : Colors.white,
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 4,
                                blurRadius: 4,
                                color: Colors.grey.withOpacity(0.2),
                                offset: Offset(1, 0))
                          ]),
                      child: WordsBuilder(
                        onSelect: (x) {
                          setState(() {
                            selected = x;
                          });
                          firebaseAnalytics.logWordSelection(x);
                        },
                      ),
                    ))
                : Container(),
            Expanded(
                flex: 8,
                child: constraints.maxWidth > MOBILE_WIDTH
                    ? WordDetail(
                        word: selected,
                      )
                    : WordsBuilder()),
          ],
        ),
      );
    });
  }
}

class WordsBuilder extends StatefulWidget {
  WordsBuilder({Key? key, this.onSelect}) : super(key: key);
  final Function(Word)? onSelect;

  @override
  _WordsBuilderState createState() => _WordsBuilderState();
}

class _WordsBuilderState extends State<WordsBuilder> {
  SupaStore supaStore = SupaStore();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getWords();
  }

  Future<void> getWords() async {
    await Future.delayed(Duration.zero);
    showCircularIndicator(context);
    supaStoreWords = await supaStore.findByWord("");
    stopCircularIndicator(context);
    listNotifier.value = supaStoreWords;
    totalNotifier.value = supaStoreWords.length;
  }

  Future<void> refresh() async {
    supaStoreWords = await supaStore.findByWord("");
    listNotifier.value = supaStoreWords;
    totalNotifier.value = supaStoreWords.length;
    print('${totalNotifier.value}');
    _refreshController.refreshCompleted();
  }

  bool isInSynonym(String query, List<String>? synonyms) {
    bool result = false;
    if (synonyms == null || synonyms.isEmpty) {
      return result;
    }
    synonyms.forEach((element) {
      if (element.toLowerCase() == query.toLowerCase()) {
        result = true;
      }
    });
    return result;
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<Word> supaStoreWords = [];
  String selectedWord = '';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ValueListenableBuilder<List<Word>?>(
        valueListenable: listNotifier,
        builder: (BuildContext context, List<Word>? value, Widget? child) {
          if (value == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return Container(
            color: darkNotifier.value ? primaryDark : Colors.white,
            child: Column(
              children: [
                SearchBuilder(
                  onShuffle: () {
                    final wordList = listNotifier.value;
                    wordList!.shuffle(Random());
                    setState(() {});
                  },
                  onChanged: (x) {
                    if (x.isEmpty) {
                      listNotifier.value = supaStoreWords;
                      return;
                    }
                    List<Word> result = [];
                    supaStoreWords.forEach((element) {
                      if (element.word
                              .toLowerCase()
                              .contains(x.toLowerCase()) ||
                          element.meaning
                              .toLowerCase()
                              .contains(x.toLowerCase()) ||
                          isInSynonym(x, element.synonyms)) {
                        result.add(element);
                      }
                    });
                    listNotifier.value = result;
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => FocusScope.of(context).unfocus(),
                    child: SmartRefresher(
                      enablePullDown: size.width > MOBILE_WIDTH ? false : true,
                      enablePullUp: false,
                      controller: _refreshController,
                      onRefresh: () => refresh(),
                      child: ListView.builder(
                          itemCount: value.length,
                          itemBuilder: (_, x) {
                            return WordTile(
                                word: value[x],
                                isMobile: size.width <= MOBILE_WIDTH,
                                isSelected: selectedWord.toLowerCase() ==
                                    value[x].word.toLowerCase(),
                                onSelect: (word) {
                                  setState(() {
                                    selectedWord = word.word;
                                  });
                                  widget.onSelect!(word);
                                });
                          }),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
