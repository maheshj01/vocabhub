import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:vocabhub/services/supastore.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/synonymslist.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/utils/extensions.dart';

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
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));
    meaning = '';
    if (widget.word != null) {
      selectedWord = widget.word!.word;
      meaning = widget.word!.meaning;
      length = widget.word!.meaning.length;
    }
    edited = meaning;
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
    // TODO: implement dispose
    _animationController.dispose();
    editModeNotifier.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WordDetail oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.word != null) {
      setState(() {
        length = widget.word!.meaning.length;
        meaning = widget.word!.meaning;
        edited = meaning;
      });
    }
    if (length < 30) {
      _animationController.duration = Duration(seconds: 1);
    } else {
      _animationController.duration = Duration(seconds: 3);
    }
    textEditingController.clear();
    editModeNotifier.value = false;
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

  Future<void> updateMeaning() async {
    showCircularIndicator(context);
    meaning = edited;
    textEditingController.text = edited;
    String id = widget.word!.id;
    Word word = widget.word!;
    word.meaning = edited;
    final response = await supaStore.updateMeaning(id: id, word: word);
    stopCircularIndicator(context);
    if (response.status == 200) {
      showMessage(context, "meaning of word ${word.word} updated.");
    } else {
      print('failed to update ${response.error!.message}');
    }
  }

  void unfocus() => FocusScope.of(context).unfocus();

  late String edited;
  late String meaning;
  bool hasError = false;
  late SupaStore supaStore;
  final ValueNotifier<bool> editModeNotifier = ValueNotifier<bool>(false);
  TextEditingController textEditingController = TextEditingController(text: "");
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
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              editModeNotifier.value = false;
              setState(() {
                hasError = false;
              });
              unfocus();
            },
            child: ListView(
              children: [
                SizedBox(
                  height: size.height / 5,
                ),
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
                      child: Text(
                        widget.word!.word.capitalize(),
                        style: TextStyle(fontSize: size.height * 0.06),
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
                ValueListenableBuilder<bool>(
                    valueListenable: editModeNotifier,
                    builder:
                        (BuildContext context, bool editMode, Widget? child) {
                      return GestureDetector(
                        onTap: () {
                          editModeNotifier.value = true;
                        },
                        child: AnimatedBuilder(
                          animation: _animation,
                          builder: (BuildContext _, Widget? child) {
                            meaning = widget.word!.meaning
                                .substring(0, _animation.value);
                            textEditingController.text = meaning;
                            return Column(
                              children: [
                                AnimatedContainer(
                                  curve: Curves.easeIn,
                                  padding: const EdgeInsets.all(16.0),
                                  duration: Duration(seconds: 1),
                                  margin: EdgeInsets.symmetric(
                                      horizontal: (size.width > MOBILE_WIDTH &&
                                              size.width < TABLET_WIDTH)
                                          ? 24.0
                                          : 48.0),
                                  decoration: BoxDecoration(
                                      boxShadow: editMode
                                          ? [
                                              BoxShadow(
                                                color: isDark
                                                    ? primaryDark
                                                    : Colors.grey[100]!,
                                                // .withOpacity(0.2),
                                                offset: Offset(-6.0, -6.0),
                                                blurRadius: 16.0,
                                              ),
                                              BoxShadow(
                                                color: isDark
                                                    ? Colors.black
                                                        .withOpacity(0.2)
                                                    : Colors.black
                                                        .withOpacity(0.1),
                                                offset: Offset(6.0, 6.0),
                                                blurRadius: 16.0,
                                              ),
                                            ]
                                          : null,
                                      color: textfieldBgColor(editMode),
                                      borderRadius: BorderRadius.circular(
                                          editMode ? 12 : 0)),
                                  child: StatefulBuilder(
                                    builder: (_, state) => TextField(
                                        controller: textEditingController,
                                        readOnly: !editMode,
                                        maxLines: 5,
                                        textAlign: TextAlign.center,
                                        autofocus: false,
                                        onChanged: (x) {
                                          state(() {
                                            edited = x;
                                          });
                                        },
                                        onTap: () {
                                          editModeNotifier.value = true;
                                        },
                                        decoration: InputDecoration(
                                            hintText: length > 0
                                                ? null
                                                : "Add a meaning",
                                            hintStyle: TextStyle(
                                                fontSize: 18,
                                                color: Colors.grey),
                                            focusedBorder: InputBorder.none,
                                            border: InputBorder.none),
                                        style: TextStyle(fontSize: 20)),
                                  ),
                                ),
                                hasError
                                    ? Text(
                                        "Meaning cannot be empty",
                                        style: TextStyle(color: Colors.red),
                                      )
                                    : Container(),
                                SizedBox(
                                  height: 20,
                                ),
                                AnimatedAlign(
                                  alignment: editMode
                                      ? Alignment(0.0, 0.0)
                                      : Alignment(1.2, 0.0),
                                  duration: Duration(milliseconds: 400),
                                  child: AnimatedOpacity(
                                      duration: Duration(seconds: 1),
                                      opacity: editMode ? 1.0 : 0.0,
                                      child: Container(
                                        width: 100,
                                        height: 40,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty
                                                      .all<Color>(!isDark
                                                          ? primaryColor
                                                          : secondaryDark)),
                                          child: Text('Save'),
                                          onPressed: editMode
                                              ? () {
                                                  final text =
                                                      textEditingController
                                                          .text;
                                                  if (text.isNotEmpty) {
                                                    setState(() {
                                                      hasError = false;
                                                    });
                                                    editModeNotifier.value =
                                                        false;
                                                    unfocus();
                                                    if (edited != meaning &&
                                                        _animationController
                                                                .status ==
                                                            AnimationStatus
                                                                .completed) {
                                                      /// TODO: Update meaning
                                                      length = edited.length;
                                                      _tween.end = length;
                                                      updateMeaning();
                                                    }
                                                  } else {
                                                    setState(() {
                                                      hasError = true;
                                                    });
                                                    editModeNotifier.value =
                                                        true;
                                                  }
                                                }
                                              : null,
                                        ),
                                      )),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    }),
                SizedBox(
                  height: 24,
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
                SizedBox(
                  height: 100,
                ),
              ],
            ),
          );
  }
}

class ExampleBuilder extends StatefulWidget {
  final List<String>? examples;
  final String word;
  const ExampleBuilder({Key? key, required this.examples, required this.word})
      : super(key: key);

  @override
  _ExampleBuilderState createState() => _ExampleBuilderState();
}

class _ExampleBuilderState extends State<ExampleBuilder> {
  RichText getExample(String example) {
    final textSpans = [TextSpan(text: ' - ')];

    final iterable = example
        .split(' ')
        .toList()
        .map((e) => TextSpan(
            text: e + ' ',
            style: TextStyle(
                fontWeight:
                    (e.toLowerCase().contains(widget.word.toLowerCase()))
                        ? FontWeight.bold
                        : FontWeight.normal)))
        .toList();
    textSpans.addAll(iterable);
    textSpans.add(TextSpan(text: '\n'));
    return RichText(
        text: TextSpan(
            style: TextStyle(
                color: darkNotifier.value ? Colors.white : Colors.black),
            children: textSpans));
  }

  @override
  Widget build(BuildContext context) {
    return widget.examples!.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Example',
                style: TextStyle(fontSize: 24),
              ),
              SizedBox(
                height: 20,
              ),
              ...[
                for (int i = 0; i < widget.examples!.length; i++)
                  getExample(widget.examples![i])
              ]
            ],
          );
  }
}

class EmptyWord extends StatelessWidget {
  const EmptyWord({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Whats the word on your mind?',
            style: TextStyle(fontSize: 20),
          )
        ],
      ),
    );
  }
}
