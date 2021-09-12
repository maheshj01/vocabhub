import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/supastore.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/widgets.dart';

class AddWordForm extends StatefulWidget {
  final bool isEdit;
  final Word? word;

  const AddWordForm({Key? key, this.isEdit = false, this.word})
      : super(key: key);

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
  late TextEditingController mnemonicController;

  Future<void> submitForm() async {
    showCircularIndicator(context);
    final newWord = wordController.text;
    final meaning = meaningController.text;
    try {
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
        if (_synonyms.isNotEmpty) {
          wordObject.synonyms = _synonyms;
        }
        if (_mnemonics.isNotEmpty) {
          wordObject.mnemonics = _mnemonics;
        }

        final response = await supaStore.addWord(wordObject);
        if (response.didSucced) {
          firebaseAnalytics.logWordAdd(wordObject, userProvider.email);
          showMessage(context, 'Congrats! You just added $word to vocabhub',
              onClosed: () {
            List<Word?>? newList = listNotifier.value;
            newList!.add(response.data as Word);
            totalNotifier.value = newList.length;
            stopCircularIndicator(context);
            Navigate().popView(context);
          });
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
    } catch (x) {
      stopCircularIndicator(context);
      setState(() {
        isDisabled = false;
        error = '$x';
        _errorNotifier.value = true;
      });
    }
  }

  final firebaseAnalytics = Analytics();
  final _errorNotifier = ValueNotifier<bool>(false);
  @override
  void initState() {
    super.initState();
    wordController = TextEditingController();
    meaningController = TextEditingController();
    exampleController = TextEditingController();
    synonymController = TextEditingController();
    mnemonicController = TextEditingController();
    wordFocus = FocusNode(canRequestFocus: true);
    meaningFocus = FocusNode(canRequestFocus: true);
    _title = 'Lets add a new word';
    if (widget.isEdit) {
      _populateData();
      _title = 'Editing Word';
    }

    wordController.addListener(_listenWordChanges);
    meaningController.addListener(() {
      if (wordController.text.isNotEmpty && meaningController.text.isNotEmpty) {
        _errorNotifier.value = false;
      }
    });
    exampleController.addListener(_rebuild);
    synonymController.addListener(_rebuild);
    mnemonicController.addListener(_rebuild);
    userProvider = Provider.of<UserModel>(context, listen: false);
  }

  void _populateData() {
    wordController.text = widget.word!.word;
    meaningController.text = widget.word!.meaning;
    if (widget.word!.synonyms != null && widget.word!.synonyms!.isNotEmpty) {
      _synonyms = widget.word!.synonyms!;
    }
    if (widget.word!.examples != null && widget.word!.examples!.isNotEmpty) {
      _examples = widget.word!.examples!;
    }
    if (widget.word!.mnemonics != null && widget.word!.mnemonics!.isNotEmpty) {
      _mnemonics = widget.word!.mnemonics!;
    }
  }

  void _rebuild() {
    final synonym = synonymController.text;
    final example = exampleController.text;
    final mnemonic = mnemonicController.text;
    if (synonym.isNotEmpty || example.isNotEmpty || mnemonic.isNotEmpty) {
      error = 'Please submit the field';
      _errorNotifier.value = true;
      isDisabled = true;
    } else {
      _errorNotifier.value = false;
      isDisabled = false;
    }
    setState(() {});
  }

  void _listenWordChanges() {
    setState(() {
      word = wordController.text;
    });
    if (wordController.text.isNotEmpty && meaningController.text.isNotEmpty) {
      _errorNotifier.value = false;
    }
    if (widget.isEdit) {
      /// TODO: Compare each field if
      /// there is a change in Object if yes then isDisabled = false
      setState(() {
        isDisabled = false;
      });
    } else {
      final list = listNotifier.value;
      Word found = list!.firstWhere(
          (element) => element.word.toLowerCase() == word.toLowerCase(),
          orElse: () => Word('', '', ''));
      if (found.word.isNotEmpty) {
        setState(() {
          isDisabled = true;
        });
        error = '${word.capitalize()} already present';
        _errorNotifier.value = true;
      } else {
        setState(() {
          isDisabled = false;
        });
        _errorNotifier.value = false;
      }
    }
  }

  /// Edit mode
  Future<void> updateWord() async {
    showCircularIndicator(context);
    String id = widget.word!.id;
    Word word = widget.word!;
    final newWord = wordController.text;
    final meaning = meaningController.text;
    if (newWord.isNotEmpty && meaning.isNotEmpty) {
      setState(() {
        isDisabled = true;
      });
      // TODO: to be removed in a future release
      word.word = newWord;
      word.meaning = meaning;
      if (_examples.isNotEmpty) {
        word.examples = _examples;
      }
      if (_synonyms.isNotEmpty) {
        word.synonyms = _synonyms;
      }
      if (_mnemonics.isNotEmpty) {
        word.mnemonics = _mnemonics;
      }
      final response = await supaStore.updateWord(id: id, word: word);
      stopCircularIndicator(context);
      if (response.status == 200) {
        firebaseAnalytics.logWordEdit(word, userProvider.email);
        showMessage(context, "The word \"${word.word}\" is updated.",
            onClosed: () => Navigate().popView(context));
      } else {
        print('failed to update ${response.error!.message}');
      }
    } else {
      stopCircularIndicator(context);
      error = 'word or meaning cannot be empty!';
      _errorNotifier.value = true;
    }
  }

  Future<void> deleteWord() async {
    if (widget.isEdit) {
      showCircularIndicator(context);
      String id = widget.word!.id;
      final response = await supaStore.deleteById(id);
      stopCircularIndicator(context);
      if (response.status == 200) {
        firebaseAnalytics.logWordDelete(widget.word!, userProvider.email);
        showMessage(
            context, "The word \"${widget.word!.word}\" has been deleted.",
            onClosed: () => Navigate().popView(context));
      } else {
        print('failed to update ${response.error!.message}');
      }
    }
  }

  Future<void> _showAlert() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => VocabAlert(
            title: 'Are you sure you want to delete this word?',
            onConfirm: () {
              Navigator.of(context).pop();
              deleteWord();
            },
            onCancel: () {
              Navigate().popView(context);
            }));
  }

  @override
  void dispose() {
    wordController.dispose();
    meaningController.dispose();
    exampleController.dispose();
    synonymController.dispose();
    mnemonicController.dispose();
    _errorNotifier.dispose();
    super.dispose();
  }

  bool isDisabled = false;
  String word = '';
  List<String> _examples = [];
  List<String> _synonyms = [];
  List<String> _mnemonics = [];
  int maxExampleCount = 3;
  int maxSynonymCount = 5;
  int maxMnemonicCount = 5;
  String error = '';
  late FocusNode wordFocus;
  late FocusNode meaningFocus;
  late String _title;
  late UserModel userProvider;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    bool isDark = darkNotifier.value;
    Widget synonymChip(String synonym, Function onDeleted) {
      return InputChip(
        label: Text(
          '${synonym.trim().capitalize()}',
          style: Theme.of(context)
              .textTheme
              .headline5!
              .copyWith(color: Colors.white),
        ),
        onDeleted: () => onDeleted(),
        isEnabled: true,
        backgroundColor: isDark ? secondaryDark : secondaryColor,
        useDeleteButtonTooltip: true,
        deleteButtonTooltipMessage: 'remove',
      );
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: ListView(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 16),
                  child: IconButton(
                      onPressed: () => Navigate().popView(context),
                      icon: Icon(Icons.clear, size: 32)),
                ),
              ),
              Center(
                child: Text('$_title',
                    style: Theme.of(context)
                        .textTheme
                        .headline3!
                        .copyWith(fontWeight: FontWeight.w500)),
              ),
              SizedBox(
                height: 25,
              ),
              VocabField(
                autofocus: true,
                fontSize: 30,
                maxlength: 20,
                hint: 'e.g Ambivalent',
                focusNode: wordFocus,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[A-Z-a-z]+'))
                ],
                controller: wordController,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: VocabField(
                  hint: 'What does ' +
                      '${word.isEmpty ? 'it mean?' : word + ' mean?'}',
                  controller: meaningController,
                  focusNode: meaningFocus,
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
                                  RegExp('[A-Z-a-z]+'))
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
                                      if (word.isNotEmpty) {
                                        if (newSynonym.isNotEmpty) {
                                          _synonyms.add(newSynonym);
                                        }
                                      } else {
                                        showMessage(context,
                                            'You must add a word first');
                                        FocusScope.of(context)
                                            .requestFocus(wordFocus);
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
                height: 30,
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
                                        exampleController.clear();
                                      } else {
                                        showMessage(
                                            context, 'Add a word first');
                                        FocusScope.of(context)
                                            .requestFocus(wordFocus);
                                      }
                                      setState(() {});
                                    },
                                    icon: Icon(Icons.done, size: 32)),
                              )
                            : Container(),
                      ],
                    )
                  : Container(),
              ...List.generate(_mnemonics.length, (index) {
                return Container(
                  margin: EdgeInsets.symmetric(
                      horizontal: size.width < MOBILE_WIDTH ? 16 : 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(child: buildExample(_mnemonics[index], word)),
                      GestureDetector(
                          onTap: () {
                            _mnemonics.remove(_mnemonics.elementAt(index));
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
              SizedBox(
                height: 24,
              ),
              _mnemonics.length < maxMnemonicCount
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          child: VocabField(
                            hint:
                                'A mnemonic to help remember $word (Optional)',
                            controller: mnemonicController,
                            maxlines: 4,
                          ),
                        ),
                        mnemonicController.text.isNotEmpty
                            ? Padding(
                                padding: const EdgeInsets.only(
                                    left: 16.0, right: 16, top: 8),
                                child: IconButton(
                                    onPressed: () {
                                      String text = mnemonicController.text;
                                      if (word.isNotEmpty) {
                                        _mnemonics.add(text);
                                        mnemonicController.clear();
                                      } else {
                                        showMessage(
                                            context, 'Add a word first');
                                        FocusScope.of(context)
                                            .requestFocus(wordFocus);
                                      }
                                      setState(() {});
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
                  child: SizedBox(
                    height: 40,
                    width: 100,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: isDark ? Colors.teal : primaryColor,
                        ),
                        onPressed: isDisabled
                            ? null
                            : () => widget.isEdit ? updateWord() : submitForm(),
                        child: Text(widget.isEdit ? 'Update' : 'Submit',
                            style: TextStyle(
                                color:
                                    isDisabled ? Colors.black : Colors.white))),
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
                height: 16,
              ),
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  height: 40,
                  width: 150,
                  child: widget.isEdit && emails.contains(userProvider.email)
                      ? TextButton(
                          onPressed: _showAlert,
                          child: Text(
                            'Delete',
                            style: Theme.of(context)
                                .textTheme
                                .headline4!
                                .copyWith(
                                    color: errorColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600),
                          ))
                      : SizedBox(),
                ),
              ),
              SizedBox(
                height: 40,
              )
            ],
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
  final FocusNode? focusNode;
  final List<TextInputFormatter>? inputFormatters;
  final TextEditingController controller;

  const VocabField(
      {Key? key,
      required this.hint,
      this.maxlines = 1,
      this.maxlength,
      this.focusNode,
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
              focusNode: widget.focusNode,
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

class VocabAlert extends StatelessWidget {
  final String title;
  final Function()? onConfirm;
  final Function()? onCancel;

  const VocabAlert(
      {Key? key,
      required this.title,
      required this.onConfirm,
      required this.onCancel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    return AlertDialog(
      content: Text(title),
      actions: [
        TextButton(
          onPressed: onConfirm,
          child: Text(
            'Delete',
            style: TextStyle(color: errorColor),
          ),
        ),
        TextButton(
          onPressed: onCancel,
          child: Text(
            'Cancel',
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
          ),
        ),
      ],
    );
  }
}
