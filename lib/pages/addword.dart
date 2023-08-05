import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:uuid/uuid.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/history.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/pages/drafts.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services/edit_history.dart';
import 'package:vocabhub/services/services/vocabstore.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/widgets.dart';

import '../constants/constants.dart';

class AddWordForm extends ConsumerStatefulWidget {
  final bool isEdit;
  final Word? word;
  static const String route = '/addword';

  const AddWordForm({Key? key, this.isEdit = false, this.word}) : super(key: key);

  @override
  _AddWordFormState createState() => _AddWordFormState();
}

class _AddWordFormState extends ConsumerState<AddWordForm> {
  late Size size;
  VocabStoreService supaStore = VocabStoreService();

  late TextEditingController wordController;
  late TextEditingController meaningController;
  late TextEditingController exampleController;
  late TextEditingController synonymController;
  late TextEditingController mnemonicController;
  late TextEditingController commentController;

  /// add a new word
  Future<void> addWord() async {
    showCircularIndicator(context);
    final newWord = wordController.text.trim();
    final meaning = meaningController.text.trim();
    Word wordObject;
    if (newWord.isNotEmpty && meaning.isNotEmpty) {
      wordObject = buildWordFromFields()!;
    } else {
      _requestNotifier.value =
          Response(state: RequestState.error, message: 'Word and Meaning are required');
      Future.delayed(Duration(seconds: 3), () {
        _requestNotifier.value = Response(state: RequestState.done);
      });
      stopCircularIndicator(context);
      return;
    }
    analytics.logWordAddSubmit(wordObject, 'submitted');
    try {
      if (await wordExists(wordObject)) {
        stopCircularIndicator(context);
        _requestNotifier.value = Response(
            state: RequestState.error, message: 'Word "${wordObject.word}" already exists!');
        return;
      }
      var history = EditHistory.fromWord(wordObject, userProvider!.email);
      history = history.copyWith(
        edit_type: EditType.add,
      );
      final response = await EditHistoryService.insertHistory(history);
      if (response.didSucced) {
        history = history.copyWith(
          users_mobile: userProvider!,
        );
        analytics.logWordAddSubmit(wordObject, 'success');
        pushNotificationService.sendNotification(Constants.constructEditPayload(history));
        NavbarNotifier.showSnackBar(
            context, 'Congrats! Your new word ${editedWord.word} is under review!', onClosed: () {
          stopCircularIndicator(context);
          Navigate.popView(context);
        });
      } else {
        _requestNotifier.value =
            Response(state: RequestState.error, message: 'Failed to add ${editedWord.word}');
        stopCircularIndicator(context);
      }
    } catch (x) {
      stopCircularIndicator(context);
      NavbarNotifier.showSnackBar(context, x.toString(), onClosed: () {});
      _requestNotifier.value = Response(state: RequestState.error, message: '$x');
    }
  }

  Word? buildWordFromFields() {
    final newWord = wordController.text.trim();
    final meaning = meaningController.text;
    Word wordObject = Word(
      Uuid().v1(),
      newWord.trim().capitalize()!,
      meaning,
    );
    wordObject = wordObject.copyWith(
        examples: editedWord.examples,
        synonyms: editedWord.synonyms,
        mnemonics: editedWord.mnemonics);
    return wordObject;
  }

  Future<bool> wordExists(Word editedWord) async {
    final currentWordFromDatabase =
        await VocabStoreService.findByWord(editedWord.word.capitalize()!);
    if (currentWordFromDatabase == null) {
      _requestNotifier.value = Response(state: RequestState.done);
      return false;
    }
    _requestNotifier.value = Response(state: RequestState.error, message: 'Word already exists');
    return true;
  }

  final analytics = Analytics.instance;
  final _requestNotifier =
      ValueNotifier<Response>(Response(message: '', state: RequestState.error));
  Word? currentWordFromDatabase;
  late String _title;

  @override
  void initState() {
    super.initState();
    analytics.logRouteView(AddWordForm.route);
    wordController = TextEditingController();
    meaningController = TextEditingController();
    exampleController = TextEditingController();
    synonymController = TextEditingController();
    mnemonicController = TextEditingController();
    commentController = TextEditingController();
    wordFocus = FocusNode(canRequestFocus: true);
    meaningFocus = FocusNode(canRequestFocus: true);
    _title = 'Lets add a new word';
    if (widget.isEdit) {
      _populateData(word: widget.word);
      _title = 'Editing Word';
    }
    exampleController.addListener(_rebuild);
    synonymController.addListener(_rebuild);
    mnemonicController.addListener(_rebuild);
  }

  void _populateData({Word? word}) {
    if (word != null) {
      editedWord = word.deepCopy();
    } else {
      editedWord = widget.word!.deepCopy();
    }
    wordController.text = word!.word;
    meaningController.text = word.meaning;
  }

  /// when field contains some info and user has not clicked on tick
  /// applies to synonyms, examples, mnemonics
  void _rebuild() {
    final synonym = synonymController.text;
    final example = exampleController.text;
    final mnemonic = mnemonicController.text;
    if (synonym.isNotEmpty || example.isNotEmpty || mnemonic.isNotEmpty) {
      _requestNotifier.value =
          Response(state: RequestState.error, message: 'Please submit the field');
    } else {
      _requestNotifier.value = Response(state: RequestState.done);
    }
    setState(() {});
  }

  /// Edit mode
  Future<void> updateWord() async {
    showCircularIndicator(context);
    final newWord = wordController.text.trim();
    final meaning = meaningController.text.trim();
    try {
      if (newWord.isNotEmpty && meaning.isNotEmpty) {
        editedWord = editedWord.copyWith(id: widget.word!.id, word: newWord, meaning: meaning);
        final comments = commentController.text.trim();
        var history = EditHistory.fromWord(editedWord, userProvider!.email);
        history = history.copyWith(
            edit_type: EditType.edit,
            comments: comments.isEmpty ? 'Edited word: ${editedWord.word}' : comments);
        if (widget.word != editedWord) {
          final response = await EditHistoryService.insertHistory(history);
          history = history.copyWith(
            users_mobile: userProvider!,
          );
          if (response.didSucced) {
            pushNotificationService.sendNotification(Constants.constructEditPayload(history));
            NavbarNotifier.showSnackBar(context, "$WORD_SUBMITTED", onClosed: () {
              stopCircularIndicator(context);
              Navigate.popView(context);
            });
          } else {
            stopCircularIndicator(context);
            NavbarNotifier.showSnackBar(context, "Failed to update word. Try again later!  ",
                onClosed: () {});
          }
        } else {
          stopCircularIndicator(context);
          NavbarNotifier.showSnackBar(context, "No changes to update", onClosed: () {});
        }
      }
    } catch (_) {
      stopCircularIndicator(context);
      NavbarNotifier.showSnackBar(context, _.toString(), onClosed: () {});
    }
  }

  Future<void> deleteWord() async {
    try {
      if (widget.isEdit) {
        showCircularIndicator(context);
        final String id = widget.word!.id;
        final response = await VocabStoreService.deleteById(id);
        if (response.status == 200) {
          analytics.logWordDelete(widget.word!, userProvider!.email);
          NavbarNotifier.showSnackBar(
              context, "The word \"${widget.word!.word}\" has been deleted.",
              onClosed: () => Navigate.popView(context));
        } else {
          final error = response.error;
          NavbarNotifier.showSnackBar(context, "Failed to delete word", onClosed: () {});
        }
        stopCircularIndicator(context);
      }
    } catch (_) {
      stopCircularIndicator(context);
      NavbarNotifier.showSnackBar(context, "Failed to delete word", onClosed: () {});
    }
  }

  Future<void> _showAlert() async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => VocabAlert(
            title: 'Are you sure you want to delete this word?',
            onAction1: () {
              Navigator.of(context).pop();
              deleteWord();
            },
            onAction2: () {
              Navigate.popView(context);
            }));
  }

  @override
  void dispose() {
    wordController.dispose();
    meaningController.dispose();
    exampleController.dispose();
    synonymController.dispose();
    mnemonicController.dispose();
    _requestNotifier.dispose();
    super.dispose();
  }

  Future<bool> showUnSavedDialog() async {
    bool shouldExit = false;
    await showDialog(
        context: context,
        builder: (x) => VocabAlert(
            title: 'Save word to drafts?',
            subtitle: 'We will pull up this word from drafts, next time you try to add a word',
            actionTitle1: 'Discard & Close',
            actionTitle2: 'Save',
            onAction1: () {
              shouldExit = true;
              Navigator.of(context).pop();
            },
            onAction2: () async {
              shouldExit = true;
              await addWordController.saveDrafts(editedWord);
              Navigator.of(context).pop();
            }));
    return shouldExit;
  }

  Future<void> showLoadDraftsDialog() async {
    // drafts found in local storage
    await showDialog(
        context: context,
        builder: (x) => VocabAlert(
            title: 'Load Word from Drafts',
            subtitle: 'We will pull up this word from drafts, next time you try to add a word',
            actionTitle1: 'Add New Word',
            actionTitle2: 'Load UnPublished Word',
            onAction1: () {
              Navigator.of(context).pop();
            },
            onAction2: () async {
              // _populateData(word: addWordController.drafts);
              Navigator.of(context).pop();
            }));
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final List<GlobalKey<FormFieldState>> _formFieldKeys =
      List.generate(4, (x) => GlobalKey<FormFieldState>());
  Word editedWord = Word('', '', '');
  late FocusNode wordFocus;
  late FocusNode meaningFocus;
  UserModel? userProvider;
  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    Widget synonymChip(String synonym, Function onDeleted) {
      return InputChip(
        label: Text(
          '${synonym.trim().capitalize()}',
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
        ),
        onDeleted: () => onDeleted(),
        isEnabled: true,
        backgroundColor: Theme.of(context).primaryColor,
        deleteButtonTooltipMessage: 'remove',
      );
    }

    userProvider = ref.watch(userNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: ValueListenableBuilder<Response>(
          valueListenable: _requestNotifier,
          builder: (BuildContext context, Response request, Widget? child) {
            return WillPopScope(
              onWillPop: () async {
                removeFocus(context);
                final bool isEmpty = editedWord.isWordEmpty();
                if (!isEmpty && !widget.isEdit) {
                  bool shouldExit = await showUnSavedDialog();
                  return shouldExit;
                }
                return Future.value(true);
              },
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: colorScheme.background,
                appBar: AppBar(
                  title: Text(widget.isEdit ? 'Edit Word' : 'Add word'),
                  elevation: 5,
                  actions: [
                    if (!widget.isEdit)
                      IconButton(
                          onPressed: () async {
                            removeFocus(context);
                            Word selectedDraft = await Navigate.push(context, Drafts(),
                                transitionType: TransitionType.rtl);
                            _populateData(word: selectedDraft);
                          },
                          icon: Icon(Icons.drafts)),
                  ],
                ),
                body: Form(
                  key: _formKey,
                  onChanged: () {
                    // update button state
                    editedWord = buildWordFromFields()!;
                    if (widget.word != null && widget.word!.equals(editedWord)) {
                      _requestNotifier.value = _requestNotifier.value
                          .copyWith(message: 'No changes made', state: RequestState.error);
                    } else {
                      _requestNotifier.value =
                          _requestNotifier.value.copyWith(state: RequestState.none);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ListView(
                      children: [
                        25.0.vSpacer(),
                        VocabField(
                          fieldKey: _formFieldKeys[0],
                          autofocus: true,
                          fontSize: 30,
                          maxlength: 20,
                          hint: 'e.g Ambivalent',
                          onChange: (x) async {
                            editedWord = editedWord.copyWith(word: x);
                            if (!widget.isEdit) {
                              final currentWordFromDatabase =
                                  await VocabStoreService.findByWord(editedWord.word.capitalize()!);
                              if (currentWordFromDatabase != null) {
                                _requestNotifier.value = Response(
                                    state: RequestState.error, message: 'Word already exists');
                              } else {
                                _requestNotifier.value = Response(state: RequestState.done);
                              }
                              setState(() {});
                            }
                          },
                          focusNode: wordFocus,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp('[A-Z-a-z]+'))
                          ],
                          controller: wordController,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: VocabField(
                            fieldKey: _formFieldKeys[1],
                            hint: 'What does ' +
                                '${editedWord.word.isEmpty ? 'it mean?' : '${editedWord.word} mean?'}',
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
                          children: List.generate(editedWord.synonyms!.length, (index) {
                            return synonymChip(editedWord.synonyms![index], () {
                              editedWord.synonyms!.remove(editedWord.synonyms![index]);
                              setState(() {});
                            });
                          }),
                        ),
                        editedWord.synonyms!.length == maxSynonymCount
                            ? SizedBox.shrink()
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
                                        FilteringTextInputFormatter.allow(RegExp('[A-Z-a-z]+')),
                                        // FilteringTextInputFormatter.deny(wordController.text)
                                      ],
                                      controller: synonymController,
                                    ),
                                  ),
                                  synonymController.text.isNotEmpty
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0, right: 16, top: 8),
                                          child: IconButton(
                                              onPressed: () {
                                                final String newSynonym = synonymController.text;
                                                if (newSynonym.toLowerCase() ==
                                                    editedWord.word.toLowerCase()) {
                                                  NavbarNotifier.showSnackBar(
                                                      context, 'Synonym cannot be same as word',
                                                      bottom: 0);
                                                  synonymController.clear();
                                                  return;
                                                }
                                                if (editedWord.word.isNotEmpty) {
                                                  if (newSynonym.isNotEmpty &&
                                                      !editedWord.synonyms!.contains(newSynonym)) {
                                                    editedWord = editedWord.copyWith(synonyms: [
                                                      ...editedWord.synonyms!,
                                                      newSynonym
                                                    ]);
                                                    synonymController.clear();
                                                  }
                                                } else {
                                                  NavbarNotifier.showSnackBar(
                                                      context, 'You must add a word first');
                                                  FocusScope.of(context).requestFocus(wordFocus);
                                                  synonymController.clear();
                                                }
                                              },
                                              icon: Icon(Icons.done, size: 32)),
                                        )
                                      : Container(),
                                ],
                              ),
                        30.0.hSpacer(),
                        ...List.generate(editedWord.examples!.length, (index) {
                          return Container(
                            margin:
                                EdgeInsets.symmetric(horizontal: SizeUtils.isMobile ? 16 : 24.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child:
                                        buildExample(editedWord.examples![index], editedWord.word)),
                                GestureDetector(
                                    onTap: () {
                                      editedWord.examples!
                                          .remove(editedWord.examples!.elementAt(index));
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Icon(Icons.delete),
                                    )),
                              ],
                            ),
                          );
                        }),
                        editedWord.examples!.length < maxExampleCount
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: VocabField(
                                      fieldKey: _formFieldKeys[2],
                                      hint:
                                          'An example sentence ${editedWord.word.isEmpty ? "" : "with ${editedWord.word}"} (Optional)',
                                      controller: exampleController,
                                      maxlines: 4,
                                    ),
                                  ),
                                  exampleController.text.isNotEmpty
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0, right: 16, top: 8),
                                          child: IconButton(
                                              onPressed: () {
                                                final String text = exampleController.text;
                                                if (editedWord.word.isNotEmpty) {
                                                  editedWord = editedWord.copyWith(
                                                      examples: [...editedWord.examples!, text]);
                                                  exampleController.clear();
                                                } else {
                                                  NavbarNotifier.showSnackBar(
                                                      context, 'Add a word first');
                                                  FocusScope.of(context).requestFocus(wordFocus);
                                                }
                                                setState(() {});
                                              },
                                              icon: Icon(Icons.done, size: 32)),
                                        )
                                      : Container(),
                                ],
                              )
                            : SizedBox.shrink(),
                        ...List.generate(editedWord.mnemonics!.length, (index) {
                          return Container(
                            margin:
                                EdgeInsets.symmetric(horizontal: SizeUtils.isMobile ? 16 : 24.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: buildExample(
                                        editedWord.mnemonics![index], editedWord.word)),
                                GestureDetector(
                                    onTap: () {
                                      editedWord.mnemonics!
                                          .remove(editedWord.mnemonics!.elementAt(index));
                                      setState(() {});
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                      child: Icon(Icons.delete),
                                    )),
                              ],
                            ),
                          );
                        }),
                        24.0.vSpacer(),
                        editedWord.mnemonics!.length < maxMnemonicCount
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Flexible(
                                    child: VocabField(
                                      fieldKey: _formFieldKeys[3],
                                      hint:
                                          'A mnemonic to help remember ${editedWord.word} (Optional)',
                                      controller: mnemonicController,
                                      maxlines: 4,
                                    ),
                                  ),
                                  mnemonicController.text.isNotEmpty
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(left: 16.0, right: 16, top: 8),
                                          child: IconButton(
                                              onPressed: () {
                                                final String text = mnemonicController.text;
                                                if (text.isNotEmpty) {
                                                  editedWord = editedWord.copyWith(
                                                      mnemonics: [...editedWord.mnemonics!, text]);
                                                  mnemonicController.clear();
                                                } else {
                                                  NavbarNotifier.showSnackBar(
                                                      context, 'Add a word first');
                                                  FocusScope.of(context).requestFocus(wordFocus);
                                                }
                                                setState(() {});
                                              },
                                              icon: Icon(Icons.done, size: 32)),
                                        )
                                      : Container(),
                                ],
                              )
                            : Container(),
                        widget.isEdit
                            ? VocabField(
                                hint: 'Briefly explain about your changes',
                                maxlines: 3,
                                controller: commentController)
                            : SizedBox.shrink(),
                        50.0.hSpacer(),
                        Align(
                          alignment: Alignment.center,
                          child: VHButton(
                            height: 44,
                            width: 120,
                            onTap: request.state == RequestState.error
                                ? null
                                : () => widget.isEdit ? updateWord() : addWord(),
                            label: widget.isEdit ? 'Update' : 'Submit',
                          ),
                        ),
                        16.0.vSpacer(),
                        if (request.state == RequestState.error &&
                            _requestNotifier.value.message.isNotEmpty)
                          Align(
                            alignment: Alignment.center,
                            child: Text(
                              '${_requestNotifier.value.message}',
                            ),
                          ),
                        16.0.vSpacer(),
                        Align(
                          alignment: Alignment.center,
                          child: SizedBox(
                            height: 40,
                            width: 150,
                            child: widget.isEdit && userProvider!.isAdmin
                                ? TextButton(
                                    onPressed: _showAlert,
                                    child: Text(
                                      'Delete',
                                      style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                          color: colorScheme.error,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600),
                                    ))
                                : SizedBox.shrink(),
                          ),
                        ),
                        40.0.vSpacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
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
  final Function(String)? onChange;
  final Function(String)? onSubmit;
  final Key? fieldKey;
  const VocabField(
      {Key? key,
      this.fieldKey,
      required this.hint,
      this.maxlines = 1,
      this.maxlength,
      this.focusNode,
      this.onChange,
      this.onSubmit,
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
    final style = Theme.of(context).textTheme.headlineMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
              key: widget.fieldKey,
              controller: widget.controller,
              maxLines: widget.maxlines,
              textAlign: TextAlign.center,
              maxLength: widget.maxlength,
              autofocus: widget.autofocus,
              focusNode: widget.focusNode,
              textInputAction: TextInputAction.next,
              onFieldSubmitted: (x) {
                if (widget.onSubmit != null) widget.onSubmit!(x);
              },
              inputFormatters: widget.inputFormatters,
              onChanged: (x) {
                if (widget.onChange != null) widget.onChange!(x);
              },
              decoration: InputDecoration(
                  hintText: widget.hint,
                  counterText: '',
                  hintStyle: style!.copyWith(fontSize: widget.fontSize, color: Colors.grey),
                  focusedBorder: InputBorder.none,
                  border: InputBorder.none),
              style: style.copyWith(fontWeight: FontWeight.bold, fontSize: widget.fontSize)),
        ],
      ),
    );
  }
}

class VocabAlert extends StatelessWidget {
  final String title;
  final String actionTitle1;
  final String actionTitle2;
  final Function()? onAction1;
  final Function()? onAction2;
  final String? subtitle;

  const VocabAlert(
      {Key? key,
      required this.title,
      this.subtitle,
      this.actionTitle1 = 'Delete',
      this.actionTitle2 = 'Cancel',
      required this.onAction1,
      required this.onAction2})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: subtitle != null ? Text(subtitle!) : null,
      actions: [
        TextButton(
          onPressed: onAction1,
          child: Text(
            actionTitle1,
            style: TextStyle(color: VocabTheme.errorColor),
          ),
        ),
        TextButton(
          onPressed: onAction2,
          child: Text(
            actionTitle2,
          ),
        ),
      ],
    );
  }
}
