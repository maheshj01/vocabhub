import 'package:flutter/material.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/themes/vocab_theme.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/services/analytics.dart';
import 'package:vocabhub/utils/extensions.dart';

class WordListTile extends StatefulWidget {
  final Word word;
  final Function(Word)? onSelect;
  final bool isSelected;

  const WordListTile({
    Key? key,
    required this.word,
    this.onSelect,
    this.isSelected = false,
  }) : super(key: key);

  @override
  _WordListTileState createState() => _WordListTileState();
}

class _WordListTileState extends State<WordListTile> {
  late Color expandedColor;
  late Analytics firebaseAnalytics;

  @override
  void initState() {
    super.initState();
    expandedColor = darkNotifier.value ? Colors.white : Colors.black;
    firebaseAnalytics = Analytics();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = darkNotifier.value;
    final userProvider = AppStateScope.of(context).user!;

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

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () => widget.onSelect!(widget.word),
        child: Container(
          height: 80,
          width: 250,
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ]),
          child: Row(
            children: [
              SizedBox(
                width: 16,
              ),
              CircleAvatar(
                child: Text(
                  widget.word.word.initals(),
                  style: Theme.of(context).textTheme.headline4,
                ),
              ),
              SizedBox(
                width: 32,
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    widget.word.word.trim(),
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  Text(
                    widget.word.synonyms != null
                        ? widget.word.synonyms!.join(', ')
                        : '',
                    style: Theme.of(context).textTheme.subtitle2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
