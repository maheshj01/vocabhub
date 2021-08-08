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
  final _opacityNotifier = ValueNotifier<double>(0.0);
  @override
  void dispose() {
    _opacityNotifier.dispose();
    super.dispose();
  }

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
              _opacityNotifier.value = 1.0;
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
                        alignment: Alignment.bottomRight,
                        child: Text(value.toInt().toString(),
                            style: Theme.of(context).textTheme.headline3),
                      ),
                      ValueListenableBuilder<double>(
                          valueListenable: _opacityNotifier,
                          builder: (BuildContext context, double value,
                              Widget? child) {
                            return AnimatedOpacity(
                                duration: Duration(milliseconds: 500),
                                opacity: value,
                                child: Text(
                                  ' Words added so far...',
                                  style: Theme.of(context).textTheme.headline6,
                                ));
                          })
                    ],
                  ),
                ],
              );
            });
      },
    );
  }
}
