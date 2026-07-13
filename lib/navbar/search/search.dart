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
import 'package:vocabhub/navbar/search/search_view.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/utils/utils.dart';
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
        final difference = (_scrollController.offset - _lastScrollOffset).abs();
        if (difference > _offsetThreshold) {
          _lastScrollOffset = _scrollController.offset;
          _toggleFab();
        }
      });
    });
  }

  void _toggleFab() {
    if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
      ref.read(appProvider.notifier).setExtended(true);
    } else {
      ref.read(appProvider.notifier).setExtended(false);
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
                    padding: 8.0.horizontalPadding + (kNavbarHeight * 1.2).bottomPadding,
                    child: GridView.custom(
                      controller: _scrollController,
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

class WordTile extends ConsumerWidget {
  final int index;
  final String title;
  final List<Word>? wordList;

  const WordTile({super.key, required this.title, required this.index, this.wordList});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
              color: ref.read(appThemeProvider).isDark ? randomDarkColor : randomColor,
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: Text(
              '$title',
              style: Theme.of(context).textTheme.headlineLarge!.copyWith(color: Colors.white),
            )));
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
  static const int _pageSize = 20;
  final List<Word> _results = [];
  final ValueNotifier<List<Word>> wordsNotifier = ValueNotifier<List<Word>>([]);
  String _query = '';
  int _offset = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    widget.controller ??= ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load(reset: true));
  }

  @override
  void dispose() {
    _debounce?.cancel();
    wordsNotifier.dispose();
    super.dispose();
  }

  /// Loads a page for the current mode: browse (empty query) or search — both
  /// fetched and paged from the database.
  Future<void> _load({bool reset = false}) async {
    if (_isLoading) return;
    if (reset) {
      _offset = 0;
      _hasMore = true;
      _results.clear();
    }
    if (!_hasMore) return;
    _isLoading = true;
    final page = _query.isEmpty
        ? await VocabStoreService.getWordsPage(limit: _pageSize, offset: _offset)
        : await VocabStoreService.searchWord(_query, limit: _pageSize, offset: _offset);
    _isLoading = false;
    if (!mounted) return;
    _results.addAll(page);
    _offset += page.length;
    _hasMore = page.length == _pageSize;
    wordsNotifier.value = List<Word>.of(_results);
  }

  void _onQueryChanged(String value) {
    _query = value.trim();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () => _load(reset: true));
  }

  bool _onScrollNotification(ScrollNotification notification) {
    final metrics = notification.metrics;
    if (_hasMore && !_isLoading && metrics.pixels >= metrics.maxScrollExtent - 320) {
      _load();
    }
    return false;
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
                        ontap: () => widget.onFocus?.call(),
                        onChanged: _onQueryChanged,
                      ),
                    ),
                  ),
                  widget.isExpanded == null
                      ? SizedBox.shrink()
                      : IconButton(
                          onPressed: () => widget.onExpanded?.call(),
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
                    ? (_isLoading ? const Center(child: CircularProgressIndicator()) : EmptyWord())
                    : NotificationListener<ScrollNotification>(
                        onNotification: _onScrollNotification,
                        child: ListView.builder(
                          itemCount: value.length + (_hasMore ? 1 : 0),
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          controller: widget.controller,
                          itemBuilder: (context, index) {
                            if (index >= value.length) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 20),
                                child: Center(child: CircularProgressIndicator()),
                              );
                            }
                            return WordListTile(
                              word: value[index],
                              onSelect: (x) => widget.onSelected(value[index]),
                            );
                          },
                        ),
                      ),
              ),
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
