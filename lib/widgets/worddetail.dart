import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/constants/strings.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services/vocabstore.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/size_utils.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/drawer.dart';
import 'package:vocabhub/widgets/examplebuilder.dart';
import 'package:vocabhub/widgets/synonymslist.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/utils/extensions.dart';

import 'wordscount.dart';

class WordDetail extends StatefulWidget {
  final Word? word;
  const WordDetail({Key? key, this.word}) : super(key: key);

  @override
  _WordDetailState createState() => _WordDetailState();
}

class _WordDetailState extends State<WordDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<int> _animation;
  late Tween<int> _tween;
  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    meaning = '';
    if (widget.word != null) {
      selectedWord = widget.word!.word;
      meaning = widget.word!.meaning;
      length = widget.word!.meaning.length;
    }
    supaStore = VocabStoreService();
    _tween = IntTween(begin: 0, end: length);
    _animation = _tween.animate(_animationController);
    _animationController.addStatusListener((status) {
      // if (status == AnimationStatus.completed) {
      // _animationController.reset();
      // }
    });
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      userProvider = AppStateScope.of(context).user!;
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

  @override
  void didUpdateWidget(covariant WordDetail oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.word != null) {
      setState(() {
        length = widget.word!.meaning.length;
        meaning = widget.word!.meaning;
      });
    }
    if (length < 30) {
      _animationController.duration = Duration(seconds: 1);
    } else {
      _animationController.duration = Duration(seconds: 3);
    }
    _tween.end = length;
    if (widget.word?.word != selectedWord) {
      _animationController.reset();
      _animationController.forward();
    }
    if (widget.word != null) {
      selectedWord = widget.word!.word;
    }
  }

  late String meaning;
  late VocabStoreService supaStore;
  UserModel userProvider = UserModel.init();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = darkNotifier.value;

    Color? textfieldBgColor(bool editMode) {
      if (editMode) {
        if (isDark) {
          return Colors.grey;
        } else {
          return Colors.grey[100];
        }
      } else {
        if (isDark) {
          return Colors.transparent;
        } else {
          return Colors.white12;
        }
      }
    }

    return widget.word == null
        ? EmptyWord()
        : Material(
            child: Column(
              children: [
                SizedBox(
                  height: SizeUtils.isMobile ? 24 : (size.height / 5),
                ),
                userProvider.isLoggedIn && userProvider.isAdmin
                    ? Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.only(right: 16),
                        child: IconButton(
                            icon: Icon(
                              Icons.edit,
                            ),
                            onPressed: () {
                              Navigate.push(
                                  context,
                                  AddWordForm(
                                    isEdit: true,
                                    word: widget.word,
                                  ),
                                  slideTransitionType: TransitionType.btt);
                            }))
                    : SizedBox(),
                Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(
                          ClipboardData(text: "${widget.word!.word}"));
                      showMessage(context,
                          " copied ${widget.word!.word} to clipboard.");
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            widget.word!.word.capitalize(),
                            style: Theme.of(context)
                                .textTheme
                                .headline2!
                                .copyWith(
                                    color:
                                        isDark ? Colors.white : Colors.black),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SynonymsList(
                  synonyms: widget.word!.synonyms,
                ),
                SizedBox(
                  height: 50,
                ),
                AnimatedBuilder(
                    animation: _animation,
                    builder: (BuildContext _, Widget? child) {
                      meaning =
                          widget.word!.meaning.substring(0, _animation.value);
                      return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SelectableText(meaning,
                            textAlign: TextAlign.center,
                            style:
                                Theme.of(context).textTheme.headline4!.copyWith(
                                        fontFamily: GoogleFonts.inter(
                                      fontWeight: FontWeight.w400,
                                    ).fontFamily)),
                      );
                    }),
                SizedBox(
                  height: 48,
                ),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ExampleListBuilder(
                      title: 'Usage',
                      examples: (widget.word!.examples == null ||
                              widget.word!.examples!.isEmpty)
                          ? []
                          : widget.word!.examples,
                      word: widget.word!.word,
                    )),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ExampleListBuilder(
                      title: 'Mnemonics',
                      examples: (widget.word!.mnemonics == null ||
                              widget.word!.mnemonics!.isEmpty)
                          ? []
                          : widget.word!.mnemonics,
                      word: widget.word!.word,
                    )),
                SizedBox(
                  height: 200,
                ),
              ],
            ),
          );
  }
}

class EmptyWord extends StatefulWidget {
  EmptyWord({Key? key}) : super(key: key);

  @override
  _EmptyWordState createState() => _EmptyWordState();
}

class _EmptyWordState extends State<EmptyWord> {
  late int randIndex;

  @override
  void initState() {
    super.initState();
    randIndex = Random().nextInt(tips.length);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          Text(
            'Whats the word on your mind?',
            style: Theme.of(context).textTheme.headline4,
          ),
          SizedBox(height: 16),
          Text('Tip: ' + tips[randIndex],
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.caption),
          WordsCountAnimator(),
          Expanded(child: Container()),
          if (kIsWeb)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                storeRedirect(
                  context,
                ),
                storeRedirect(context,
                    redirectUrl: AMAZON_APP_STORE_URL,
                    assetUrl: 'assets/amazonappstore.png'),
              ],
            ),
          Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: VersionBuilder()),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}
