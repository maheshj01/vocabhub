import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/pages/login.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/circle_clipper.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/settings.dart';
import 'package:vocabhub/utils/size_utils.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/circle_avatar.dart';
import 'package:vocabhub/widgets/drawer.dart';
import 'package:vocabhub/widgets/search.dart';
import 'package:vocabhub/widgets/widgets.dart';
import 'package:vocabhub/widgets/worddetail.dart';
import 'package:vocabhub/widgets/word_list_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

TextEditingController searchController = TextEditingController();

class MyHomePage extends StatefulWidget {
  final bool isSignedIn;
  MyHomePage({Key? key, required this.title, this.isSignedIn = false})
      : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  String query = '';
  Word? selected;

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    firebaseAnalytics = Analytics();
    logger.d(SizeUtils.size);
    _animationController = AnimationController(
        vsync: this,
        duration: Duration(milliseconds: (!SizeUtils.isMobile) ? 1000 : 800));
    userProvider = AppStateScope.of(context).user!;
    _animationController.forward();
    initWebState();
  }

  /// TODO: INVESTIGATE THIS IS NOT WORKING FOR THE WEB

  Future<void> getUser() async {
    if (userProvider.isLoggedIn) {
      final existingUser =
          await UserService.findByEmail(email: userProvider.email);
      userProvider.user = existingUser;
    }
  }

  Future<void> initWebState() async {
    if (kIsWeb) {
      final String _email = await Settings.email;
      userProvider.isLoggedIn = _email.isNotEmpty;
      userProvider.email = _email;
      print('signedIn =${userProvider.isLoggedIn}');
      print('email =${userProvider.email}');
    }
    if (userProvider.isLoggedIn) {
      logger.d('loggedIn user = ${userProvider.email}');
      if (userProvider.isAdmin) {
        actions = popupMenu['admin']!;
      } else {
        actions = popupMenu['signout']!;
      }
    } else {
      actions = popupMenu['signin']!;
    }
    getUser();
  }

  Future<void> downloadFile() async {
    try {
      showCircularIndicator(context);
      final success = await VocabStoreService().downloadFile();
      if (success) {
        showMessage(context, 'Downloaded successfully!');
      } else {
        showMessage(context, 'Failed to Download');
      }
    } catch (x) {
      stopCircularIndicator(context);
      showMessage(context, '$x');
    }
  }

  Future<void> _onMenuSelect(String text) async {
    if (text.toLowerCase() == 'add word') {
      await Navigate.push(context, AddWordForm(),
          slideTransitionType: TransitionType.btt);
    } else if (text.toLowerCase() == 'sign out') {
      final isSignedOut = await AuthService().googleSignOut(context);
      showCircularIndicator(context);
      if (isSignedOut) {
        Settings.setIsSignedIn(false, email: '');
        userProvider.user = null;
        showMessage(context, 'Signed Out successfully!');
        stopCircularIndicator(context);
        Navigate()
            .pushAndPopAll(context, AppSignIn(),
                slideTransitionType: TransitionType.btt)
            .then((value) {});
      } else {
        stopCircularIndicator(context);
        showMessage(context, 'Failed to sign out');
      }
    } else if (text.toLowerCase() == 'download file') {
      downloadFile();
    } else if (text.toLowerCase() == 'sign in') {
      Navigate().pushAndPopAll(context, AppSignIn(),
          slideTransitionType: TransitionType.btt);
    } else {
      String url = '';
      switch (text.toLowerCase()) {
        case 'source code':
          url = '$SOURCE_CODE_URL';
          break;
        case 'privacy policy':
          url = '$PRIVACY_POLICY';
          break;
        case 'report':
          url = '$REPORT_URL';
          break;
        default:
          url = '$SOURCE_CODE_URL';
      }
      await launchURL(url);
    }
  }

  VocabStoreService supaStore = VocabStoreService();
  late AnimationController _animationController;
  late Analytics firebaseAnalytics;
  late SharedPreferences sharedPreferences;
  GlobalKey key = GlobalKey();
  List<String> actions = [];

  late UserModel userProvider;
  double x = 0;
  double y = 0;

  Widget actionWidget(String text, String url,
      {String toolTip = '', Function? onTap}) {
    return SizeUtils.isMobile
        ? SizedBox()
        : InkWell(
            onTap: onTap != null
                ? () => onTap()
                : () {
                    launchURL(url);
                  },
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeUtils.isTablet ? 18 : 24, vertical: 4),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(text,
                      style: Theme.of(context).textTheme.headline5!.copyWith(
                          color: darkNotifier.value
                              ? Colors.white
                              : VocabTheme.primaryColor,
                          fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          );
  }

  Widget _userAvatar() {
    final user = AppStateScope.of(context).user!;
    if (user.email.isEmpty)
      return CircularAvatar(
        url: '$profileUrl',
        radius: 25,
      );
    else {
      return CircularAvatar(
        name: getInitial('${user.name}'),
        url: user.avatarUrl,
        radius: 25,
        onTap: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final size = MediaQuery.of(context).size;
      return AnimatedBuilder(
        animation: _animationController,
        builder: (BuildContext context, Widget? child) {
          bool isDark = darkNotifier.value;
          return ClipPath(
            clipper: CircularClipper(
                diagonal(Size(constraints.maxWidth, constraints.maxHeight)) *
                    2 *
                    _animationController.value,
                Offset(x + 20, y + 20)),
            child: Scaffold(
              drawer: SizeUtils.isMobile
                  ? DrawerBuilder(
                      onMenuTap: (x) {
                        _onMenuSelect(x);
                      },
                    )
                  : null,
              appBar: AppBar(
                iconTheme: Theme.of(context).iconTheme,
                centerTitle: SizeUtils.isMobile ? true : false,
                title: Text('$APP_TITLE',
                    style: Theme.of(context).textTheme.headline4!.copyWith(
                        color: isDark ? Colors.white : VocabTheme.primaryColor,
                        fontWeight: FontWeight.bold)),
                actions: [
                  if (!SizeUtils.isMobile)
                    PopupMenuButton<String>(
                      offset: Offset(-20, 50),
                      onSelected: (String x) {
                        _onMenuSelect(x);
                      },
                      itemBuilder: (BuildContext context) {
                        return actions.map((String action) {
                          return PopupMenuItem<String>(
                            value: action,
                            child: Text(action),
                          );
                        }).toList();
                      },
                      child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _userAvatar()),
                    )
                ],
              ),
              floatingActionButton: FloatingActionButton(
                key: key,
                onPressed: () {
                  darkNotifier.value = !darkNotifier.value;
                  final RenderBox box =
                      key.currentContext!.findRenderObject() as RenderBox;
                  Offset position = box.localToGlobal(Offset.zero);
                  x = position.dx;
                  y = position.dy;
                  _animationController.reset();
                  _animationController.forward();

                  Settings().dark = darkNotifier.value;
                },
                backgroundColor:
                    isDark ? Colors.cyanAccent : VocabTheme.primaryColor,
                child: Icon(!isDark
                    ? Icons.brightness_2_outlined
                    : Icons.wb_sunny_rounded),
              ),
              body: Row(
                children: [
                  !SizeUtils.isMobile
                      ? Expanded(
                          flex: SizeUtils.isMobile ? 4 : 3,
                          child: Container(
                            decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey.withOpacity(0.5)
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      spreadRadius: 4,
                                      blurRadius: 4,
                                      color: Colors.grey.withOpacity(0.2),
                                      offset: Offset(1, 0))
                                ]),
                            child: WordsBuilder(
                              onSelect: (x) {
                                setState(() {
                                  selected = x;
                                });
                                firebaseAnalytics.logWordSelection(x);
                              },
                            ),
                          ))
                      : Container(),
                  Expanded(
                      flex: 8,
                      child: !SizeUtils.isMobile
                          ? WordDetail(
                              word: selected!,
                            )
                          : WordsBuilder()),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class WordsBuilder extends StatefulWidget {
  WordsBuilder({Key? key, this.onSelect}) : super(key: key);
  final Function(Word)? onSelect;

  @override
  _WordsBuilderState createState() => _WordsBuilderState();
}

class _WordsBuilderState extends State<WordsBuilder> {
  @override
  void initState() {
    super.initState();
    getWords();
  }

  Future<void> getWords() async {
    await Future.delayed(Duration.zero);
    showCircularIndicator(context);
    supaStoreWords = await VocabStoreService.getAllWords();
    stopCircularIndicator(context);
    listNotifier.value = supaStoreWords;
    totalNotifier.value = supaStoreWords.length;
  }

  Future<void> refresh() async {
    supaStoreWords = await VocabStoreService.getAllWords();
    listNotifier.value = supaStoreWords;
    totalNotifier.value = supaStoreWords.length;
    _refreshController.refreshCompleted();
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

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);
  List<Word> supaStoreWords = [];
  String selectedWord = '';
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return ValueListenableBuilder<List<Word>?>(
        valueListenable: listNotifier,
        builder: (BuildContext context, List<Word>? value, Widget? child) {
          if (value == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Container(
              color: darkNotifier.value ? VocabTheme.primaryDark : Colors.white,
              child: Column(
                children: [
                  SearchBuilder(
                    onChanged: (x) {
                      if (x.isEmpty) {
                        listNotifier.value = supaStoreWords;
                        return;
                      }
                      List<Word> result = [];
                      supaStoreWords.forEach((element) {
                        if (element.word
                                .toLowerCase()
                                .contains(x.toLowerCase()) ||
                            element.meaning
                                .toLowerCase()
                                .contains(x.toLowerCase()) ||
                            isInSynonym(x, element.synonyms)) {
                          result.add(element);
                        }
                      });
                      listNotifier.value = result;
                    },
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: SmartRefresher(
                        enablePullDown: !SizeUtils.isMobile ? false : true,
                        enablePullUp: false,
                        controller: _refreshController,
                        onRefresh: () => refresh(),
                        child: ListView.builder(
                            itemCount: value.length,
                            itemBuilder: (_, x) {
                              return WordListTile(
                                  word: value[x],
                                  isSelected: selectedWord.toLowerCase() ==
                                      value[x].word.toLowerCase(),
                                  onSelect: (word) {
                                    setState(() {
                                      selectedWord = word.word;
                                    });
                                    widget.onSelect!(word);
                                  });
                            }),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}

class WordsList extends StatefulWidget {
  const WordsList({Key? key}) : super(key: key);

  @override
  State<WordsList> createState() => _WordsListState();
}

class _WordsListState extends State<WordsList> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: Colors.red,
      ),
    );
  }
}
