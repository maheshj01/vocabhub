import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/widgets/button.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/search.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/worddetail.dart';

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

class SearchViewPage extends ConsumerStatefulWidget {
  const SearchViewPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SearchViewPageState();
}

class _SearchViewPageState extends ConsumerState<SearchViewPage> {
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

  String oldQuery = '';

  @override
  Widget build(BuildContext context) {
    // final dashboardState = ref.read(dashboardUtilityProvider.notifier);
    // final words = dashboardState.stateValue.words;

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
                                padding: (kNavbarHeight * 1.2).bottomPadding,
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
