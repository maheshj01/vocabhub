import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vocabhub/constants/colors.dart';
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
    return widget.isMobile
        ? ExpansionTile(
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
          )
        : GestureDetector(
            onTap: () => widget.onSelect!(widget.word),
            child: Container(
              color: widget.isSelected ? primaryBlue : Colors.transparent,
              child: ListTile(
                mouseCursor: SystemMouseCursors.click,
                title: Text(
                  widget.word.word.capitalize(),
                  style: TextStyle(
                    color: widget.isSelected ? Colors.white : Colors.black,
                  ),
                ),
                hoverColor: Colors.lightBlue.withOpacity(0.2),
              ),
            ),
          );
  }
}
