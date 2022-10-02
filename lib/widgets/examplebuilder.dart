import 'package:flutter/material.dart';
import 'package:vocabhub/utils/utils.dart';
import 'package:vocabhub/widgets/widgets.dart';

class ExampleListBuilder extends StatefulWidget {
  final List<String>? examples;
  final String word;
  final String title;
  const ExampleListBuilder(
      {Key? key,
      required this.title,
      required this.examples,
      required this.word})
      : super(key: key);

  @override
  _ExampleListBuilderState createState() => _ExampleListBuilderState();
}

class _ExampleListBuilderState extends State<ExampleListBuilder> {
  Widget title(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          '$title',
          style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: SizeUtils.isMobile ? 18 : 24),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.examples!.isEmpty
        ? SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...[
                  title(widget.title),
                  16.0.vSpacer(),
                  for (int i = 0; i < widget.examples!.length; i++)
                    buildExample(widget.examples![i], widget.word)
                ]
              ],
            ),
          );
  }
}
