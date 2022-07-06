import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/search.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/word_list_tile.dart';
import 'package:vocabhub/widgets/worddetail.dart';

class Search extends StatefulWidget {
  static String route = '/';
  const Search({Key? key}) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  int selectedIndex = 0;
  Word? selectedWord;
  final ScrollController controller = ScrollController();

  @override
  void dispose() {
    // todo: dispose of the controller
    // wordsNotifier.dispose();
    super.dispose();
  }

  final DraggableScrollableController _draggableScrollableController =
      DraggableScrollableController();

  void _scrollSheetToSize({double size = 0.6}) {
    SchedulerBinding.instance.addPostFrameCallback((x) {
      _draggableScrollableController.animateTo(size,
          duration: Duration(milliseconds: 300), curve: Curves.easeIn);
    });
  }

  @override
  Widget build(BuildContext context) {
    final words = AppStateScope.of(context).words;
    return words == null
        ? LoadingWidget()
        : ResponsiveBuilder(desktopBuilder: (context) {
            return Row(
              children: [
                Flexible(
                  child: WordList(
                    onSelected: (word) {
                      setState(() {
                        selectedWord = word;
                        selectedIndex = words.indexOf(word);
                      });
                    },
                  ),
                ),
                Expanded(
                    flex: 2,
                    child: WordDetail(word: selectedWord ?? words.first)),
              ],
            );
          }, mobileBuilder: (BuildContext context) {
            return Stack(
              fit: StackFit.expand,
              children: [
                GestureDetector(
                  onTapDown: (x) {
                    removeFocus(context);
                    _scrollSheetToSize(size: 0.2);
                  },
                  child: WordDetail(word: words[selectedIndex]),
                ),
                DraggableScrollableSheet(
                    maxChildSize: 0.6,
                    minChildSize: 0.2,
                    controller: _draggableScrollableController,
                    expand: true,
                    builder: ((context, scrollController) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: 16.0.allRadius,
                            boxShadow: [VocabTheme.secondaryShadow]),
                        child: WordList(
                          onFocus: () {
                            _scrollSheetToSize(size: 0.6);
                          },
                          controller: scrollController,
                          onSelected: (word) {
                            setState(() {
                              selectedIndex = words.indexOf(word);
                            });
                            _scrollSheetToSize(size: 0.2);
                          },
                        ),
                      );
                    }))
              ],
            );
          });
  }
}

class WordList extends StatefulWidget {
  final Function(Word) onSelected;
  ScrollController? controller;
  final Function? onFocus;

  WordList({Key? key, required this.onSelected, this.controller, this.onFocus})
      : super(key: key);

  @override
  State<WordList> createState() => _WordListState();
}

class _WordListState extends State<WordList> {
  @override
  void initState() {
    wordsNotifier = ValueNotifier<List<Word>>([]);
    widget.controller ??= ScrollController();
    super.initState();
  }

  bool isInSynonym(String query, List<String>? synonyms) {
    bool result = false;
    if (synonyms == null || synonyms.isEmpty) {
      return result;
    }
    synonyms.forEach((element) {
      if (element.toLowerCase() == query.toLowerCase()) {
        result = true;
      }
    });
    return result;
  }

  List<Word> _words = [];
  late final ValueNotifier<List<Word>> wordsNotifier;

  @override
  void activate() {
    wordsNotifier = ValueNotifier<List<Word>>([]);
    super.activate();
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateWidget.of(context);
    _words = AppStateScope.of(context).words!;
    wordsNotifier.value = _words;

    /// todo: sheet shuld be draggable on dragging the  top edge of the sheet
    return ValueListenableBuilder<List<Word>>(
        valueListenable: wordsNotifier,
        builder: (BuildContext context, List<Word> value, Widget? child) {
          return Column(
            children: [
              SizedBox(height: 8),
              SearchBuilder(
                ontap: () => widget.onFocus!(),
                onChanged: (x) {
                  if (x.isEmpty) {
                    wordsNotifier.value = _words;
                    state.setWords(_words);
                    return;
                  }
                  List<Word> result = [];
                  _words.forEach((element) {
                    if (element.word.toLowerCase().contains(x.toLowerCase()) ||
                        element.meaning
                            .toLowerCase()
                            .contains(x.toLowerCase()) ||
                        isInSynonym(x, element.synonyms)) {
                      result.add(element);
                    }
                  });
                  wordsNotifier.value = result;
                },
              ),
              Expanded(
                  child: value.isEmpty
                      ? EmptyWord()
                      : ListView.builder(
                          itemCount: value.length,
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          controller: widget.controller,
                          itemBuilder: (context, index) {
                            return WordListTile(
                              word: value[index],
                              onSelect: (x) => widget.onSelected(value[index]),
                            );
                          })),
            ],
          );
        });
  }
}

class MyBackgroundWidget extends StatelessWidget {
  final int index;
  const MyBackgroundWidget({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 20; i++) Text('selected $index'),
      ],
    );
  }
}
