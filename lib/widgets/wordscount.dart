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
  double _opacity = 0.0;
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
            onEnd: () {
              setState(() {
                _opacity = 1.0;
              });
            },
            builder: (BuildContext context, double value, Widget? child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 50,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 90,
                        child: Text(value.toInt().toString(),
                            style: Theme.of(context).textTheme.headline3),
                      ),
                      AnimatedOpacity(
                          duration: Duration(milliseconds: 500),
                          opacity: _opacity,
                          child: Text(
                            ' Words added so far...',
                            style: Theme.of(context).textTheme.headline6,
                          ))
                    ],
                  ),
                ],
              );
            });
      },
    );
  }
}
