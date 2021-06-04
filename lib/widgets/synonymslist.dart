import 'package:flutter/material.dart';

class SynonymsList extends StatelessWidget {
  final List<String>? synonyms;
  MainAxisAlignment mainAxisAlignment;
  SynonymsList(
      {Key? key,
      this.synonyms,
      this.mainAxisAlignment = MainAxisAlignment.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return synonyms!.isEmpty
        ? SizedBox(height: 20)
        : Row(
            mainAxisAlignment: mainAxisAlignment,
            children: [
              Wrap(
                direction: Axis.horizontal,
                runSpacing: 5,
                spacing: 10,
                children: List.generate(synonyms!.length, (index) {
                  String synonym = synonyms![index];
                  return Container(
                      alignment: Alignment.center,
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.lightBlue.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(synonym));
                }),
              ),
            ],
          );
  }
}
