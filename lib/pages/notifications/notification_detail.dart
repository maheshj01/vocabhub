import 'package:flutter/material.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class NotificationDetail extends StatefulWidget {
  final EditHistory editHistory;

  static const String route = '/';

  const NotificationDetail({Key? key, required this.editHistory}) : super(key: key);

  @override
  State<NotificationDetail> createState() => _NotificationDetailState();
}

class _NotificationDetailState extends State<NotificationDetail> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
        desktopBuilder: (context) => NotificationDetailMobile(
              editHistory: widget.editHistory,
            ),
        mobileBuilder: (context) => NotificationDetailMobile(
              editHistory: widget.editHistory,
            ));
  }
}

class NotificationDetailDesktop extends StatelessWidget {
  const NotificationDetailDesktop({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('NotificationDetailDesktop'),
      ),
    );
  }
}

class NotificationDetailMobile extends StatefulWidget {
  NotificationDetailMobile({Key? key, required this.editHistory}) : super(key: key);

  /// current edit
  final EditHistory editHistory;

  @override
  State<NotificationDetailMobile> createState() => _NotificationDetailMobileState();
}

class _NotificationDetailMobileState extends State<NotificationDetailMobile> {
  Future<void> getCurrentWord() async {
    currentEdit = Word(
        widget.editHistory.word_id, widget.editHistory.word, widget.editHistory.meaning,
        synonyms: widget.editHistory.synonyms,
        examples: widget.editHistory.examples,
        mnemonics: widget.editHistory.mnemonics);

    // find previous approved word
    final resp = await EditHistoryService.findPreviousEditsByWord(widget.editHistory.word);
    // findById(widget.edit_history.word_id);
    if (resp.status == 200) {
      final list = resp.data as List;
      // case when word is added and deleted
      // The difference should show the word was added/deleted
      for (int i = 0; i < list.length; i++) {
        final data = list[i];
        final history = EditHistory.fromJson(data);
        if (history.edit_id == widget.editHistory.edit_id) {
          if (i == 0) {
            lastEdit = Word.fromEditHistoryJson(data);
          } else {
            lastEdit = Word.fromEditHistoryJson(list[i - 1]);
          }
        }
      }
    } else {
      lastEdit = Word('', '', '');
    }
    currentWordNotifier.value = lastEdit;
  }

  ValueNotifier<Word> currentWordNotifier = ValueNotifier(Word('', '', ''));

  /// edit from database before the current edit
  late Word lastEdit;

  late Word currentEdit;
  @override
  void initState() {
    super.initState();
    getCurrentWord();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final editState = widget.editHistory.state;
    final editType = widget.editHistory.edit_type;
    return Scaffold(
        backgroundColor: colorScheme.background,
        appBar: AppBar(
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Edit Detail (${editState!.toName().capitalize()})',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        body: ValueListenableBuilder<Word>(
            valueListenable: currentWordNotifier,
            builder: (context, Word value, Widget? child) {
              if (value.id == '') {
                return LoadingWidget();
              }
              List<Widget> _children = [
                widget.editHistory.edit_type == EditType.edit
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Old Version',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          16.0.vSpacer(),
                          heading('Word'),
                          8.0.vSpacer(),
                          differenceVisualizerGranular(currentEdit.word, lastEdit.word,
                              isOldVersion: true),
                          8.0.vSpacer(),
                          heading('Meaning'),
                          8.0.vSpacer(),
                          differenceVisualizerGranular(currentEdit.meaning, lastEdit.meaning,
                              isOldVersion: true),
                          8.0.vSpacer(),
                          heading('Synonyms'),
                          8.0.vSpacer(),
                          differenceVisualizerGranular(
                              currentEdit.synonyms!.join(','), lastEdit.synonyms!.join(','),
                              isOldVersion: true),
                          8.0.vSpacer(),
                          heading('Examples'),
                          8.0.vSpacer(),
                          differenceVisualizerGranular(
                              currentEdit.examples!.join(','), lastEdit.examples!.join(','),
                              isOldVersion: true),
                          8.0.vSpacer(),
                          heading('Mnemonics'),
                          8.0.vSpacer(),
                          differenceVisualizerGranular(
                              currentEdit.mnemonics!.join(','), lastEdit.mnemonics!.join(','),
                              isOldVersion: true),
                          Padding(
                            padding: 8.0.verticalPadding,
                            child: hLine(),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      editType == EditType.add ? 'New Word' : 'New Version',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    16.0.vSpacer(),
                    heading('Word'),
                    8.0.vSpacer(),
                    differenceVisualizerGranular(currentEdit.word, lastEdit.word,
                        isOldVersion: false),
                    8.0.vSpacer(),
                    heading('Meaning'),
                    8.0.vSpacer(),
                    differenceVisualizerGranular(currentEdit.meaning, lastEdit.meaning,
                        isOldVersion: false),
                    8.0.vSpacer(),
                    heading('Synonyms'),
                    8.0.vSpacer(),
                    differenceVisualizerGranular(
                        currentEdit.synonyms!.join(','), lastEdit.synonyms!.join(','),
                        isOldVersion: false),
                    8.0.vSpacer(),
                    heading('Examples'),
                    8.0.vSpacer(),
                    differenceVisualizerGranular(
                        currentEdit.examples!.join(','), lastEdit.examples!.join(','),
                        isOldVersion: false),
                    8.0.vSpacer(),
                    heading('Mnemonics'),
                    8.0.vSpacer(),
                    differenceVisualizerGranular(
                        currentEdit.mnemonics!.join(','), lastEdit.mnemonics!.join(','),
                        isOldVersion: false),
                    8.0.vSpacer(),
                  ],
                )
              ];
              return Padding(
                  padding: 12.0.horizontalPadding,
                  child: SingleChildScrollView(
                    scrollDirection: SizeUtils.isDesktop ? Axis.horizontal : Axis.vertical,
                    child: SizeUtils.isMobile
                        ? Column(crossAxisAlignment: CrossAxisAlignment.start, children: _children)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _children,
                          ),
                  ));
            }));
  }
}

/// Authenticate User using social auth
/// Allow users to post their ad
///
