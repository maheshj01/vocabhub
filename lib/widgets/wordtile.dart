import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vocabhub/constants/colors.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:vocabhub/widgets/examplebuilder.dart';
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
  late Color expandedColor;

  @override
  void didUpdateWidget(covariant WordTile oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (widget.isMobile) {
      setState(() {
        expandedColor = darkNotifier.value ? Colors.white : Colors.black;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    expandedColor = darkNotifier.value ? Colors.white : Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    Color tileColor() {
      if (isDark) {
        return Colors.white54;
      } else {
        return secondaryColor;
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
                accentColor: isDark ? Colors.cyanAccent : primaryColor,
                unselectedWidgetColor: isDark ? Colors.white : Colors.black),
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
                    expandedColor = isDark ? Colors.cyanAccent : primaryColor;
                  });
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
                  child: SynonymsList(
                    synonyms: widget.word.synonyms,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                  child: Text(
                    widget.word.meaning,
                    style: Theme.of(context).textTheme.headline5,
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ExampleBuilder(
                      examples: (widget.word.examples == null ||
                              widget.word.examples!.isEmpty)
                          ? []
                          : widget.word.examples,
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
