import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';
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
    // Guests are tracked on-device: resolve their words from the loaded list.
    if (widget.user.email.isEmpty) {
      final want = widget.isBookMark ? WordState.unknown : WordState.known;
      final ids = wordTrackingController.states.entries
          .where((e) => e.value == want)
          .map((e) => e.key)
          .toSet();
      _bookmarksNotifier.value =
          dashboardController.words.where((w) => ids.contains(w.id)).toList();
      return;
    }
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
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.builder(
          itemCount: words.length,
          padding: EdgeInsets.only(top: 12, bottom: kNotchedNavbarHeight * 1.5),
          itemBuilder: (context, index) {
            final word = words[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: OpenContainer(
                closedColor: colorScheme.surfaceContainerHighest,
                closedElevation: 0,
                openColor: colorScheme.surface,
                openElevation: 0,
                closedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                openBuilder: (context, _) => WordDetail(word: word),
                middleColor: Colors.transparent,
                tappable: true,
                transitionType: ContainerTransitionType.fadeThrough,
                closedBuilder: (context, openContainer) => Padding(
                  padding: EdgeInsets.fromLTRB(16, 14, hasTrailing! ? 8 : 16, 14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              word.word,
                              style: GoogleFonts.quicksand(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                              ),
                            ),
                            if (word.meaning.trim().isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                word.meaning,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.quicksand(
                                  fontSize: 13,
                                  height: 1.3,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (hasTrailing!)
                        IconButton(
                          icon: Icon(iconData, color: colorScheme.primary),
                          onPressed: onTrailingTap != null ? () => onTrailingTap!(word) : null,
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
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
                  title: widget.title,
                  hasTrailing: widget.hasTrailing,
                  words: widget.words,
                  onTrailingTap: widget.onTrailingTap);
            },
            mobileBuilder: (context) => WordListPageMobile(
                title: widget.title,
                hasTrailing: widget.hasTrailing,
                words: widget.words,
                onTrailingTap: widget.onTrailingTap)));
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
    final colorScheme = Theme.of(context).colorScheme;
    final body = Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.builder(
          itemCount: words.length,
          padding: EdgeInsets.only(top: 12, bottom: kNotchedNavbarHeight * 1.5),
          itemBuilder: (context, index) {
            final word = words[index];
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => Navigator.push(
                      context, MaterialPageRoute(builder: (context) => WordDetail(word: word))),
                  borderRadius: BorderRadius.circular(20),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(16, 14, hasTrailing! ? 8 : 16, 14),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  word.word,
                                  style: GoogleFonts.quicksand(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                if (word.meaning.trim().isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    word.meaning,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.quicksand(
                                      fontSize: 13,
                                      height: 1.3,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          if (hasTrailing!)
                            IconButton(
                              icon: Icon(Icons.bookmark_rounded, color: colorScheme.primary),
                              onPressed: onTrailingTap != null ? () => onTrailingTap!(word) : null,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text('$title', style: GoogleFonts.quicksand(fontWeight: FontWeight.w700)),
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
    // Guests are tracked on-device: resolve their words from the loaded list.
    if (widget.user.email.isEmpty) {
      final want = widget.isBookMark ? WordState.unknown : WordState.known;
      final ids = wordTrackingController.states.entries
          .where((e) => e.value == want)
          .map((e) => e.key)
          .toSet();
      _bookmarksNotifier.value =
          dashboardController.words.where((w) => ids.contains(w.id)).toList();
      return;
    }
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
