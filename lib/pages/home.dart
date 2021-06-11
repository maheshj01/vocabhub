import 'package:flutter/material.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:vocabhub/services/supastore.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/drawer.dart';
import 'package:vocabhub/widgets/search.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/worddetail.dart';
import 'package:vocabhub/widgets/wordtile.dart';

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
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    return LayoutBuilder(builder: (_, constraints) {
      Widget actionIcon(IconData data, String url, {String toolTip = ''}) {
        return constraints.maxWidth <= MOBILE_WIDTH
            ? Container()
            : IconButton(
                tooltip: toolTip,
                icon: Icon(
                  data,
                  color: isDark ? Colors.white : Colors.black.withOpacity(0.75),
                ),
                onPressed: () {
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
            constraints.maxWidth <= MOBILE_WIDTH
                ? Container()
                : IconButton(
                    icon: Image.asset(
                      !isDark
                          ? '$GITHUB_ASSET_PATH'
                          : '$GITHUB_WHITE_ASSET_PATH',
                      scale: 2.0,
                    ),
                    tooltip: 'Github',
                    onPressed: () {
                      launchUrl(SOURCE_CODE_URL, isNewTab: true);
                    },
                  ),
            actionIcon(Icons.insert_drive_file, SHEET_URL,
                toolTip: 'Contribute'),
            actionIcon(Icons.help, REPORT_URL, toolTip: 'Report'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            darkNotifier.value = !darkNotifier.value;
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
  }

  List<Word> supaStoreWords = [];
  final ValueNotifier<List<Word>?> listNotifier = ValueNotifier<List<Word>>([]);
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
          return Column(
            children: [
              SearchBuilder(
                onChanged: (x) {
                  if (x.isEmpty) {
                    listNotifier.value = supaStoreWords;
                    return;
                  }
                  List<Word> result = [];
                  supaStoreWords.forEach((element) {
                    if (element.word.toLowerCase().contains(x.toLowerCase()) ||
                        element.meaning
                            .toLowerCase()
                            .contains(x.toLowerCase())) {
                      result.add(element);
                    }
                  });
                  listNotifier.value = result;
                },
              ),
              Expanded(
                child: Scrollbar(
                  radius: Radius.circular(2.0),
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
            ],
          );
        });
  }
}

// class SplashScreen extends StatefulWidget {
//   const SplashScreen({Key? key}) : super(key: key);

//   @override
//   _SplashScreenState createState() => _SplashScreenState();
// }

// class _SplashScreenState extends State<SplashScreen>
//     with SingleTickerProviderStateMixin {
//   List<Word> words = [
//     Word("1", "Hello", "Meaning"),
//     Word("12", "Frantic", "Meaning"),
//     Word("1234", "Fervid", "Meaning"),
//     Word("2341", "Pusillanimous", "Meaning"),
//     Word("dsdf1", "Ardent", "Meaning"),
//     Word("sdfsdf1", "Grandiloquent", "Meaning"),
//     Word("sdfds1", "Malevolent", "Meaning"),
//     Word("1sdfs", "Loquacious", "Meaning"),
//     Word("fdgdf1", "Servile", "Meaning"),
//     Word("dfgfdg1", "Obnoxious", "Meaning"),
//     Word("1dfgfdg", "Saggacious", "Meaning"),
//     Word("fdgdsf1", "Scoundrel", "Meaning"),
//     Word("1dfgdf", "Panacea", "Meaning"),
//   ];
//   late AnimationController _animationController;
//   late Animation _animation;

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     _animationController =
//         AnimationController(vsync: this, duration: Duration(seconds: 10));
//     dx = List.generate(15, (index) => 30.0 * index).toList();
//     dy = List.generate(20, (index) => 15.0 * index).toList();
//   }

//   List<double> dx = [];
//   List<double> dy = [];
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     int len = words.length;
//     return Stack(alignment: Alignment.center, children: [
//       for (int i = 0; i < 25; i++)
//         // Positioned(
//         //   top: dy[Random().nextInt(20)],
//         //   left: dx[Random().nextInt(15) % 14],
//         Align(
//           alignment: Alignment(
//             Random().nextDouble() - 0.2,
//             Random().nextDouble() - 0.2,
//           ),
//           child: TweenAnimationBuilder<double>(
//               tween: Tween(begin: 0.0, end: 3.0),
//               duration: Duration(seconds: 10),
//               builder: (BuildContext context, double value, Widget? child) {
//                 return Transform.scale(
//                   scale: value * i / 100,
//                   child: Text(
//                     words[i % len].word,
//                     style: TextStyle(fontSize: 10),
//                   ),
//                 );
//               }),
//         )
//     ]);
//   }
// }
