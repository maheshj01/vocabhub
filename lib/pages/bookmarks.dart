import 'package:flutter/material.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/widgets.dart';

class BookmarksPage extends StatefulWidget {
  final bool isBookMark;
  final UserModel user;

  const BookmarksPage({Key? key, required this.isBookMark, required this.user})
      : super(key: key);

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  @override
  Widget build(BuildContext context) {
    return Material(
        child: ResponsiveBuilder(
      desktopBuilder: (context) => _BookmarksDesktop(),
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

  const _BookmarksMobile({Key? key, this.isBookMark = true, required this.user})
      : super(key: key);

  @override
  State<_BookmarksMobile> createState() => _BookmarksMobileState();
}

class _BookmarksMobileState extends State<_BookmarksMobile> {
  Future<void> getBookmarks() async {
    final words = await VocabStoreService.getBookmarks(widget.user.email,
        isBookmark: widget.isBookMark);
    _bookmarksNotifier.value = words;
  }

  @override
  void initState() {
    super.initState();
    getBookmarks();
  }

  ValueNotifier<List<Word>?> _bookmarksNotifier =
      ValueNotifier<List<Word>?>(null);

  @override
  Widget build(BuildContext context) {
    String title = widget.isBookMark ? 'Bookmarks' : 'Mastered words';
    return Scaffold(
        appBar: AppBar(
          title: Text('$title'),
        ),
        body: ValueListenableBuilder(
          valueListenable: _bookmarksNotifier,
          builder: (_, List<Word>? value, Widget? child) {
            if (value == null) {
              return LoadingWidget();
            }
            if (value.isEmpty) {
              return Center(
                child: Text('No ${title.toLowerCase()} to show'),
              );
            }
            return ListView.builder(
              itemCount: value.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(value[index].word),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.bookmark,
                      color: VocabTheme.primaryColor,
                    ),
                    onPressed: () async {
                      await VocabStoreService.removeBookmark(value[index].id,
                          isBookmark: widget.isBookMark);
                      getBookmarks();
                      showMessage(context, '$title removed');
                    },
                  ),
                );
              },
            );
          },
        ));
  }
}

class _BookmarksDesktop extends StatefulWidget {
  const _BookmarksDesktop({Key? key}) : super(key: key);

  @override
  State<_BookmarksDesktop> createState() => _BookmarksDesktopState();
}

class _BookmarksDesktopState extends State<_BookmarksDesktop> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red,
      ),
    );
  }
}
