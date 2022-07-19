import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/navbar/navbar.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/utils.dart';

const appBarDesktopHeight = 128.0;

class AdaptiveLayout extends StatefulWidget {
  const AdaptiveLayout({Key? key}) : super(key: key);

  @override
  State<AdaptiveLayout> createState() => _AdaptiveLayoutState();
}

class _AdaptiveLayoutState extends State<AdaptiveLayout> {
  @override
  void initState() {
    super.initState();
    getWords();
  }

  Future<void> getWords() async {
    final _store = VocabStoreService();
    final words = await _store.getAllWords();
    if (words.isNotEmpty) {
      AppStateWidget.of(context).setWords(words);
      // updateWord(words);
    }
  }

  updateWord(List<Word> words) {
    words.forEach((word) {
      print('\nBEFORE\n${word.meaning}');
      if (word.meaning.isNotEmpty) {
        // word.synonyms!.forEach((syn) {
        //   synonyms.add(syn.trim().replaceAll('\n', ''));
        // });
        final meaning = word.meaning.replaceAll('\n', '');
        final _updatedWord = word.copyWith(meaning: meaning);
        print(
            '\n AFTER meaning of ${_updatedWord.word}\n${_updatedWord.meaning}');
        // SupaStore().updateWord(id: word.id, word: _updatedWord);
      }
      // _store.updateWord(id: word.id, word: _updatedWord);
    });
  }

  Future<void> silentLogin() async {
    /// TODO UPDATE LOGIN STATE IN BACKEND AND LOCALLY
  }

  void showToast() {
    Fluttertoast.showToast(
        msg: "Press back button to exit",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        textColor: Colors.white,
        fontSize: 12.0);
  }

  void hideToast() {
    Fluttertoast.cancel();
  }

  late AppState state;

  bool animatePageOnce = false;
  DateTime oldTime = DateTime.now();
  DateTime newTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    SizeUtils.size = MediaQuery.of(context).size;
    List<NavbarItem> items = [
      NavbarItem(Icons.dashboard, 'Dashboard'),
      NavbarItem(Icons.search, 'Search'),
      NavbarItem(Icons.explore, 'Explore'),
      NavbarItem(Icons.person, 'Me'),
    ];

    final Map<int, Map<String, Widget>> _routes = {
      0: {
        Dashboard.route: Dashboard(),
        Notifications.route: Notifications(),
      },
      1: {Search.route: Search(), AddWordForm.route: AddWordForm()},
      2: {ExploreWords.route: ExploreWords()},
      3: {UserProfile.route: UserProfile()}
    };
    return Scaffold(
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: kBottomNavigationBarHeight * 0.7,
        ),
        child: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              Navigate.push(
                  context,
                  AddWordForm(
                    isEdit: false,
                  ),
                  slideTransitionType: TransitionType.scale);
            }),
      ),
      body: NavbarRouter(
        errorBuilder: (context) {
          return const Center(child: Text('Error 404'));
        },
        onBackButtonPressed: (isExiting) {
          if (isExiting) {
            newTime = DateTime.now();
            int difference = newTime.difference(oldTime).inMilliseconds;
            oldTime = newTime;
            if (difference < 1000) {
              hideToast();
              return isExiting;
            } else {
              showToast();
              return false;
            }
          } else {
            return isExiting;
          }
        },
        isDesktop: !SizeUtils.isMobile,
        destinationAnimationCurve: Curves.fastOutSlowIn,
        destinationAnimationDuration: 600,
        onChanged: (x) {
          /// Simulate DragGesture on pageView
          if (EXPLORE_INDEX == x && !animatePageOnce) {
            print('index change = ${pageController.hasClients}');
            if (pageController.hasClients) {
              Future.delayed(Duration(seconds: 3), () {
                if (NavbarNotifier.currentIndex == EXPLORE_INDEX) {
                  pageController.animateTo(200,
                      duration: Duration(milliseconds: 600),
                      curve: Curves.easeIn);
                  animatePageOnce = true;
                }
              });
            }
          }
        },
        decoration: NavbarDecoration(
            backgroundColor: VocabTheme.navigationBarColor,
            isExtended: SizeUtils.isExtendedDesktop,
            // showUnselectedLabels: false,
            selectedLabelTextStyle: TextStyle(fontSize: 12),
            unselectedLabelTextStyle: TextStyle(fontSize: 10),
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
      ),
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
