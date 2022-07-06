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

    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(boxShadow: [VocabTheme.primaryShadow]),
        height: 80,
        width: 220,
        child: Material(
          borderRadius: 8.0.allRadius,
          color: Theme.of(context).colorScheme.surface,
          child: InkWell(
            borderRadius: BorderRadius.circular(8.0),
            onTap: () => widget.onSelect!(widget.word),
            focusColor: colorScheme.primary.withOpacity(0.2),
            splashColor: colorScheme.primary.withOpacity(0.2),
            hoverColor: colorScheme.primary.withOpacity(0.2),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                ),
                Flexible(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.word.word.trim(),
                        style: Theme.of(context).textTheme.headline4,
                      ),
                      Text(
                        widget.word.meaning,
                        style: Theme.of(context).textTheme.subtitle2,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}