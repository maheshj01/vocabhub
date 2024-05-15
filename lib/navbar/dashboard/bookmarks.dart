import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/worddetail.dart';

class BookmarksPage extends StatefulWidget {
  final bool isBookMark;
  final UserModel user;

  const BookmarksPage({Key? key, required this.isBookMark, required this.user}) : super(key: key);

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: ResponsiveBuilder(
          desktopBuilder: (context) => _BookmarksDesktop(
            isBookMark: widget.isBookMark,
            user: widget.user,
          ),
          mobileBuilder: (context) => _BookmarksMobile(
            isBookMark: widget.isBookMark,
            user: widget.user,
          ),
        ));
  }
}

class _BookmarksMobile extends StatefulWidget {
  final bool isBookMark;
  final UserModel user;

  const _BookmarksMobile({Key? key, this.isBookMark = true, required this.user}) : super(key: key);

  @override
  State<_BookmarksMobile> createState() => _BookmarksMobileState();
}

class _BookmarksMobileState extends State<_BookmarksMobile> {
  Future<void> getBookmarks() async {
    final words =
        await VocabStoreService.getBookmarks(widget.user.email, isBookmark: widget.isBookMark);
    _bookmarksNotifier.value = words;
  }

  @override
  void initState() {
    super.initState();
    getBookmarks();
  }

  ValueNotifier<List<Word>?> _bookmarksNotifier = ValueNotifier<List<Word>?>(null);

  @override
  Widget build(BuildContext context) {
    final String title = widget.isBookMark ? 'Bookmarks' : 'Mastered words';

    Widget _emptyWidget() {
      return Center(
        child: Text('No ${title.toLowerCase()} to show'),
      );
    }

    return ValueListenableBuilder(
        valueListenable: _bookmarksNotifier,
        builder: (_, List<Word>? value, Widget? child) {
          if (value == null) {
            return Scaffold(
                backgroundColor: Colors.transparent,
                appBar: AppBar(backgroundColor: Colors.transparent, title: Text('$title')),
                body: LoadingWidget());
          }
          return Scaffold(
              backgroundColor: Colors.transparent,
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                title: value.isEmpty ? Text('$title') : Text('${value.length} $title'),
              ),
              body: value.isEmpty
                  ? _emptyWidget()
                  : WordListBuilder(
                      words: value,
                      onTrailingTap: (word) async {
                        await VocabStoreService.removeBookmark(word.id,
                            isBookmark: widget.isBookMark);
                        getBookmarks();
                        NavbarNotifier.showSnackBar(context, '$title removed', bottom: 0);
                      },
                    ));
        });
  }
}

class WordListBuilder extends ConsumerWidget {
  final List<Word> words;
  final Function(Word)? onTrailingTap;
  final bool? hasTrailing;
  final IconData? iconData;
  WordListBuilder(
      {Key? key,
      required this.words,
      this.hasTrailing = true,
      this.onTrailingTap,
      this.iconData = Icons.bookmark})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      itemCount: words.length,
      padding: EdgeInsets.only(top: 16, bottom: kNotchedNavbarHeight * 1.5),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
          child: OpenContainer(
              closedColor: Colors.transparent,
              closedElevation: 0,
              openColor: Colors.transparent,
              openElevation: 0,
              openShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest, width: 1)),
              closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest, width: 1)),
              openBuilder: (BuildContext context, VoidCallback openContainer) {
                return WordDetail(word: words[index]);
              },
              middleColor: Colors.transparent,
              tappable: true,
              transitionType: ContainerTransitionType.fadeThrough,
              closedBuilder: (BuildContext context, VoidCallback openContainer) {
                return ListTile(
                  minVerticalPadding: 24,
                  title: Text(words[index].word),
                  trailing: hasTrailing!
                      ? IconButton(
                          icon: Icon(
                            iconData,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          onPressed:
                              onTrailingTap != null ? () => onTrailingTap!(words[index]) : null,
                        )
                      : null,
                );
              }),
        );
      },
    );
  }
}

class WordListPage extends StatefulWidget {
  final String title;
  final List<Word> words;
  final Function(Word)? onTrailingTap;
  final bool? hasTrailing;
  WordListPage(
      {Key? key,
      required this.title,
      required this.words,
      this.hasTrailing = true,
      this.onTrailingTap})
      : super(key: key);

  @override
  State<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: ResponsiveBuilder(
            desktopBuilder: (context) {
              return WordListPageMobile(
                  title: widget.title, hasTrailing: widget.hasTrailing, words: widget.words);
            },
            mobileBuilder: (context) => WordListPageMobile(
                title: widget.title, hasTrailing: widget.hasTrailing, words: widget.words)));
  }
}

class WordListPageMobile extends StatelessWidget {
  final String title;
  final List<Word> words;
  final Function(Word)? onTrailingTap;
  final bool? hasTrailing;
  WordListPageMobile(
      {Key? key,
      required this.title,
      required this.words,
      this.hasTrailing = true,
      this.onTrailingTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final body = ListView.builder(
            itemCount: words.length,
            padding: EdgeInsets.only(top: 16, bottom: kNotchedNavbarHeight * 1.5),
            itemBuilder: (context, index) {
              return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4.0),
                  child: ListTile(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => WordDetail(word: words[index])));
                    },
                    minVerticalPadding: 24,
                    title: Text(words[index].word),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                      color: Theme.of(context).colorScheme.surfaceContainerHighest, width: 1)),
                    trailing: hasTrailing!
                        ? IconButton(
                            icon: Icon(
                              Icons.bookmark,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            onPressed:
                                onTrailingTap != null ? () => onTrailingTap!(words[index]) : null,
                          )
                        : null,
                  ));
            },
    );

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 15,
          title: Text('$title'),
          ),
        body: body);
  }
}

class _BookmarksDesktop extends StatefulWidget {
  final bool isBookMark;
  final UserModel user;
  const _BookmarksDesktop({Key? key, required this.isBookMark, required this.user})
      : super(key: key);

  @override
  State<_BookmarksDesktop> createState() => _BookmarksDesktopState();
}

class _BookmarksDesktopState extends State<_BookmarksDesktop> {
  Future<void> getBookmarks() async {
    final words =
        await VocabStoreService.getBookmarks(widget.user.email, isBookmark: widget.isBookMark);
    _bookmarksNotifier.value = words;
  }

  @override
  void initState() {
    super.initState();
    getBookmarks();
  }

  ValueNotifier<List<Word>?> _bookmarksNotifier = ValueNotifier<List<Word>?>(null);

  @override
  Widget build(BuildContext context) {
    final String title = widget.isBookMark ? 'Bookmarks' : 'Mastered words';

    Widget _emptyWidget() {
      return Center(
        child: Text('No ${title.toLowerCase()} to show'),
      );
    }

    return ValueListenableBuilder(
        valueListenable: _bookmarksNotifier,
        builder: (_, List<Word>? value, Widget? child) {
          if (value == null) {
            return Scaffold(
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                appBar: AppBar(title: Text('$title')),
                body: LoadingWidget());
          }
          return Material(
              child: value.isEmpty
                  ? _emptyWidget()
                  : WordListBuilder(
                      words: value,
                      onTrailingTap: (word) async {
                        await VocabStoreService.removeBookmark(word.id,
                            isBookmark: widget.isBookMark);
                        getBookmarks();
                        NavbarNotifier.showSnackBar(context, '$title removed', bottom: 0);
                      },
                    ));
        });
  }
}
