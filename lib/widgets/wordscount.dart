import 'package:flutter/material.dart';
import 'package:vocabhub/constants/constants.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/widgets/drawer.dart';

class WordsCountAnimator extends StatefulWidget {
  final bool isAnimated;
  const WordsCountAnimator({Key? key, this.isAnimated = false})
      : super(key: key);

  @override
  _WordsCountAnimatorState createState() => _WordsCountAnimatorState();
}

class _WordsCountAnimatorState extends State<WordsCountAnimator> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: totalNotifier,
      builder: (BuildContext context, int total, Widget? child) {
        if (total == 0) {
          return Container();
        }
        return TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0.0, end: total.toDouble()),
            duration: isAnimated ? Duration.zero : wordCountAnimationDuration,
            builder: (BuildContext context, double value, Widget? child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Text('Total Words '),
                  Text(value.toInt().toString(), style: TextStyle(fontSize: 35))
                ],
              );
            });
      },
    );
  }
}
