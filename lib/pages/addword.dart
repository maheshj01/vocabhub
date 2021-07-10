import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:vocabhub/services/supastore.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/widgets.dart';

class AddWordForm extends StatefulWidget {
  const AddWordForm({Key? key}) : super(key: key);

  @override
  _AddWordFormState createState() => _AddWordFormState();
}

class _AddWordFormState extends State<AddWordForm> {
  late Size size;
  SupaStore supaStore = SupaStore();

  late TextEditingController wordController;
  late TextEditingController meaningController;
  late TextEditingController exampleController;
  late TextEditingController synonymController;

  Future<void> submitForm() async {
    showCircularIndicator(context);
    final newWord = wordController.text;
    final meaning = meaningController.text;
    if (newWord.isNotEmpty && meaning.isNotEmpty) {
      setState(() {
        isDisabled = true;
      });
      final wordObject = Word(
        '',
        newWord,
        meaning,
      );
      if (_examples.isNotEmpty) {
        wordObject.examples = _examples;
      }
      if (_examples.isNotEmpty) {
        wordObject.synonyms = _synonyms;
      }
      final response = await supaStore.addWord(wordObject);
      stopCircularIndicator(context);
      if (response.didSucced) {
        final supaStoreWords = await supaStore.findByWord("");
        listNotifier.value = supaStoreWords;
        totalNotifier.value = supaStoreWords.length;
        showMessage(context, 'Congrats! You just added $word to vocabhub ');
        popView(context);
      } else {
        setState(() {
          isDisabled = false;
          error = 'Failed to add $word';
          _errorNotifier.value = true;
        });
      }
    } else {
      stopCircularIndicator(context);
      error = 'word or meaning cannot be empty!';
      _errorNotifier.value = true;
    }
  }

  final _errorNotifier = ValueNotifier<bool>(false);
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    wordController = TextEditingController();
    meaningController = TextEditingController();
    exampleController = TextEditingController();
    synonymController = TextEditingController();
    wordController.addListener(() {
      setState(() {
        word = wordController.text;
      });
    });
    exampleController.addListener(() {
      setState(() {});
    });
    synonymController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    wordController.dispose();
    meaningController.dispose();
    exampleController.dispose();
    synonymController.dispose();
    _errorNotifier.dispose();
  }

  bool isDisabled = false;
  String word = '';
  List<String> _examples = [];
  List<String> _synonyms = [];
  int maxExampleCount = 3;
  int maxSynonymCount = 5;
  String error = '';
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    bool isDark = darkNotifier.value;
    Widget synonymChip(String synonym, Function onDeleted) {
      return InputChip(
        label: Text(
          '${synonym.capitalize()}',
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.white),
        ),
        onDeleted: () => onDeleted(),
        isEnabled: true,
        backgroundColor: isDark ? secondaryDark : secondaryColor,
        useDeleteButtonTooltip: true,
        deleteButtonTooltipMessage: 'soimething',
      );
    }

    return Material(
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Container(
            color: isDark ? Colors.grey[850] : Colors.white,
            height: size.width < MOBILE_WIDTH ? size.height * 0.8 : null,
            child: ListView(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0, top: 16),
                    child: IconButton(
                        onPressed: () => popView(context),
                        icon: Icon(Icons.clear, size: 32)),
                  ),
                ),
                Center(
                  child: Text('Lets add a new word',
                      style: Theme.of(context)
                          .textTheme
                          .headline3!
                          .copyWith(fontWeight: FontWeight.w500)),
                ),
                SizedBox(
                  height: 50,
                ),
                VocabField(
                  autofocus: true,
                  fontSize: 30,
                  maxlength: 20,
                  hint: 'e.g Ambivalent',
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp('[A-Za-z]+'))
                  ],
                  controller: wordController,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: VocabField(
                    hint: 'What does ' +
                        '${word.isEmpty ? 'it mean?' : word + ' mean?'}',
                    controller: meaningController,
                    maxlines: 4,
                  ),
                ),
                Wrap(
                  direction: Axis.horizontal,
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 2,
                  children: List.generate(_synonyms.length, (index) {
                    return synonymChip(_synonyms[index], () {
                      _synonyms.remove(_synonyms[index]);
                      setState(() {});
                    });
                  }),
                ),
                _synonyms.length == maxSynonymCount
                    ? Container()
                    : Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 150,
                            child: VocabField(
                              fontSize: 16,
                              hint: 'add synonym',
                              maxlength: 16,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp('[A-Za-z]+'))
                              ],
                              controller: synonymController,
                            ),
                          ),
                          synonymController.text.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16, top: 8),
                                  child: IconButton(
                                      onPressed: () {
                                        String newSynonym =
                                            synonymController.text;
                                        if (newSynonym.isNotEmpty) {
                                          _synonyms.add(newSynonym);
                                        }
                                        setState(() {});
                                        synonymController.clear();
                                      },
                                      icon: Icon(Icons.done, size: 32)),
                                )
                              : Container(),
                        ],
                      ),
                SizedBox(
                  height: 32,
                ),
                ...List.generate(_examples.length, (index) {
                  return Container(
                    margin: EdgeInsets.symmetric(
                        horizontal: size.width < MOBILE_WIDTH ? 16 : 24.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(child: buildExample(_examples[index], word)),
                        GestureDetector(
                            onTap: () {
                              _examples.remove(_examples.elementAt(index));
                              setState(() {});
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Icon(Icons.delete),
                            )),
                      ],
                    ),
                  );
                }),
                _examples.length < maxExampleCount
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Flexible(
                            child: VocabField(
                              hint:
                                  'An example sentence ${word.isEmpty ? "" : "with $word"} (Optional)',
                              controller: exampleController,
                              maxlines: 4,
                            ),
                          ),
                          exampleController.text.isNotEmpty
                              ? Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16.0, right: 16, top: 8),
                                  child: IconButton(
                                      onPressed: () {
                                        String text = exampleController.text;
                                        if (word.isNotEmpty) {
                                          _examples.add(text);
                                        }
                                        setState(() {});
                                        exampleController.clear();
                                      },
                                      icon: Icon(Icons.done, size: 32)),
                                )
                              : Container(),
                        ],
                      )
                    : Container(),
                SizedBox(
                  height: 50,
                ),
                Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: 40,
                      width: 100,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: isDark ? Colors.teal : primaryColor,
                          ),
                          onPressed: isDisabled ? null : () => submitForm(),
                          child: Text('Submit',
                              style: TextStyle(
                                  color: isDisabled
                                      ? Colors.black
                                      : Colors.white))),
                    )),
                SizedBox(height: 16),
                ValueListenableBuilder<bool>(
                    valueListenable: _errorNotifier,
                    builder: (context, value, Widget? widget) {
                      if (value) {
                        return Align(
                          alignment: Alignment.center,
                          child: Text(
                            '$error',
                            style: TextStyle(
                                color: isDark ? Colors.white : Colors.red),
                          ),
                        );
                      }
                      return Container();
                    }),
                SizedBox(
                  height: 40,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class VocabField extends StatefulWidget {
  final String hint;
  final int? maxlines;
  final int? maxlength;
  final bool autofocus;
  final double fontSize;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController controller;

  const VocabField(
      {Key? key,
      required this.hint,
      this.maxlines = 1,
      this.maxlength,
      this.inputFormatters,
      required this.controller,
      this.fontSize = 16,
      this.autofocus = false})
      : super(key: key);

  @override
  VocabFieldState createState() => VocabFieldState();
}

class VocabFieldState extends State<VocabField> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
              controller: widget.controller,
              maxLines: widget.maxlines,
              textAlign: TextAlign.center,
              maxLength: widget.maxlength,
              autofocus: widget.autofocus,
              inputFormatters: widget.inputFormatters,
              decoration: InputDecoration(
                  hintText: widget.hint,
                  counterText: '',
                  hintStyle: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(fontSize: widget.fontSize),
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none),
              style: Theme.of(context).textTheme.headline4!.copyWith(
                  fontWeight: FontWeight.bold, fontSize: widget.fontSize)),
        ],
      ),
    );
  }
}
