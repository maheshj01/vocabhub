import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:navbar_router/navbar_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:vocabhub/exports.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/pages/notifications/notification_detail.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/services/services.dart';
import 'package:vocabhub/utils/utility.dart';
import 'package:vocabhub/widgets/drawer.dart';
import 'package:vocabhub/widgets/examplebuilder.dart';
import 'package:vocabhub/widgets/responsive.dart';
import 'package:vocabhub/widgets/synonymslist.dart';
import 'package:vocabhub/widgets/word_title.dart';

class WordDetail extends StatefulWidget {
  static String routeName = '/worddetail';
  final Word word;
  final String? title;

  /// If true, then it is a word of the day
  final bool isWod;
  const WordDetail({Key? key, required this.word, this.title, this.isWod = false})
      : super(key: key);

  @override
  State<WordDetail> createState() => _WordDetailState();
}

class _WordDetailState extends State<WordDetail> {
  @override
  void initState() {
    super.initState();
    if (widget.isWod) {
      analytics.logRouteView(WordDetail.routeName);
    }
  }

  final analytics = Analytics.instance;
  @override
  Widget build(BuildContext context) {
    return ResponsiveBuilder(desktopBuilder: (context) {
      return WordDetailDesktop(
        word: widget.word,
        isWod: widget.isWod,
      );
    }, mobileBuilder: (BuildContext context) {
      return WordDetailMobile(
        word: widget.word,
        title: widget.title,
      );
    });
  }
}

class WordDetailMobile extends ConsumerStatefulWidget {
  final Word? word;
  final String? title;
  const WordDetailMobile({Key? key, required this.word, this.title}) : super(key: key);

  @override
  _WordDetailMobileState createState() => _WordDetailMobileState();
}

class _WordDetailMobileState extends ConsumerState<WordDetailMobile> {
  String selectedWord = '';
  int length = 0;
  late String meaning;
  late VocabStoreService supaStore;
  UserModel userProvider = UserModel.init();

  @override
  Widget build(BuildContext context) {
    final userProvider = ref.watch(userNotifierProvider);
    final size = MediaQuery.of(context).size;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: widget.title != null ? Text(widget.title!) : null,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
              icon: Icon(
                Icons.share,
                color: colorScheme.primary,
              ),
              onPressed: () {
                final String message = buildShareMessage(widget.word!);
                Share.share(message);
              })
        ],
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.bottomRight,
                  child: userProvider.isLoggedIn
                      ? IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: colorScheme.primary,
                          ),
                          onPressed: () {
                            Navigate.push(
                                context,
                                AddWordForm(
                                  isEdit: true,
                                  word: widget.word,
                                ),
                                transitionType: TransitionType.scale);
                          })
                      : SizedBox.shrink(),
                ),
                Align(
                    alignment: Alignment.topCenter,
                    child: WordTitleBuilder(
                      word: widget.word!,
                      hasFloatingActionButton: true,
                    )),
              ],
            ),
          ),
          Padding(
            padding: 48.0.horizontalPadding,
            child: SynonymsList(
              synonyms: widget.word!.synonyms,
              onTap: (synonym) {
                if (SizeUtils.isDesktop) {
                  NavbarNotifier.index = SEARCH_INDEX;
                  searchController.setText(synonym);
                }
              },
            ),
          ),
          16.0.vSpacer(),
          TextButton(
            child: Text("show edit History"),
            onPressed: () async {
              await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (context) {
                    return DraggableScrollableSheet(
                        maxChildSize: 0.8,
                        initialChildSize: 0.8,
                        expand: false,
                        builder: (context, controller) {
                          return NotificationDetailMobile(
                              title: "Edit History",
                              isNotification: false,
                              word: widget.word!.word);
                        });
                  });
            },
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              widget.word!.meaning,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontFamily: GoogleFonts.inter(
                    fontWeight: FontWeight.w400,
                  ).fontFamily),
            ),
          ),
          48.0.vSpacer(),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ExampleListBuilder(
                title: 'Usage',
                examples: (widget.word!.examples == null || widget.word!.examples!.isEmpty)
                    ? []
                    : widget.word!.examples,
                word: widget.word!.word,
              )),
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: ExampleListBuilder(
                title: 'Mnemonics',
                examples: (widget.word!.mnemonics == null || widget.word!.mnemonics!.isEmpty)
                    ? []
                    : widget.word!.mnemonics,
                word: widget.word!.word,
              )),
          kNavbarHeight.vSpacer()
        ]),
      ),
    );
  }
}

class WordDetailDesktop extends ConsumerStatefulWidget {
  final Word? word;
  final bool isWod;
  WordDetailDesktop({
    Key? key,
    this.word,
    this.isWod = false,
  }) : super(key: key);

  @override
  _WordDetailDesktopState createState() => _WordDetailDesktopState();
}

class _WordDetailDesktopState extends ConsumerState<WordDetailDesktop>
    with SingleTickerProviderStateMixin {
  late Animation<int> _animation;
  late Tween<int> _tween;
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: Duration(seconds: 3));
    meaning = '';
    if (widget.word != null) {
      selectedWord = widget.word!.word;
      meaning = widget.word!.meaning;
      length = widget.word!.meaning.length;
    }
    supaStore = VocabStoreService();
    _tween = IntTween(begin: 0, end: length);
    _animation = _tween.animate(_animationController);
    _animationController.addStatusListener((status) {
      // if (status == AnimationStatus.completed) {
      // _animationController.reset();
      // }
    });
    _animationController.forward();
  }

  int length = 0;
  int synLength = 0;
  String selectedWord = '';
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant WordDetailDesktop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.word != null) {
      setState(() {
        length = widget.word!.meaning.length;
        meaning = widget.word!.meaning;
      });
    }
    if (length < 30) {
      _animationController.duration = Duration(seconds: 1);
    } else {
      _animationController.duration = Duration(seconds: 3);
    }
    _tween.end = length;
    if (widget.word?.word != selectedWord) {
      _animationController.reset();
      _animationController.forward();
    }
    if (widget.word != null) {
      selectedWord = widget.word!.word;
    }
  }

  late String meaning;
  late VocabStoreService supaStore;
  UserModel userProvider = UserModel.init();

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    userProvider = ref.watch(userNotifierProvider);
    return widget.word == null
        ? EmptyWord()
        : Material(
            child: Column(
              children: [
                (SizeUtils.isMobile ? 24.0 : (size.height / 5)).vSpacer(),
                userProvider.isLoggedIn
                    ? Container(
                        alignment: Alignment.topRight,
                        padding: EdgeInsets.only(right: 16),
                        child: IconButton(
                            icon: Icon(
                              Icons.edit,
                            ),
                            onPressed: () {
                              Navigate.push(
                                  context,
                                  AddWordForm(
                                    isEdit: true,
                                    word: widget.word,
                                  ),
                                  transitionType: TransitionType.scale);
                            }))
                    : SizedBox.shrink(),
                Align(
                  alignment: Alignment.topCenter,
                  child: GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: "${widget.word!.word}"));
                      NavbarNotifier.showSnackBar(
                          context, " copied ${widget.word!.word} to clipboard.");
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Text(
                            widget.word!.word.capitalize()!,
                            style: Theme.of(context).textTheme.displayMedium!,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                20.0.vSpacer(),
                SynonymsList(
                  synonyms: widget.word!.synonyms,
                  onTap: (synonym) {
                    searchController.setText(synonym);
                    if (widget.isWod || SizeUtils.isDesktop) {
                      NavbarNotifier.index = SEARCH_INDEX;
                    }
                  },
                ),
                50.0.vSpacer(),
                AnimatedBuilder(
                    animation: _animation,
                    builder: (BuildContext _, Widget? child) {
                      meaning = widget.word!.meaning.substring(0, _animation.value);
                      return Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: SelectableText(meaning,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                                    fontFamily: GoogleFonts.inter(
                                  fontWeight: FontWeight.w400,
                                ).fontFamily)),
                      );
                    }),
                48.0.vSpacer(),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ExampleListBuilder(
                      title: 'Usage',
                      examples: (widget.word!.examples == null || widget.word!.examples!.isEmpty)
                          ? []
                          : widget.word!.examples,
                      word: widget.word!.word,
                    )),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ExampleListBuilder(
                      title: 'Mnemonics',
                      examples: (widget.word!.mnemonics == null || widget.word!.mnemonics!.isEmpty)
                          ? []
                          : widget.word!.mnemonics,
                      word: widget.word!.word,
                    )),
                100.0.vSpacer(),
              ],
            ),
          );
  }
}

class EmptyWord extends StatefulWidget {
  EmptyWord({Key? key}) : super(key: key);

  @override
  _EmptyWordState createState() => _EmptyWordState();
}

class _EmptyWordState extends State<EmptyWord> {
  late int randIndex;

  @override
  void initState() {
    super.initState();
    randIndex = Random().nextInt(tips.length);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: Container()),
          Text(
            'Whats the word on your mind?',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          16.0.vSpacer(),
          Text('Tip: ${tips[randIndex]}',
              textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          Expanded(child: Container()),
          Padding(padding: EdgeInsets.symmetric(vertical: 16), child: VersionBuilder()),
          40.0.vSpacer(),
        ],
      ),
    );
  }
}
