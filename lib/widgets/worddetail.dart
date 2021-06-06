import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
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
    _animationController.reset();
    _animationController.forward();
  }

  Future<void> updateMeaning() async {
    if (edited.isNotEmpty) {
      meaning = edited;
      textEditingController.text = edited;
      String id = widget.word!.id;
      Word word = widget.word!;
      word.meaning = edited;
      final response = await supaStore.updateMeaning(id: id, word: word);
      stopCircularIndicator(context);
      if (response.status == 200) {
        showMessage(context, " meaning of word ${word.word} updated.");
      } else {
        print('failed to update ${response.error!.message}');
      }
    }
  }

  void unfocus() => FocusScope.of(context).unfocus();

  late String edited;
  late String meaning;
  late SupaStore supaStore;
  final ValueNotifier<bool> editModeNotifier = ValueNotifier<bool>(false);
  TextEditingController textEditingController = TextEditingController(text: "");
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return widget.word == null
        ? EmptyWord()
        : GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              editModeNotifier.value = false;
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
                                  padding: const EdgeInsets.all(16.0),
                                  duration: Duration(seconds: 1),
                                  margin: EdgeInsets.symmetric(horizontal: 8),
                                  decoration: BoxDecoration(
                                      color: editMode
                                          ? Colors.grey.withOpacity(0.08)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(
                                          editMode ? 20 : 0)),
                                  child: TextField(
                                      controller: textEditingController,
                                      readOnly: !editMode,
                                      maxLines: 5,
                                      autofocus: false,
                                      onChanged: (x) {
                                        edited = x;
                                      },
                                      onTap: () {
                                        editModeNotifier.value = true;
                                      },
                                      decoration: InputDecoration(
                                          hintText: "Add a meaning",
                                          focusedBorder: InputBorder.none,
                                          border: InputBorder.none),
                                      style: TextStyle(fontSize: 20)),
                                ),
                                SizedBox(
                                  height: 10,
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
                                        child: Text('Save'),
                                        onPressed: editMode
                                            ? () {
                                                editModeNotifier.value = false;
                                                unfocus();
                                                showCircularIndicator(context);
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
                                              }
                                            : null,
                                      ),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      );
                    })
              ],
            ),
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
