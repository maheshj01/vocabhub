import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/models.dart';
import 'package:vocabhub/navbar/dashboard/bookmarks.dart';
import 'package:vocabhub/navbar/error_page.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/search.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/word_list_tile.dart';
import 'package:vocabhub/widgets/worddetail.dart';

class Search extends ConsumerStatefulWidget {
  static String route = '/';
  const Search({Key? key}) : super(key: key);

  @override
  ConsumerState<Search> createState() => _SearchState();
}

class _SearchState extends ConsumerState<Search> {
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
    final words = dashboardController.words;
    return ResponsiveBuilder(desktopBuilder: (context) {
      return SafeArea(
        child: Row(
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
        ),
      );
    }, mobileBuilder: (BuildContext context) {
      return MobileView();
    });
  }
}

class MobileView extends ConsumerStatefulWidget {
  const MobileView({super.key});

  @override
  ConsumerState<MobileView> createState() => _MobileViewState();
}

class _MobileViewState extends ConsumerState<MobileView> {
  Future<void> getWordsByAlphabet() async {
    response.value = response.value.copyWith(state: RequestState.active);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        words = await VocabStoreService.getAllWords(sort: true);
        List<List<Word>> wordsByAlphabet = [];
        words.forEach((element) {
          final index = element.word[0].toUpperCase().codeUnitAt(0) - 65;
          if (wordsByAlphabet.length <= index) {
            wordsByAlphabet.add([element]);
          } else {
            wordsByAlphabet[index].add(element);
          }
        });
        if (NavbarNotifier.currentIndex == SEARCH_INDEX) {
          showToast('${words.length} Words fetched successfully');
        }
        response.value = response.value.copyWith(
            data: wordsByAlphabet,
            state: RequestState.done,
            status: 200,
            message: 'Words by Alphabet fetched successfully');
      } catch (_) {
        NavbarNotifier.showSnackBar(context, NETWORK_ERROR, bottom: kNavbarHeight);
        if (_.runtimeType == TimeoutException) {
          response.value =
              response.value.copyWith(state: RequestState.error, message: NETWORK_ERROR);
        } else {
          response.value =
              response.value.copyWith(state: RequestState.error, message: _.toString());
        }
      }
    });
  }

  List<Word> words = [];
  final ScrollController _scrollController = ScrollController();
  late ScrollDirection _lastScrollDirection;
  late double _lastScrollOffset;
  final double _offsetThreshold = 50.0;

  @override
  void initState() {
    super.initState();
    getWordsByAlphabet();
    _lastScrollDirection = ScrollDirection.idle;
    _lastScrollOffset = 0;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _scrollController.addListener(() {
        if (_scrollController.position.userScrollDirection != _lastScrollDirection) {
          _lastScrollDirection = _scrollController.position.userScrollDirection;
          _lastScrollOffset = _scrollController.offset;
        }
        double difference = (_scrollController.offset - _lastScrollOffset).abs();
        if (difference > _offsetThreshold) {
          _lastScrollOffset = _scrollController.offset;
          _toggleFab();
        }
      });
    });
  }

  void _toggleFab() {
    final appController = ref.watch(appNotifier);
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      ref.watch(appNotifier.notifier).state = appController.copyWith(extended: true);
    } else {
      ref.watch(appNotifier.notifier).state = appController.copyWith(extended: false);
    }
  }

  ValueNotifier<Response> response = ValueNotifier<Response>(Response.init());

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: 16.0.horizontalPadding + 8.0.topPadding,
            child: SearchBuilder(
              ontap: () {
                final size = MediaQuery.of(context).size;
                searchController.clearText();
                Navigate.push(context, SearchView(),
                    offset: Offset(size.width / 2, 100),
                    transitionDuration: Duration(milliseconds: 500),
                    transitionType: TransitionType.reveal,
                    isRootNavigator: true);
              },
              readOnly: true,
              onChanged: (x) {},
            ),
          ),
          Padding(
            padding: 8.0.allPadding,
            child: heading('Words By Alphabets', fontSize: 16),
          ),
          Expanded(
              child: RefreshIndicator(
            onRefresh: () async {
              await getWordsByAlphabet();
            },
            child: ValueListenableBuilder<Response>(
                valueListenable: response,
                builder: (context, Response resp, child) {
                  if (resp.state == RequestState.active) {
                    return LoadingWidget();
                  }
                  if (resp.state == RequestState.error) {
                    return Container(
                      padding: 16.0.allPadding,
                      child: ErrorPage(
                        onRetry: () async {
                          getWordsByAlphabet();
                        },
                        errorMessage: resp.message,
                      ),
                    );
                  }
                  final List<List<Word>> wordsByAlphabet = resp.data as List<List<Word>>;
                  return Padding(
                    padding: 8.0.horizontalPadding,
                    child: GridView.custom(
                      controller: _scrollController,
                      padding: 80.0.bottomPadding,
                      gridDelegate: SliverQuiltedGridDelegate(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        repeatPattern: QuiltedGridRepeatPattern.inverted,
                        pattern: [
                          QuiltedGridTile(1, 2),
                          QuiltedGridTile(2, 2),
                          QuiltedGridTile(1, 1),
                          QuiltedGridTile(1, 1),
                        ],
                      ),
                      childrenDelegate: SliverChildBuilderDelegate(
                        childCount: wordsByAlphabet.length,
                        (context, index) => WordTile(
                          title: wordsByAlphabet[index][0].word[0].toUpperCase(),
                          index: index,
                          wordList: wordsByAlphabet[index],
                        ),
                      ),
                    ),
                  );
                }),
          ))
        ],
      ),
    );
  }
}

class WordTile extends StatelessWidget {
  final int index;
  final String title;
  final List<Word>? wordList;

  const WordTile({super.key, required this.title, required this.index, this.wordList});

  @override
  Widget build(BuildContext context) {
    final randomColor = Colors.primaries[index % Colors.primaries.length].withOpacity(0.8);
    final randomDarkColor =
        Colors.primaries[index % Colors.primaries.length].shade900.withOpacity(0.8);
    return GestureDetector(
        onTap: () {
          Navigate.push(
              context,
              WordListPage(
                  title: "Words With Letter $title (${wordList!.length})",
                  hasTrailing: false,
                  words: wordList!));
        },
        child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: settingsController.isDark ? randomDarkColor : randomColor,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Text(
              '$title',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white),
            )));
  }
}

class SearchView extends StatefulWidget {
  static String route = '/searchview';

  const SearchView({super.key});

  @override
  State<SearchView> createState() => _SearchViewState();
}

class _SearchViewState extends State<SearchView> {
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(
      desktopBuilder: (context) => SearchViewPage(),
      mobileBuilder: (context) => SearchViewPage(),
    );
  }
}

class SearchViewPage extends StatefulWidget {
  const SearchViewPage({Key? key}) : super(key: key);

  @override
  State<SearchViewPage> createState() => _SearchViewPageState();
}

class _SearchViewPageState extends State<SearchViewPage> {
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
    words = dashboardController.words;
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
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
                                  return Container(
                                      margin: 2.0.verticalPadding + 16.0.horizontalPadding,
                                      decoration: BoxDecoration(

                                          // blur the background
                                          color: colorScheme.secondaryContainer.withOpacity(0.2),
                                          boxShadow: [
                                            BoxShadow(
                                                color:
                                                    colorScheme.secondaryContainer.withOpacity(0.2),
                                                blurRadius: 8.0,
                                                offset: Offset(0, 2))
                                          ]),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: colorScheme.secondaryContainer, width: 1.0),
                                            borderRadius: BorderRadius.circular(8.0)),
                                        title: Text('${results[index].word}'),
                                        onTap: () {
                                          Navigate.push(
                                              context,
                                              WordDetail(
                                                word: results[index],
                                              ),
                                              isRootNavigator: true);
                                        },
                                        trailing: GestureDetector(
                                            onTap: () async {
                                              searchController.removeRecent(results[index]);
                                              showRecents();
                                            },
                                            child: Icon(Icons.close, size: 16)),
                                      ));
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
                                  return Container(
                                      margin: 8.0.horizontalPadding + 4.0.verticalPadding,
                                      decoration: BoxDecoration(
                                          color: colorScheme.secondaryContainer.withOpacity(0.2),
                                          boxShadow: [
                                            BoxShadow(
                                                color:
                                                    colorScheme.secondaryContainer.withOpacity(0.2),
                                                blurRadius: 8.0,
                                                offset: Offset(0, 2))
                                          ]),
                                      child: ListTile(
                                        shape: RoundedRectangleBorder(
                                            side: BorderSide(
                                                color: colorScheme.secondaryContainer, width: 1.0),
                                            borderRadius: BorderRadius.circular(8.0)),
                                        minVerticalPadding: 24,
                                        tileColor: Colors.transparent,
                                        title: Text('${results[index].word}'),
                                        onTap: () {
                                          searchController.addRecent(results[index]);
                                          Navigate.push(
                                              context,
                                              WordDetail(
                                                word: results[index],
                                              ),
                                              isRootNavigator: true);
                                        },
                                        subtitle: Text(
                                          '${results[index].meaning}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                      ));
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
      _words = dashboardController.words;
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
                      padding: 16.0.horizontalPadding,
                      child: SearchBuilder(
                        controller: searchController.controller,
                        ontap: () {
                          if (widget.onFocus != null) {
                            widget.onFocus!();
                          }
                        },
                        onChanged: (x) {
                          _words = dashboardController.words;
                          if (x.isEmpty) {
                            wordsNotifier.value = _words;
                            return;
                          }
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
