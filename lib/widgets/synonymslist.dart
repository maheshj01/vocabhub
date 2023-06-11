import 'package:flutter/material.dart';
import 'package:vocabhub/navbar/search/search.dart';
import 'package:vocabhub/utils/extensions.dart';
import 'package:vocabhub/utils/size_utils.dart';

class SynonymsList extends StatelessWidget {
  final List<String>? synonyms;
  final double emptyHeight;
  SynonymsList({
    Key? key,
    this.emptyHeight = 20,
    this.synonyms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Size size = MediaQuery.of(context).size;
    return (synonyms == null || synonyms!.isEmpty)
        ? emptyHeight.vSpacer()
        : Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
                horizontal: !SizeUtils.isMobile ? 12.0 : 8.0),
            child: Wrap(
              direction: Axis.horizontal,
              runSpacing: 5,
              spacing: 10,
              children: List.generate(synonyms!.length, (index) {
                final String synonym = synonyms![index].capitalize()!;
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () {
                      searchController.text = synonym.trim();
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(20)),
                        child: Text(
                          '${synonym.trim()}',
                    ),
                  ),
                    ));
              }),
            ),
          );
  }
}
