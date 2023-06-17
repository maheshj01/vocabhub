import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/controller/explore_controller.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/services/services/word_state_service.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/examplebuilder.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/synonymslist.dart';
import 'package:vocabhub/widgets/worddetail.dart';

class ExploreWords extends StatelessWidget {
  static const String route = '/';
  final VoidCallback? onScrollThresholdReached;

  const ExploreWords({Key? key, this.onScrollThresholdReached}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => ExploreWordsDesktop(),
        mobileBuilder: (context) => ExploreWordsMobile(
              onScrollThresholdReached: () => onScrollThresholdReached!(),
            ));
  }
}

class ExploreWordsMobile extends StatefulWidget {
  final VoidCallback? onScrollThresholdReached;

  const ExploreWordsMobile({Key? key, this.onScrollThresholdReached}) : super(key: key);

  @override
  State<ExploreWordsMobile> createState() => _ExploreWordsMobileState();
}

class _ExploreWordsMobileState extends State<ExploreWordsMobile> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      exploreWords();
    });
  }

  Future<void> exploreWords() async {
    _request.value = Response(state: RequestState.active);
    final user = AppStateScope.of(context).user;
    final newWords = await exploreController.exploreWords(user!.email, page: page);
    newWords.shuffle();
    max = newWords.length;
    print(max);
    if (mounted) {
      _request.value = _request.value.copyWith(data: newWords, state: RequestState.done);
    }
  }

  int page = 0;
  int max = 0;
  bool isFetching = false;
  ExploreController _exploreController = ExploreController();
  ValueNotifier<Response> _request = ValueNotifier<Response>(Response(state: RequestState.none));
  int _scrollCountCallback = 11;
  @override
  void dispose() {
    _request.dispose();
    _exploreController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Response>(
        valueListenable: _request,
        builder: (BuildContext context, Response? request, Widget? child) {
          if (request == null ||
              (request.data == null) ||
              (request.data as List<dynamic>).isEmpty) {
            return SizedBox.shrink();
          }
          final words = request.data as List<Word>;
          return Material(
            child: Stack(
              fit: StackFit.expand,
              children: [
                PageView.builder(
                    itemCount: words.length,
                    controller: pageController,
                    scrollBehavior: MaterialScrollBehavior(),
                    onPageChanged: (x) {
                      if (x > max - 5) {
                        page++;
                        exploreWords();
                      }
                      if (x % _scrollCountCallback == 0) {
                        widget.onScrollThresholdReached!();
                      }
                      hideMessage(context);
                    },
                    physics: ClampingScrollPhysics(),
                    scrollDirection: Axis.vertical,
                    itemBuilder: (context, index) {
                      return ExploreWord(word: words[index], index: index);
                    }),
                request.state == RequestState.active
                    ? Positioned(
                        bottom: kBottomNavigationBarHeight + 50,
                        left: 120,
                        child: Text('Fetching more words'))
                    : SizedBox.shrink(),
              ],
            ),
          );
        });
  }
}

PageController pageController = PageController();

class ExploreWordsDesktop extends StatefulWidget {
  ExploreWordsDesktop({Key? key}) : super(key: key);

  @override
  State<ExploreWordsDesktop> createState() => _ExploreWordsDesktopState();
}

class _ExploreWordsDesktopState extends State<ExploreWordsDesktop> {
  final focusNode = FocusNode();
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final words = AppStateScope.of(context).words;
    if (words == null || words.isEmpty) return SizedBox.shrink();
    return KeyboardListener(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          pageController.previousPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          pageController.nextPage(duration: Duration(milliseconds: 500), curve: Curves.easeIn);
        }
      },
      child: Material(
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: PageView.builder(
                  itemCount: words.length,
                  controller: pageController,
                  scrollBehavior: MaterialScrollBehavior(),
                  physics: ClampingScrollPhysics(),
                  onPageChanged: (x) {
                    hideMessage(context);
                  },
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return WordDetail(word: words[index]);
                  }),
            ),
            Positioned(
              top: size.height * 0.5,
              left: kNotchedNavbarHeight,
              child: IconButton(
                  icon: Icon(
                    Icons.arrow_back_ios,
                    color: Colors.black,
                    size: 42,
                  ),
                  onPressed: () => pageController.previousPage(
                      duration: Duration(milliseconds: 500), curve: Curves.easeIn)),
            ),
            Positioned(
              top: size.height * 0.5,
              right: kNotchedNavbarHeight,
              child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 42),
                  onPressed: () => pageController.nextPage(
                      duration: Duration(milliseconds: 500), curve: Curves.easeIn)),
            ),
          ],
        ),
      ),
    );
  }
}

class ExploreWord extends StatefulWidget {
  final Word? word;
  final int index;
  const ExploreWord({Key? key, this.word, required this.index}) : super(key: key);

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
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    if (length < 30) {
      _animationController.duration = Duration(seconds: 1);
    } else {
      _animationController.duration = Duration(seconds: 3);
    }
    supaStore = VocabStoreService();
    _tween = IntTween(begin: 0, end: length);
    _animation = _tween.animate(_animationController);
    _animationController.addStatusListener((status) {
      // if (status == AnimationStatus.completed) {
      // _animationController.reset();
      // }
    });
    isHidden = exploreController.isHidden;
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
  late VocabStoreService supaStore;
  int upperIndex = 0;
  int lowerIndex = 0;
  WordState wordState = WordState.unanswered;
  List<Color> backgrounds = [
    Color(0xff989E9C),
    Color(0xffDFD3BB),
    Color(0xffB9B49E),
    Color(0xff72858C),
    Color(0xff30414B),
  ];
  late bool isHidden;
  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Size size = MediaQuery.of(context).size;
    final textTheme = Theme.of(context).textTheme;
    final userProvider = AppStateScope.of(context).user!;
    if (!userProvider.isLoggedIn) {
      _animationController.forward();
    }
    return widget.word == null
        ? EmptyWord()
        : AnimatedBuilder(
            animation: exploreController,
            builder: (BuildContext context, Widget? child) {
              return Column(
                children: [
                  kToolbarHeight.vSpacer(),
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: kToolbarHeight, bottom: 12),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32.0),
                              child: Text(widget.word!.word.capitalize()!,
                                  style: textTheme.displayMedium!),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 20,
                        right: 40,
                        child: userProvider.isLoggedIn && !isHidden
                            ? IconButton(
                                onPressed: () {
                                  Navigate.push(
                                      context,
                                      AddWordForm(
                                        isEdit: true,
                                        word: widget.word,
                                      ),
                                      transitionType: TransitionType.scale);
                                },
                                icon: Icon(
                                  Icons.edit,
                                  color: Theme.of(context).colorScheme.primary,
                                ))
                            : SizedBox.shrink(),
                      )
                    ],
                  ),
                  (userProvider.isLoggedIn && isHidden)
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              isHidden = !isHidden;
                            });
                            _animationController.forward();
                          },
                          icon: Icon(
                            Icons.visibility_off,
                          ),
                        )
                      : SizedBox.shrink(),
                  AnimatedOpacity(
                    opacity: !isHidden ? 1 : 0,
                    duration: Duration(milliseconds: 500),
                    child: IgnorePointer(
                      ignoring: isHidden,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: SynonymsList(
                              synonyms: widget.word!.synonyms,
                              emptyHeight: 0,
                              onTap: (synonym) {},
                            ),
                          ),
                          AnimatedBuilder(
                              animation: _animation,
                              builder: (BuildContext _, Widget? child) {
                                meaning = widget.word!.meaning.substring(0, _animation.value);
                                return Container(
                                  alignment: Alignment.center,
                                  margin: 24.0.verticalPadding,
                                  padding: 16.0.horizontalPadding,
                                  child: SelectableText(meaning,
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium!
                                          .copyWith(fontWeight: FontWeight.w400)),
                                );
                              }),
                          ExampleListBuilder(
                            title: 'Usage',
                            examples:
                                (widget.word!.examples == null || widget.word!.examples!.isEmpty)
                                    ? []
                                    : widget.word!.examples,
                            word: widget.word!.word,
                          ),
                          ExampleListBuilder(
                            title: 'Mnemonics',
                            examples:
                                (widget.word!.mnemonics == null || widget.word!.mnemonics!.isEmpty)
                                    ? []
                                    : widget.word!.mnemonics,
                            word: widget.word!.word,
                          ),
                          SizedBox(
                            height: 48,
                          ),
                          userProvider.isLoggedIn
                              ? WordMasteredPreference(
                                  onChanged: (state) async {
                                    final wordId = widget.word!.id;
                                    final userEmail = userProvider.email;
                                    String message = '';
                                    if (state) {
                                      wordState = WordState.known;
                                      message = knownWord;
                                    } else {
                                      wordState = WordState.unknown;
                                      message = unKnownWord;
                                    }
                                    setState(() {});
                                    final resp = await WordStateService.storeWordPreference(
                                        wordId, userEmail, wordState);
                                    if (resp.didSucced) {
                                      showToast(message);
                                    }
                                  },
                                  value: wordState,
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                    ),
                  )
                ],
              );
            });
  }

  @override
  bool get wantKeepAlive {
    return true;

    /// TODO this doesn't work
    /// keep only 5 near by pages alive based on current index
    if (widget.index < lowerIndex || widget.index > upperIndex) {
      return false;
    }
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
    // final bool unAnswered = widget.value == WordState.unanswered;

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
            Text('Do you know this word?',
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontFamily: GoogleFonts.inter(
                        fontWeight: FontWeight.w200,
                      ).fontFamily,
                    )),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Tooltip(
                triggerMode: TooltipTriggerMode.tap,
                preferBelow: false,
                decoration: BoxDecoration(color: colorScheme.tertiaryContainer),
                richMessage: TextSpan(
                    style: Theme.of(context).textTheme.bodyText1!.copyWith(
                          fontWeight: FontWeight.w200,
                        ),
                    children: [
                      TextSpan(
                        text:
                            'If marked as "yes" this word will be under your mastered list and when marked as "no" it will be under your bookmarks.',
                      ),
                    ]),
                child: Icon(Icons.help),
              ),
            ),
          ],
        ),
        16.0.vSpacer(),
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
                  textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineMedium!),
            ),
            SizedBox(
              width: 120,
              child: Text('No',
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium!
                      .copyWith(color: isMastered ? Colors.black : stateToColor(widget.value))),
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
