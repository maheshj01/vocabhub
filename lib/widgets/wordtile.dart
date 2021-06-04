import 'package:flutter/material.dart';
import 'package:vocabhub/models/word_model.dart';
import 'package:vocabhub/widgets/synonymslist.dart';

class WordTile extends StatefulWidget {
  final Word word;
  final bool isMobile;
  final Function(Word)? onSelect;

  const WordTile(
      {Key? key, required this.word, this.onSelect, this.isMobile = false})
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
            title: Text(widget.word.word),
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 16),
                child: SynonymsList(
                  synonyms: widget.word.synonyms,
                  mainAxisAlignment: MainAxisAlignment.start,
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
            child: ListTile(
              title: Text(widget.word.word),
            ),
          );
  }
}
