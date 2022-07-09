import 'package:flutter/material.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/navbar/navbar.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/utils.dart';

const appBarDesktopHeight = 128.0;

class AdaptiveLayout extends StatefulWidget {
  const AdaptiveLayout({Key? key}) : super(key: key);

  @override
  State<AdaptiveLayout> createState() => _AdaptiveLayoutState();
}

class _AdaptiveLayoutState extends State<AdaptiveLayout> {
  List<NavbarItem> items = [
    NavbarItem(Icons.dashboard, 'Home', backgroundColor: colors[0]),
    NavbarItem(Icons.search, 'Search', backgroundColor: colors[1]),
    NavbarItem(Icons.explore, 'Explore', backgroundColor: colors[2]),
    NavbarItem(Icons.notifications_active_sharp, 'Notifications',
        backgroundColor: colors[2]),
    NavbarItem(Icons.person, 'Me', backgroundColor: colors[2]),
  ];

  final Map<int, Map<String, Widget>> _routes = {
    0: {Dashboard.route: Dashboard()},
    1: {Search.route: Search(), AddWordForm.route: AddWordForm()},
    2: {ExploreWords.route: ExploreWords()},
    3: {Notifications.route: Notifications()},
    4: {UserProfile.route: UserProfile()}
  };
  @override
  void initState() {
    super.initState();
    getWords();
  }

  Future<void> getWords() async {
    final _store = SupaStore();
    final words = await _store.getAllWords();
    if (words.isNotEmpty) {
      AppStateWidget.of(context).setWords(words);
    }
  }

  // updateWord(List<Word> words) {
  //   words.forEach((word) {
  //     print('\nBEFORE ${word.word} ${word.synonyms}');
  //     print('\nAFTERr ${word.word.trim()} ${word.synonyms}');
  // if (word.synonyms != null) {
  //   word.synonyms!.forEach((syn) {
  //     synonyms.add(syn.trim().replaceAll('\n', ''));
  //   });
  //   final _updatedWord = word.copyWith(synonyms: synonyms);
  //   print(
  //       '\n AFTERsynonyms of ${_updatedWord.word} ${_updatedWord.synonyms}');
  //   // _store.updateWord(id: word.id, word: _updatedWord);
  // } else {
  //   final _updatedWord = word.copyWith(synonyms: synonyms);
  //   print(
  //       '\n AFTER null synonyms of ${_updatedWord.word} ${_updatedWord.synonyms}');
  //   // _store.updateWord(id: word.id, word: _updatedWord);
  // }
  // });
  // }

  Future<void> silentLogin() async {
    /// TODO UPDATE LOGIN STATE IN BACKEND AND LOCALLY
  }

  late AppState state;

  @override
  Widget build(BuildContext context) {
    SizeUtils.size = MediaQuery.of(context).size;
    return NavbarRouter(
      errorBuilder: (context) {
        return const Center(child: Text('Error 404'));
      },
      onBackButtonPressed: (isExiting) {
        return isExiting;
      },
      isDesktop: !SizeUtils.isMobile,
      destinationAnimationCurve: Curves.fastOutSlowIn,
      destinationAnimationDuration: 600,
      decoration: NavbarDecoration(
          backgroundColor: VocabTheme.navigationBarColor,
          isExtended: SizeUtils.isExtendedDesktop,
          navbarType: BottomNavigationBarType.fixed),
      destinations: [
        for (int i = 0; i < items.length; i++)
          DestinationRouter(
            navbarItem: items[i],
            destinations: [
              for (int j = 0; j < _routes[i]!.keys.length; j++)
                Destination(
                  route: _routes[i]!.keys.elementAt(j),
                  widget: _routes[i]!.values.elementAt(j),
                ),
            ],
            initialRoute: _routes[i]!.keys.elementAt(0),
          ),
      ],
    );
  }
}

class DesktopHome extends StatefulWidget {
  const DesktopHome({Key? key}) : super(key: key);

  @override
  State<DesktopHome> createState() => _DesktopHomeState();
}

class _DesktopHomeState extends State<DesktopHome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Container(
              color: Colors.red,
              child: Center(
                child: Text('Desktop Home'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
