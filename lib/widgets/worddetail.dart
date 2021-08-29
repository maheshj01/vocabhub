import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:vocabhub/constants/strings.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/services/supastore.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/drawer.dart';
import 'package:vocabhub/widgets/examplebuilder.dart';
import 'package:vocabhub/widgets/mnemonicbuilder.dart';
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
    unfocus();
    _tween.end = length;
    if (widget.word?.word != selectedWord) {
      _animationController.reset();
      _animationController.forward();
    }
    if (widget.word != null) {
      selectedWord = widget.word!.word;
    }
  }

  void unfocus() => FocusScope.of(context).unfocus();

  late String meaning;
  late SupaStore supaStore;
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool isDark = darkNotifier.value;
    final userProvider = Provider.of<UserModel>(context);

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
        : ListView(
            children: [
              SizedBox(
                height: size.height / 5,
              ),
              userProvider.isLoggedIn
                  ? Container(
                      alignment: Alignment.topRight,
                      padding: EdgeInsets.only(right: 16),
                      child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            Navigate().push(
                                context,
                                AddWordForm(
                                  isEdit: true,
                                  word: widget.word,
                                ),
                                slideTransitionType: SlideTransitionType.btt);
                          }))
                  : SizedBox(),
              Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () async {
                    await Clipboard.setData(
                        ClipboardData(text: "${widget.word!.word}"));
                    showMessage(
                        context, " copied ${widget.word!.word} to clipboard.");
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: Text(
                      widget.word!.word.capitalize(),
                      style: Theme.of(context).textTheme.headline3!.copyWith(
                          fontSize: size.height * 0.06,
                          color: isDark ? Colors.white : Colors.black),
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
                          style: Theme.of(context)
                              .textTheme
                              .subtitle1!
                              .copyWith(
                                  color: isDark ? Colors.white : Colors.black)),
                    );
                  }),
              // ValueListenableBuilder<bool>(
              //     valueListenable: editModeNotifier,
              //     builder:
              //         (BuildContext context, bool editMode, Widget? child) {
              //       return GestureDetector(
              //         onTap: () {
              //           editModeNotifier.value = true;
              //         },
              //         child: AnimatedBuilder(
              //           animation: _animation,
              //           builder: (BuildContext _, Widget? child) {
              //             meaning = widget.word!.meaning
              //                 .substring(0, _animation.value);
              //             textEditingController.text = meaning;
              //             return Column(
              //               children: [
              //                 AnimatedContainer(
              //                   curve: Curves.easeIn,
              //                   padding: const EdgeInsets.all(16.0),
              //                   duration: Duration(seconds: 1),
              //                   margin: EdgeInsets.symmetric(
              //                       horizontal: (size.width > MOBILE_WIDTH &&
              //                               size.width < TABLET_WIDTH)
              //                           ? 24.0
              //                           : 48.0),
              //                   decoration: BoxDecoration(
              //                       boxShadow: editMode
              //                           ? [
              //                               BoxShadow(
              //                                 color: isDark
              //                                     ? primaryDark
              //                                     : Colors.grey[100]!,
              //                                 // .withOpacity(0.2),
              //                                 offset: Offset(-6.0, -6.0),
              //                                 blurRadius: 16.0,
              //                               ),
              //                               BoxShadow(
              //                                 color: isDark
              //                                     ? Colors.black
              //                                         .withOpacity(0.2)
              //                                     : Colors.black
              //                                         .withOpacity(0.1),
              //                                 offset: Offset(6.0, 6.0),
              //                                 blurRadius: 16.0,
              //                               ),
              //                             ]
              //                           : null,
              //                       color: textfieldBgColor(editMode),
              //                       borderRadius: BorderRadius.circular(
              //                           editMode ? 12 : 0)),
              //                   child: StatefulBuilder(
              //                     builder: (_, state) => TextField(
              //                         controller: textEditingController,
              //                         readOnly: !editMode,
              //                         maxLines: 5,
              //                         textAlign: TextAlign.center,
              //                         autofocus: false,
              //                         onChanged: (x) {
              //                           state(() {
              //                             edited = x;
              //                           });
              //                         },
              //                         onTap: () {
              //                           editModeNotifier.value = true;
              //                         },
              //                         decoration: InputDecoration(
              //                             hintText: length > 0
              //                                 ? null
              //                                 : "Add a meaning",
              //                             hintStyle: TextStyle(
              //                                 fontSize: 18,
              //                                 color: Colors.grey),
              //                             focusedBorder: InputBorder.none,
              //                             border: InputBorder.none),
              //                         style: Theme.of(context)
              //                             .textTheme
              //                             .subtitle1!
              //                             .copyWith(
              //                                 color: isDark
              //                                     ? Colors.white
              //                                     : Colors.black)),
              //                   ),
              //                 ),
              //                 hasError
              //                     ? Text(
              //                         "Meaning cannot be empty",
              //                         style: TextStyle(color: Colors.red),
              //                       )
              //                     : Container(),
              //                 SizedBox(
              //                   height: 20,
              //                 ),
              //                 AnimatedAlign(
              //                   alignment: editMode
              //                       ? Alignment(0.0, 0.0)
              //                       : Alignment(1.2, 0.0),
              //                   duration: Duration(milliseconds: 400),
              //                   child: AnimatedOpacity(
              //                       duration: Duration(seconds: 1),
              //                       opacity: editMode ? 1.0 : 0.0,
              //                       child: Container(
              //                         width: 100,
              //                         height: 40,
              //                         child: ElevatedButton(
              //                           style: ButtonStyle(
              //                               backgroundColor:
              //                                   MaterialStateProperty
              //                                       .all<Color>(!isDark
              //                                           ? primaryColor
              //                                           : secondaryDark)),
              //                           child: Text('Save'),
              //                           onPressed: editMode
              //                               ? () {
              //                                   final text =
              //                                       textEditingController
              //                                           .text;
              //                                   if (text.isNotEmpty) {
              //                                     setState(() {
              //                                       hasError = false;
              //                                     });
              //                                     editModeNotifier.value =
              //                                         false;
              //                                     unfocus();
              //                                     if (edited != meaning &&
              //                                         _animationController
              //                                                 .status ==
              //                                             AnimationStatus
              //                                                 .completed) {
              //                                       length = edited.length;
              //                                       _tween.end = length;
              //                                       updateMeaning();
              //                                     }
              //                                   } else {
              //                                     setState(() {
              //                                       hasError = true;
              //                                     });
              //                                     editModeNotifier.value =
              //                                         true;
              //                                   }
              //                                 }
              //                               : null,
              //                         ),
              //                       )),
              //                 ),
              //               ],
              //             );
              //           },
              //         ),
              //       );
              //     }),
              SizedBox(
                height: 48,
              ),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ExampleBuilder(
                    examples: (widget.word!.examples == null ||
                            widget.word!.examples!.isEmpty)
                        ? []
                        : widget.word!.examples,
                    word: widget.word!.word,
                  )),
              Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MnemonnicBuilder(
                    mnemonics: (widget.word!.mnemonics == null ||
                            widget.word!.mnemonics!.isEmpty)
                        ? []
                        : widget.word!.mnemonics,
                    word: widget.word!.word,
                  )),
              SizedBox(
                height: 100,
              ),
            ],
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
                playStoreRedirect(context),
                playStoreRedirect(context,
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
