import 'package:flutter/material.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';

class ExampleBuilder extends StatefulWidget {
  final List<String>? examples;
  final String word;
  const ExampleBuilder({Key? key, required this.examples, required this.word})
      : super(key: key);

  @override
  _ExampleBuilderState createState() => _ExampleBuilderState();
}

class _ExampleBuilderState extends State<ExampleBuilder> {
  RichText getExample(String example) {
    final textSpans = [TextSpan(text: ' - ')];

    final iterable = example
        .split(' ')
        .toList()
        .map((e) => TextSpan(
            text: e + ' ',
            style: TextStyle(
                fontWeight:
                    (e.toLowerCase().contains(widget.word.toLowerCase()))
                        ? FontWeight.bold
                        : FontWeight.normal)))
        .toList();
    textSpans.addAll(iterable);
    textSpans.add(TextSpan(text: '\n'));
    return RichText(
        text: TextSpan(
            style: TextStyle(
                color: darkNotifier.value ? Colors.white : Colors.black),
            children: textSpans));
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = MediaQuery.of(context).size.width <= MOBILE_WIDTH;
    return widget.examples!.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Example',
                style: TextStyle(fontSize: isMobile ? 18 : 24),
              ),
              SizedBox(
                height: 20,
              ),
              ...[
                for (int i = 0; i < widget.examples!.length; i++)
                  getExample(widget.examples![i])
              ]
            ],
          );
  }
}
