import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vocabhub/constants/colors.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:vocabhub/widgets/synonymslist.dart';
import 'package:vocabhub/utils/extensions.dart';

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
  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;

    Color tileColor() {
      if (widget.isSelected) {
        if (isDark) {
          return Colors.white54;
        } else {
          return secondaryColor;
        }
      } else {
        if (isDark) {
          return primaryDark;
        } else {
          return Colors.white;
        }
      }
    }

    Color textColor() {
      if (widget.isSelected) {
        if (isDark) {
          return Colors.black;
        } else {
          return Colors.black;
        }
      } else {
        if (isDark) {
          return Colors.white;
        } else {
          return Colors.black;
        }
      }
    }

    return widget.isMobile
        ? Theme(
            data: Theme.of(context).copyWith(
                accentColor: isDark ? Colors.cyanAccent : primaryColor,
                unselectedWidgetColor: isDark ? Colors.white : Colors.black),
            child: ExpansionTile(
              expandedAlignment: Alignment.centerLeft,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              title: Text(widget.word.word.capitalize()),
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                  child: SynonymsList(
                    synonyms: widget.word.synonyms,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Text(widget.word.meaning),
                )
              ],
            ),
          )
        : GestureDetector(
            onTap: () => widget.onSelect!(widget.word),
            child: Container(
              color: tileColor(),
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                title: Text(
                  widget.word.word.capitalize(),
                  style: TextStyle(color: textColor()),
                ),
              ),
            ),
          );
  }
}
