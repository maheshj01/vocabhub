import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/models/user.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/pages/addword.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/utils/navigator.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/widgets/examplebuilder.dart';
import 'package:vocabhub/widgets/mnemonicbuilder.dart';
import 'package:vocabhub/widgets/synonymslist.dart';

class WordTile extends StatefulWidget {
  final Word word;
  final bool isMobile;
  final Function(Word)? onSelect;
  final bool isSelected;

  const WordTile(
      {Key? key,
      required this.word,
      this.onSelect,
      this.isSelected = false,
      this.isMobile = false})
      : super(key: key);

  @override
  _WordTileState createState() => _WordTileState();
}

class _WordTileState extends State<WordTile> {
  late Color expandedColor;
  late Analytics firebaseAnalytics;
  @override
  void didUpdateWidget(covariant WordTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isMobile) {
      setState(() {
        expandedColor = darkNotifier.value ? Colors.white : Colors.black;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    expandedColor = darkNotifier.value ? Colors.white : Colors.black;
    firebaseAnalytics = Analytics();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    final userProvider = Provider.of<UserModel>(context);

    Color tileColor() {
      if (isDark) {
        return Colors.white54;
      } else {
        return VocabTheme.secondaryColor;
      }
    }

    Color textColor() {
      if (!widget.isSelected && isDark) {
        return Colors.white;
      } else {
        return Colors.black;
      }
    }

    return widget.isMobile
        ? Theme(
            data: Theme.of(context).copyWith(
                unselectedWidgetColor: isDark ? Colors.white : Colors.black,
                colorScheme: ColorScheme.fromSwatch().copyWith(
                    secondary:
                        isDark ? Colors.cyanAccent : VocabTheme.primaryColor)),
            child: ExpansionTile(
              expandedAlignment: Alignment.centerLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: Text(
                widget.word.word.capitalize(),
                style: TextStyle(color: expandedColor),
              ),
              onExpansionChanged: (expanded) {
                if (expanded) {
                  setState(() {
                    expandedColor =
                        isDark ? Colors.cyanAccent : VocabTheme.primaryColor;
                  });
                  firebaseAnalytics.logWordSelection(widget.word);
                } else {
                  setState(() {
                    expandedColor = isDark ? Colors.white : Colors.black;
                  });
                }
              },
              trailing: Container(width: 1),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: SynonymsList(
                          synonyms: widget.word.synonyms,
                        ),
                      ),
                      userProvider.isLoggedIn &&
                              emails.contains(userProvider.email)
                          ? Container(
                              alignment: Alignment.topRight,
                              padding: EdgeInsets.only(right: 16),
                              child: IconButton(
                                  icon: Icon(Icons.edit),
                                  onPressed: () {
                                    Navigate().push(
                                        context,
                                        AddWordForm(
                                          isEdit: true,
                                          word: widget.word,
                                        ),
                                        slideTransitionType:
                                            SlideTransitionType.btt);
                                  }))
                          : SizedBox(),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: SelectableText(
                    widget.word.meaning,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                SizedBox(
                  height: 8,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: ExampleBuilder(
                      examples: (widget.word.examples == null ||
                              widget.word.examples!.isEmpty)
                          ? []
                          : widget.word.examples,
                      word: widget.word.word,
                    )),
                Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8),
                    child: MnemonnicBuilder(
                      mnemonics: (widget.word.mnemonics == null ||
                              widget.word.mnemonics!.isEmpty)
                          ? []
                          : widget.word.mnemonics,
                      word: widget.word.word,
                    )),
              ],
            ),
          )
        : GestureDetector(
            onTap: () => widget.onSelect!(widget.word),
            child: Container(
              color: widget.isSelected ? tileColor() : null,
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                title: Text(
                  widget.word.word.capitalize(),
                  style: Theme.of(context)
                      .textTheme
                      .headline5!
                      .copyWith(color: textColor()),
                ),
              ),
            ),
          );
  }
}
