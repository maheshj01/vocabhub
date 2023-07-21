import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:vocabhub/services/appstate.dart';
import 'package:vocabhub/utils/extensions.dart';

class OnboardingContentPage extends StatefulWidget {
  final String title;
  final String description;
  final Color? color;
  final int index;
  final List<String> animations;
  final String assetPath;

  const OnboardingContentPage(
      {Key? key,
      required this.index,
      required this.title,
      required this.description,
      required this.color,
      required this.assetPath,
      required this.animations})
      : super(key: key);

  @override
  State<OnboardingContentPage> createState() => _OnboardingContentPageState();
}

class _OnboardingContentPageState extends State<OnboardingContentPage> {
  @override
  void didUpdateWidget(covariant OnboardingContentPage oldWidget) {
    print(oldWidget.index == widget.index);
    super.didUpdateWidget(oldWidget);
  }

  late RiveAnimationController _controller;

  // Toggles between play and pause animation states
  void _togglePlay() => setState(() => _controller.isActive = !_controller.isActive);

  /// Tracks if the animation is playing by whether controller is running
  bool get isPlaying => _controller.isActive;

  @override
  void initState() {
    _controller = OneShotAnimation('Animation 1');
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    if (widget.index == 4) {
      return WordAnimationWidget();
    }
    return Container(
      color: widget.color,
      alignment: Alignment.center,
      child: Column(
        children: [
          32.0.vSpacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.title,
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: widget.index % 2 == 0 ? Colors.black : Colors.white,
              ),
            ),
          ),
          widget.index != 0
              ? SizedBox(
                  height: size.height * 0.5,
                  child: RiveAnimation.asset(
                    '${widget.assetPath}',
                    animations: widget.animations,
                    controllers: [_controller],
                  ),
                )
              : SizedBox(
                  height: size.height * 0.5,
                  child: Image.asset(
                    '${widget.assetPath}',
                  )),
          32.0.vSpacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              widget.description,
              style: TextStyle(
                fontSize: 18.0,
                color: widget.index % 2 == 0 ? Colors.black : Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          32.0.vSpacer(),
        ],
      ),
    );
  }
}

class WordAnimationWidget extends StatefulWidget {
  const WordAnimationWidget({super.key});

  @override
  State<WordAnimationWidget> createState() => _WordAnimationWidgetState();
}

class _WordAnimationWidgetState extends State<WordAnimationWidget> {
  @override
  Widget build(BuildContext context) {
    final words = AppStateScope.of(context).words;
    print(words!.length);
    return const Placeholder();
  }
}
