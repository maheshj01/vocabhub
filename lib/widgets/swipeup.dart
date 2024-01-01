import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AnimatedIcon extends AnimatedWidget {
  const AnimatedIcon({super.key, required Animation<double> animation})
      : super(listenable: animation);

  static final _sizeTween = Tween<double>(begin: 0, end: -50);

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Container(
        color: Colors.transparent,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Transform.translate(
                offset: Offset(0, _sizeTween.evaluate(animation)),
                child: Icon(
                  CupertinoIcons.chevron_up,
                  size: 30,
                  color: colorScheme.surfaceTint,
                )),
            Text(
              'Swipe up to see more',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colorScheme.surfaceTint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SwipeUpAnimation extends StatefulWidget {
  const SwipeUpAnimation({super.key});

  @override
  State<SwipeUpAnimation> createState() => _SwipeUpAnimationState();
}

class _SwipeUpAnimationState extends State<SwipeUpAnimation> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    animation = CurvedAnimation(parent: controller, curve: Curves.easeIn)
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          controller.reverse();
        } else if (status == AnimationStatus.dismissed) {
          controller.forward();
        }
      });
    controller.forward();
  }

  @override
  Widget build(BuildContext context) => AnimatedIcon(animation: animation);

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
