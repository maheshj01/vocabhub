import 'package:flutter/material.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:vocabhub/services/supastore.dart';
import 'package:vocabhub/widgets/search.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/worddetail.dart';
import 'package:vocabhub/widgets/wordtile.dart';

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
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Row(
          children: [
            constraints.maxWidth > MOBILE_WIDTH
                ? Expanded(
                    flex: 2,
                    child: ListBuilder(
                      onSelect: (x) {
                        setState(() {
                          selected = x;
                        });
                      },
                    ))
                : Container(),
            Container(
              width: 0.5,
              color: Colors.grey.withOpacity(0.5),
            ),
            Expanded(
                flex: 6,
                child: constraints.maxWidth > MOBILE_WIDTH
                    ? WordDetail(
                        word: selected,
                      )
                    : ListBuilder()),
          ],
        ),
      );
    });
  }
}

class ListBuilder extends StatefulWidget {
  ListBuilder({Key? key, this.onSelect}) : super(key: key);
  final Function(Word)? onSelect;

  @override
  _ListBuilderState createState() => _ListBuilderState();
}

class _ListBuilderState extends State<ListBuilder> {
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
                    if (element.word.toLowerCase().contains(x.toLowerCase())) {
                      result.add(element);
                    }
                  });
                  listNotifier.value = result;
                },
              ),
              Expanded(
                child: ListView.builder(
                    itemCount: value.length,
                    itemBuilder: (_, x) {
                      return WordTile(
                          word: value[x],
                          isMobile: size.width < MOBILE_WIDTH,
                          onSelect: (word) => widget.onSelect!(word));
                    }),
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
