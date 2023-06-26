import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/button.dart';
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
  Word? selectedWord;
  int selectedIndex = 0;
  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    analytics.logRouteView('${Search.route}search');
    super.initState();
  }

  final analytics = Analytics.instance;
  @override
  Widget build(BuildContext context) {
    final words = AppStateScope.of(context).words;
    return ResponsiveBuilder(desktopBuilder: (context) {
      if (words == null) {
        return LoadingWidget();
      }
      return Row(
        children: [
          Flexible(
            child: WordList(
              controller: ScrollController(),
              onSelected: (word) {
                setState(() {
                  selectedWord = word;
                  selectedIndex = words.indexOf(word);
                });
              },
            ),
          ),
          Expanded(flex: 2, child: WordDetail(word: selectedWord ?? words.first)),
        ],
      );
    }, mobileBuilder: (BuildContext context) {
      if (words == null) {
        return LoadingWidget();
      }
      return MobileView();
    });
  }
}

class MobileView extends StatefulWidget {
  const MobileView({super.key});

  @override
  State<MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends State<MobileView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: SearchBuilder(
              ontap: () {
                searchController.clearText();
                Navigate.push(context, SearchView(),
                    transitionType: TransitionType.fade, isRootNavigator: true);
              },
              readOnly: true,
              onChanged: (x) {},
            ),
          ),
          Expanded(
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('Hang Tight!\nPopular words\nComing soon!' + '🚀')],
            ),
          ))
        ],
      ),
    );
  }
}

class TOP10WordsCard extends StatefulWidget {
  const TOP10WordsCard({super.key});

  @override
  State<TOP10WordsCard> createState() => _TOP10WordsCardState();
}

class _TOP10WordsCardState extends State<TOP10WordsCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          ListTile(
            title: Text('Top 10 Words'),
            trailing: IconButton(
              icon: Icon(Icons.add),
              onPressed: () {},
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Word $index'),
                  subtitle: Text('Meaning $index'),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}

class SearchView extends StatefulWidget {
  static String route = '/searchview';

  const SearchView({Key? key}) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  final searchNotifier = ValueNotifier<List<Word>?>(null);

  @override
  void initState() {
    super.initState();
    showRecents();
  }

  @override
  void dispose() {
    searchNotifier.dispose();
    super.dispose();
  }

  Future<void> showRecents() async {
    final _recents = await searchController.recents();
    searchNotifier.value = _recents;
  }

  Future<void> search(String query) async {
    searchNotifier.value = null;
    if (query.isEmpty) {
      await showRecents();
      return;
    }

    /// show loading when query changes
    if (oldQuery != query) {
      oldQuery = query;
    }
    final results = await VocabStoreService.searchWord(query);
    if (mounted) {
      searchNotifier.value = results;
    }
  }

  List<Word> words = [];
  String oldQuery = '';

  @override
  Widget build(BuildContext context) {
    words = AppStateScope.of(context).words!;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      child: SafeArea(
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BackButton(),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.only(right: 16.0, top: 8.0),
                    child: SearchBuilder(
                        ontap: () {},
                        autoFocus: true,
                        onChanged: (query) {
                          searchController.controller.text = query;
                          search(query);
                        }),
                  ),
                ),
              ],
            ),
            Expanded(
                child: ValueListenableBuilder<List<Word>?>(
                    valueListenable: searchNotifier,
                    builder: (BuildContext context, List<Word>? results, Widget? child) {
                      if (results == null) {
                        return LoadingWidget();
                      } else if (searchController.searchText.isEmpty) {
                        // show Recent Suggestions
                        return Column(
                          children: [
                            SizedBox(
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Recent'),
                                  )),
                            ),
                            if (results.isEmpty)
                              Expanded(
                                child: Center(
                                  child: Text('No recent searches'),
                                ),
                              )
                            else
                              Expanded(
                                  child: ListView.builder(
                                padding: kBottomNavigationBarHeight.bottomPadding,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding: 1.0.verticalPadding,
                                    child: OpenContainer(
                                        openBuilder:
                                            (BuildContext context, VoidCallback openContainer) {
                                          searchController.addRecent(results[index]);
                                          return WordDetail(
                                            word: results[index],
                                          );
                                        },
                                        closedColor: colorScheme.secondaryContainer,
                                        closedElevation: 0,
                                        tappable: true,
                                        transitionType: ContainerTransitionType.fadeThrough,
                                        closedBuilder:
                                            (BuildContext context, VoidCallback openContainer) {
                                          return ListTile(
                                            title: Text('${results[index].word}'),
                                            trailing: GestureDetector(
                                                onTap: () async {
                                                  searchController.removeRecent(results[index]);
                                                  showRecents();
                                                },
                                                child: Icon(Icons.close, size: 16)),
                                          );
                                        }),
                                  );
                                },
                                itemCount: results.length,
                              ))
                          ],
                        );
                      } else {
                        /// search results are empty
                        if (results.isEmpty) {
                          final searchTerm = searchController.searchText;
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('"$searchTerm" not found'),
                                100.0.vSpacer(),
                                VHButton(
                                    width: 200,
                                    onTap: () {
                                      Navigate.push(
                                          context,
                                          AddWordForm(
                                            isEdit: false,
                                          ),
                                          isRootNavigator: true);
                                    },
                                    label: "Add new Word?")
                              ],
                            ),
                          );
                        }

                        /// search results found
                        return Column(
                          children: [
                            SizedBox(
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text('Search Results: ${results.length}'),
                                  )),
                            ),
                            Expanded(
                              child: ListView.builder(
                                padding: kBottomNavigationBarHeight.bottomPadding,
                                itemBuilder: (context, index) {
                                  return Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8, vertical: 1.0),
                                    child: OpenContainer(
                                        closedColor: colorScheme.secondaryContainer,
                                        openBuilder:
                                            (BuildContext context, VoidCallback openContainer) {
                                          searchController.addRecent(results[index]);
                                          return WordDetail(
                                            word: results[index],
                                          );
                                        },
                                        closedElevation: 0,
                                        tappable: true,
                                        transitionType: ContainerTransitionType.fadeThrough,
                                        closedBuilder:
                                            (BuildContext context, VoidCallback openContainer) {
                                          return ListTile(
                                            minVerticalPadding: 24,
                                            title: Text('${results[index].word}'),
                                          );
                                        }),
                                  );
                                },
                                itemCount: results.length,
                              ),
                            ),
                          ],
                        );
                      }
                    }))
          ],
        ),
      ),
    );
  }
}

class WordList extends StatefulWidget {
  final Function(Word) onSelected;
  ScrollController? controller;
  final Function? onFocus;
  final bool? isExpanded;
  final Function? onExpanded;

  WordList(
      {Key? key,
      required this.onSelected,
      this.controller,
      this.onFocus,
      this.onExpanded,
      this.isExpanded})
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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _words = AppStateScope.of(context).words!;
      wordsNotifier.value = _words;
    });
  }

  bool isInSynonym(String query, List<String>? synonyms) {
    bool result = false;
    if (synonyms == null || synonyms.isEmpty) {
      return result;
    }
    for (var element in synonyms) {
      if (element.toLowerCase() == query.toLowerCase()) {
        result = true;
      }
    }
    return result;
  }

  List<Word> _words = [];
  late final ValueNotifier<List<Word>> wordsNotifier;

  @override
  void activate() {
    wordsNotifier = ValueNotifier<List<Word>>([]);
    super.activate();
  }

  Future<void> search(String query) async {
    final results = await VocabStoreService.searchWord(query);
    if (mounted) {
      wordsNotifier.value = results;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppStateWidget.of(context);
    return ValueListenableBuilder<List<Word>>(
        valueListenable: wordsNotifier,
        builder: (BuildContext context, List<Word> value, Widget? child) {
          return Column(
            children: [
              8.0.vSpacer(),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: kIsWeb ? 16.0 : 0.0),
                      child: SearchBuilder(
                        controller: searchController.controller,
                        ontap: () {
                          if (widget.onFocus != null) {
                            widget.onFocus!();
                          }
                        },
                        onChanged: (x) {
                          // /// Searching on the Web
                          _words = AppStateScope.of(context).words!;
                          // wordsNotifier.value = _words;
                          if (x.isEmpty) {
                            wordsNotifier.value = _words;
                            state.setWords(_words);
                            return;
                          }
                          // final List<Word> result = [];
                          // for (var element in _words) {
                          //   if (element.word.toLowerCase().contains(x.toLowerCase()) ||
                          //       element.meaning.toLowerCase().contains(x.toLowerCase()) ||
                          //       isInSynonym(x, element.synonyms)) {
                          //     result.add(element);
                          //   }
                          // }
                          // wordsNotifier.value = result;
                          search(x);
                        },
                      ),
                    ),
                  ),
                  widget.isExpanded == null
                      ? SizedBox.shrink()
                      : IconButton(
                          onPressed: () {
                            if (widget.onExpanded != null) {
                              widget.onExpanded!();
                            }
                          },
                          icon: Icon(
                            widget.isExpanded == true
                                ? Icons.keyboard_arrow_down
                                : Icons.keyboard_arrow_up,
                            size: 30,
                          ))
                ],
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
