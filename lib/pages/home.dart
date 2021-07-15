import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/supastore.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/settings.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/drawer.dart';
import 'package:vocabhub/widgets/search.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/worddetail.dart';
import 'package:vocabhub/widgets/wordtile.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  void dispose() {
    // TODO: implement dispose
    darkNotifier.dispose();
    totalNotifier.dispose();
    searchController.dispose();
    listNotifier.dispose();
    super.dispose();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    firebaseAnalytics = Analytics();
    SharedPreferences.getInstance().then((value) {
      sharedPreferences = value;
    });
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

  late Analytics firebaseAnalytics;
  late SharedPreferences sharedPreferences;
  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    return LayoutBuilder(builder: (_, constraints) {
      Widget actionIcon(IconData data, String url,
          {String toolTip = '', Function? onTap}) {
        return constraints.maxWidth <= MOBILE_WIDTH
            ? Container()
            : IconButton(
                tooltip: toolTip,
                icon: Icon(
                  data,
                  color: isDark ? Colors.white : Colors.black.withOpacity(0.75),
                ),
                onPressed: onTap != null
                    ? () => onTap()
                    : () {
                        launchUrl(url);
                      });
      }

      return Scaffold(
        drawer: constraints.maxWidth <= MOBILE_WIDTH
            ? Drawer(
                child: DrawerBuilder(),
              )
            : null,
        appBar: AppBar(
          backgroundColor: isDark ? null : Colors.white,
          iconTheme: Theme.of(context).iconTheme,
          centerTitle: constraints.maxWidth <= MOBILE_WIDTH ? true : false,
          title: Text(
            '$APP_TITLE',
            style: TextStyle(color: isDark ? Colors.white : primaryColor),
          ),
          actions: [
            actionIcon(Icons.add, '', toolTip: 'Add a word', onTap: () {
              // _openCustomDialog();
              navigate(context, AddWordForm(), type: SlideTransitionType.btt);
            }),
            constraints.maxWidth <= MOBILE_WIDTH
                ? Container()
                : IconButton(
                    icon: Image.asset(
                      !isDark
                          ? '$GITHUB_ASSET_PATH'
                          : '$GITHUB_WHITE_ASSET_PATH',
                      height: isDark ? 26 : 35,
                    ),
                    tooltip: 'Github',
                    padding: EdgeInsets.zero,
                    onPressed: () {
                      launchUrl(SOURCE_CODE_URL, isNewTab: true);
                    },
                  ),
            // actionIcon(Icons.insert_drive_file, SHEET_URL,
            //     toolTip: 'Contribute'),
            actionIcon(Icons.bug_report, REPORT_URL, toolTip: 'Report'),
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
                  // TODO: Wrap with scrollbar widget currently it is buggy
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
              ],
            ),
          );
        });
  }
}
