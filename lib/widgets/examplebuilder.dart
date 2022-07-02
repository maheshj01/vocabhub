import 'package:flutter/material.dart';
import 'package:vocabhub/constants/const.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/widgets.dart';

class ExampleBuilder extends StatefulWidget {
  final List<String>? examples;
  final String word;
  const ExampleBuilder({Key? key, required this.examples, required this.word})
      : super(key: key);

  @override
  _ExampleBuilderState createState() => _ExampleBuilderState();
}

class _ExampleBuilderState extends State<ExampleBuilder> {
  @override
  Widget build(BuildContext context) {
    bool isMobile =SizeUtils.isMobile;
    bool isDark = darkNotifier.value;
    return widget.examples!.isEmpty
        ? Container()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Example',
                style: Theme.of(context).textTheme.headline4!.copyWith(
                    fontSize: isMobile ? 18 : 24,
                    color: isDark ? Colors.white : Colors.black),
              ),
              SizedBox(
                height: 20,
              ),
              ...[
                for (int i = 0; i < widget.examples!.length; i++)
                  buildExample(widget.examples![i], widget.word)
              ]
            ],
          );
  }
}
