import 'package:flutter/material.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class EditDetail extends StatefulWidget {
  final EditHistory edit_history;

  static const String route = '/';

  const EditDetail({Key? key, required this.edit_history}) : super(key: key);

  @override
  State<EditDetail> createState() => _EditDetailState();
}

class _EditDetailState extends State<EditDetail> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => EditDetailDesktop(),
        mobileBuilder: (context) => EditDetailMobile(
              edit_history: widget.edit_history,
            ));
  }
}

class EditDetailDesktop extends StatelessWidget {
  const EditDetailDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('EditDetailDesktop'),
      ),
    );
  }
}

class EditDetailMobile extends StatefulWidget {
  EditDetailMobile({Key? key, required this.edit_history}) : super(key: key);
  final EditHistory edit_history;

  @override
  State<EditDetailMobile> createState() => _EditDetailMobileState();
}

class _EditDetailMobileState extends State<EditDetailMobile> {

  Future<void> getCurrentWord() async {
    editedWord = Word(widget.edit_history.word_id, widget.edit_history.word,
        widget.edit_history.meaning,
        synonyms: widget.edit_history.synonyms,
        examples: widget.edit_history.examples,
        mnemonics: widget.edit_history.mnemonics);
    if (widget.edit_history.edit_type != EditType.edit) {
      currentWordNotifier.value = editedWord;
      currentWord = editedWord;
      return;
    }
    ;
    final resp = await VocabStoreService.findById(widget.edit_history.word_id);
    if (resp.status == 200) {
      currentWord = Word.fromJson(resp.data);
    } else {
      print("Failed to get word");
      currentWord = Word('', '', '');
    }
    currentWordNotifier.value = currentWord;
  }

  ValueNotifier<Word> currentWordNotifier = ValueNotifier(Word('', '', ''));

  late Word currentWord;
  late Word editedWord;
  @override
  void initState() {
    super.initState();
    getCurrentWord();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Edit Detail',
            style: Theme.of(context).textTheme.headline6,
          ),
        ),
        body: ValueListenableBuilder<Word>(
            valueListenable: currentWordNotifier,
            builder: (context, Word value, Widget? child) {
              if (value.id == '') {
                return LoadingWidget();
              }
              return Padding(
                padding: 12.0.horizontalPadding,
                child: SingleChildScrollView(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget.edit_history.edit_type == EditType.edit
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Old Version',
                                    style:
                                        Theme.of(context).textTheme.headline6,
                                  ),
                                  16.0.vSpacer(),
                                  heading('Word'),
                                  8.0.vSpacer(),
                                  differenceVisualizerGranular(
                                      editedWord.word, currentWord.word,
                                      isOldVersion: true),
                                  8.0.vSpacer(),
                                  heading('Meaning'),
                                  8.0.vSpacer(),
                                  differenceVisualizerGranular(
                                      editedWord.meaning, currentWord.meaning,
                                      isOldVersion: true),
                                  8.0.vSpacer(),
                                  heading('Synonyms'),
                                  8.0.vSpacer(),
                                  differenceVisualizerGranular(
                                      editedWord.synonyms!.join(','),
                                      currentWord.synonyms!.join(','),
                                      isOldVersion: true),
                                  8.0.vSpacer(),
                                  heading('Examples'),
                                  8.0.vSpacer(),
                                  differenceVisualizerGranular(
                                      editedWord.examples!.join(','),
                                      currentWord.examples!.join(','),
                                      isOldVersion: true),
                                  8.0.vSpacer(),
                                  heading('Mnemonics'),
                                  8.0.vSpacer(),
                                  differenceVisualizerGranular(
                                      editedWord.mnemonics!.join(','),
                                      currentWord.mnemonics!.join(','),
                                      isOldVersion: true),
                                  Padding(
                                    padding: 8.0.verticalPadding,
                                    child: hLine(),
                                  ),
                                ],
                              )
                            : SizedBox.shrink(),
                        Text(
                          widget.edit_history.edit_type == EditType.add
                              ? 'New Word'
                              : 'New Version',
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        16.0.vSpacer(),
                        heading('Word'),
                        8.0.vSpacer(),
                        differenceVisualizerGranular(
                            editedWord.word, currentWord.word,
                            isOldVersion: false),
                        8.0.vSpacer(),
                        heading('Meaning'),
                        8.0.vSpacer(),
                        differenceVisualizerGranular(
                            editedWord.meaning, currentWord.meaning,
                            isOldVersion: false),
                        8.0.vSpacer(),
                        heading('Synonyms'),
                        8.0.vSpacer(),
                        differenceVisualizerGranular(
                            editedWord.synonyms!.join(','),
                            currentWord.synonyms!.join(','),
                            isOldVersion: false),
                        8.0.vSpacer(),
                        heading('Examples'),
                        8.0.vSpacer(),
                        differenceVisualizerGranular(
                            editedWord.examples!.join(','),
                            currentWord.examples!.join(','),
                            isOldVersion: false),
                        8.0.vSpacer(),
                        heading('Mnemonics'),
                        8.0.vSpacer(),
                        differenceVisualizerGranular(
                            editedWord.mnemonics!.join(','),
                            currentWord.mnemonics!.join(','),
                            isOldVersion: false),
                        8.0.vSpacer(),
                      ]),
                ),
              );
            }));
  }
}
