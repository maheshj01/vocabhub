import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/examplebuilder.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/synonymslist.dart';
import 'package:vocabhub/widgets/worddetail.dart';

class ExploreWords extends StatefulWidget {
  static const String route = '/';
  const ExploreWords({Key? key}) : super(key: key);

  @override
  State<ExploreWords> createState() => _ExploreWordsState();
}

class _ExploreWordsState extends State<ExploreWords> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => ExploreWordsMobile(),
        mobileBuilder: (context) => ExploreWordsMobile());
  }
}

class ExploreWordsMobile extends StatelessWidget {
  const ExploreWordsMobile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final words = AppStateScope.of(context).words;
    if (words == null || words.isEmpty) return SizedBox.shrink();
    return Material(
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
              itemCount: words.length,
              controller: pageController,
              scrollBehavior: MaterialScrollBehavior(),
              onPageChanged: (x) {
                hideMessage(context);
              },
              physics: ClampingScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return ExploreWord(word: words[index], index: index);
              }),
        ],
      ),
    );
  }
}

PageController pageController = PageController();

// class ExploreWordsDesktop extends StatefulWidget {
//   ExploreWordsDesktop({Key? key}) : super(key: key);

//   @override
//   State<ExploreWordsDesktop> createState() => _ExploreWordsDesktopState();
// }

// class _ExploreWordsDesktopState extends State<ExploreWordsDesktop> {
//   @override
//   Widget build(BuildContext context) {
//     final words = AppStateScope.of(context).words;
//     if (words == null || words.isEmpty) return SizedBox.shrink();
//     print('pageController has clients = ${pageController.hasClients}');
//     return Material(
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           PageView.builder(
//               itemCount: words.length,
//               controller: pageController,
//               scrollBehavior: MaterialScrollBehavior(),
//               physics: ClampingScrollPhysics(),
//               onPageChanged: (x) {
//                 hideMessage(context);
//               },
//               scrollDirection: Axis.horizontal,
//               itemBuilder: (context, index) {
//                 return WordDetail(word: words[index]);
//               }),
//         ],
//       ),
//     );
//   }
// }

class ExploreWord extends StatefulWidget {
  final Word? word;
  final int index;
  const ExploreWord({Key? key, this.word, required this.index})
      : super(key: key);

  @override
  _ExploreWordState createState() => _ExploreWordState();
}

class _ExploreWordState extends State<ExploreWord>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _animationController;
  late Animation<int> _animation;
  late Tween<int> _tween;
  @override
  void initState() {
    super.initState();
    meaning = '';
    lowerIndex = widget.index > 5 ? widget.index - 5 : 0;
    upperIndex = widget.index + 5;
    if (widget.word != null) {
      selectedWord = widget.word!.word;
      meaning = widget.word!.meaning;
      length = widget.word!.meaning.length;
    }
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    if (length < 30) {
      _animationController.duration = Duration(seconds: 1);
    } else {
      _animationController.duration = Duration(seconds: 3);
    }
    supaStore = SupaStore();
    _tween = IntTween(begin: 0, end: length);
    _animation = _tween.animate(_animationController);
    _animationController.addStatusListener((status) {
      // if (status == AnimationStatus.completed) {
      // _animationController.reset();
      // }
    });
  }

  int length = 0;
  int synLength = 0;
  String selectedWord = '';

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  late String meaning;
  late SupaStore supaStore;
  int upperIndex = 0;
  int lowerIndex = 0;
  bool reveal = false;
  WordState wordState = WordState.unanswered;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = darkNotifier.value;
    final textTheme = Theme.of(context).textTheme;
    final userProvider = AppStateScope.of(context).user!;

    if (!userProvider.isLoggedIn) {
      reveal = true;
      _animationController.forward();
    }
    return widget.word == null
        ? EmptyWord()
        : Scaffold(
            body: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: kToolbarHeight),
                Align(
                  alignment: Alignment.topCenter,
                  child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32.0),
                      child: Text(
                        widget.word!.word.capitalize(),
                        style: textTheme.headline2!.copyWith(
                            color: isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                userProvider.isLoggedIn && !reveal
                    ? IconButton(
                        onPressed: () {
                          setState(() {
                            reveal = !reveal;
                          });
                          if (reveal) {
                            _animationController.forward();
                          }
                        },
                        icon: Icon(
                          reveal ? Icons.visibility : Icons.visibility_off,
                        ),
                      )
                    : SizedBox(),
                AnimatedOpacity(
                  opacity: reveal ? 1 : 0,
                  duration: Duration(milliseconds: 500),
                  child: IgnorePointer(
                    ignoring: !reveal,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: SynonymsList(
                            synonyms: widget.word!.synonyms,
                          ),
                        ),
                        AnimatedBuilder(
                            animation: _animation,
                            builder: (BuildContext _, Widget? child) {
                              meaning = widget.word!.meaning
                                  .substring(0, _animation.value);
                              return Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: SelectableText(meaning,
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context)
                                        .textTheme
                                        .headline4!
                                        .copyWith(
                                            fontFamily: GoogleFonts.inter(
                                          fontWeight: FontWeight.w400,
                                        ).fontFamily)),
                              );
                            }),
                        SizedBox(
                          height: 24,
                        ),
                        ExampleListBuilder(
                          title: 'Usage',
                          examples: (widget.word!.examples == null ||
                                  widget.word!.examples!.isEmpty)
                              ? []
                              : widget.word!.examples,
                          word: widget.word!.word,
                        ),
                        ExampleListBuilder(
                          title: 'Mnemonics',
                          examples: (widget.word!.mnemonics == null ||
                                  widget.word!.mnemonics!.isEmpty)
                              ? []
                              : widget.word!.mnemonics,
                          word: widget.word!.word,
                        ),
                        userProvider.isLoggedIn
                            ? WordMasteredPreference(
                                onChanged: (state) {
                                  String message = '';
                                  if (state) {
                                    wordState = WordState.known;
                                    message = knownWord;
                                  } else {
                                    wordState = WordState.unknown;
                                    message = unKnownWord;
                                  }
                                  setState(() {});
                                  showMessage(context, message,
                                      bottom: kBottomNavigationBarHeight * 1.1);
                                },
                                value: wordState,
                              )
                            : SizedBox.shrink(),
                        // SizedBox(
                        //   height: 200,
                        // ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
  }

  @override
  bool get wantKeepAlive {
    return true;

    /// TODO this doesn't work
    /// keep only 5 near by pages alive based on current index
    if (widget.index < lowerIndex || widget.index > upperIndex) {
      print('keeAlive false');
      return false;
    }
    print('keeAlive true');
    return true;
  }
}

class WordMasteredPreference extends StatefulWidget {
  final WordState value;
  const WordMasteredPreference(
      {Key? key, required this.onChanged, this.value = WordState.unanswered})
      : super(key: key);
  final Function(bool) onChanged;

  @override
  State<WordMasteredPreference> createState() => _WordMasteredPreferenceState();
}

class _WordMasteredPreferenceState extends State<WordMasteredPreference> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final bool isMastered = widget.value == WordState.known;
    final bool unAnswered = widget.value == WordState.unanswered;
    Color stateToColor(WordState state) {
      switch (state) {
        case WordState.unanswered:
          return Colors.grey;
        case WordState.known:
          return colorScheme.primary;
        case WordState.unknown:
          return colorScheme.error;
      }
    }

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Do you now know this word?',
                style: Theme.of(context).textTheme.headline4!.copyWith(
                      fontFamily: GoogleFonts.inter(
                        fontWeight: FontWeight.w200,
                      ).fontFamily,
                    )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                preferBelow: false,
                decoration:
                    BoxDecoration(color: colorScheme.primary.withOpacity(0.2)),
                richMessage: TextSpan(
                    style: GoogleFonts.inter(
                        color: VocabTheme.lightblue,
                        fontWeight: FontWeight.w200,
                        fontSize: 12),
                    children: [
                      TextSpan(
                        text:
                            'If marked as "yes" this word will be under your mastered list\nand when marked as "no" it will be under your bookmarks.',
                      ),
                    ]),
                child: Icon(Icons.help),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 16,
        ),
        ToggleButtons(
          borderColor: stateToColor(widget.value),
          selectedBorderColor: stateToColor(widget.value),
          renderBorder: true,
          selectedColor: stateToColor(widget.value),
          // color: isMastered ? colorScheme.primary : colorScheme.error,
          fillColor: stateToColor(widget.value).withOpacity(0.2),
          children: [
            SizedBox(
              width: 120,
              child: Text('Yes',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: isMastered
                          ? stateToColor(widget.value)
                          : Colors.black)),
            ),
            SizedBox(
              width: 120,
              child: Text('No',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headline4!.copyWith(
                      color: isMastered
                          ? Colors.black
                          : stateToColor(widget.value))),
            ),
          ],
          isSelected: [isMastered, !isMastered],
          onPressed: (int index) {
            if (widget.value == WordState.known && index == 0) return;
            if (widget.value == WordState.unknown && index == 1) return;
            widget.onChanged(index == 0);
          },
        ),
      ],
    );
  }
}
