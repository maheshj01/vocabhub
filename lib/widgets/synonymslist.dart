import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:vocabhub/constants/colors.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/pages/home.dart';
import 'package:vocabhub/utils/extensions.dart';

class SynonymsList extends StatelessWidget {
  final List<String>? synonyms;
  SynonymsList({
    Key? key,
    this.synonyms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return (synonyms == null || synonyms!.isEmpty)
        ? SizedBox(height: 20)
        : Container(
            alignment: Alignment.center,
            padding: EdgeInsets.symmetric(
                horizontal: size.width > MOBILE_WIDTH ? 12.0 : 8.0),
            child: Wrap(
              direction: Axis.horizontal,
              runSpacing: 5,
              spacing: 10,
              children: List.generate(synonyms!.length, (index) {
                String synonym = synonyms![index].capitalize();
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
                          color: darkNotifier.value
                              ? Colors.white
                              : secondaryColor,
                          borderRadius: BorderRadius.circular(20)),
                      child: Text('${synonym.trim()}',
                          style: TextStyle(
                              color: darkNotifier.value
                                  ? Colors.black
                                  : Colors.white)),
                    ),
                  ),
                );
              }),
            ),
          );
  }
}
