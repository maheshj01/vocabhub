import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:vocabhub/models/word.dart';

/// A single word row in a list — the design-system card used across search,
/// bookmarks, and collections. Full-width (sizes to its parent), with a
/// highlighted [isSelected] state for desktop master/detail lists.
class WordListTile extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => onSelect?.call(word),
          focusColor: colorScheme.primary.withValues(alpha: 0.12),
          hoverColor: colorScheme.primary.withValues(alpha: 0.08),
          splashColor: colorScheme.primary.withValues(alpha: 0.12),
          child: Ink(
            decoration: BoxDecoration(
              color:
                  isSelected ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    word.word.trim(),
                    style: GoogleFonts.quicksand(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? colorScheme.onPrimaryContainer : colorScheme.onSurface,
                    ),
                  ),
                  if (word.meaning.trim().isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      word.meaning,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.quicksand(
                        fontSize: 13,
                        height: 1.3,
                        color: isSelected
                            ? colorScheme.onPrimaryContainer.withValues(alpha: 0.85)
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
