import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:vocabhub/constants/strings.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/utils/extensions.dart';

class OnboardingContentPage extends StatefulWidget {
  final Color? color;
  final int index;
  final List<String> animations;
  final String assetPath;

  const OnboardingContentPage(
      {Key? key,
      required this.index,
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
    return Container(
      color: widget.color,
      alignment: Alignment.center,
      child: Column(
        children: [
          40.0.vSpacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              onBoardingTitles[widget.index],
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: widget.index < 2 ? Colors.black : Colors.white,
              ),
            ),
          ),
          widget.index == 0
              ? Padding(
                  padding: 32.0.verticalPadding + 48.0.bottomPadding,
                  child: WordAnimationWidget(),
                )
              : widget.index != 1
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
                      child: CachedNetworkImage(
                        imageUrl: '${widget.assetPath}',
                      )),
          32.0.vSpacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              onBoardingDescriptions[widget.index],
              style: TextStyle(
                fontSize: 18.0,
                color: widget.index < 2 ? Colors.black : Colors.white,
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

class _WordAnimationWidgetState extends State<WordAnimationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _wordController;
  @override
  void initState() {
    super.initState();
    _wordController = AnimationController(
      duration: duration,
      vsync: this,
    );
    _wordController
      ..addListener(() {
        if (_wordController.status == AnimationStatus.completed) {
          setState(() {
            index++;
          });
          _wordController.reset();
          _wordController.forward();
        }
      });

    words = dashboardController.words;
    words.shuffle();
    _wordController.forward();
  }

  final duration = Duration(milliseconds: 1600);

  List<Word> words = [];

  @override
  void dispose() {
    // _controller.dispose();
    _wordController.dispose();
    super.dispose();
  }

  int index = 0;
  @override
  Widget build(BuildContext context) {
    final words = dashboardController.words;
    if (words.isEmpty) return SizedBox();

    final word = words[index];
    return Center(
        child: Container(
            height: 280,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.primaries[index % Colors.primaries.length],
              borderRadius: BorderRadius.circular(16.0),
              border: Border.all(color: Colors.black, width: 4),
            ),
            alignment: Alignment.center,
            child: AnimatedText(
              text: word.word,
              duration: duration,
            )));
  }
}

/// Animated text widget to fadein and fadeOut text
/// For half the duration the text will fade in and for the other half it will fade out
class AnimatedText extends StatefulWidget {
  final String text;
  final Duration duration;
  const AnimatedText(
      {super.key, required this.text, this.duration = const Duration(milliseconds: 2000)});

  @override
  State<AnimatedText> createState() => _AnimatedTextState();
}

class _AnimatedTextState extends State<AnimatedText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    fadeIn = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.0,
          0.5,
          curve: Curves.easeIn,
        ),
      ),
    );
    fadeOut = Tween<double>(begin: 1.0, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(
          0.5,
          1.0,
          curve: Curves.easeOut,
        ),
      ),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  late Animation<double> fadeIn;
  late Animation<double> fadeOut;

  @override
  void didUpdateWidget(covariant AnimatedText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final value = _controller.value;
          return Opacity(
              opacity: value > 0.5 ? fadeOut.value : fadeIn.value,
              child: Text(
                widget.text,
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
              ));
        });
  }
}
