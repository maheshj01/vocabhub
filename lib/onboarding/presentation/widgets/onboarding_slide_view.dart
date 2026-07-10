import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart' hide Animation;
import 'package:vocabhub/main.dart';
import 'package:vocabhub/models/word.dart';
import 'package:vocabhub/onboarding/domain/onboarding_slide.dart';

/// Renders a slide's media based on its [SlideMedia] type. Fills whatever
/// bounded box the parent gives it (no fixed heights), so it adapts to phones,
/// tablets, and desktop panes alike.
class OnboardingSlideView extends StatelessWidget {
  final OnboardingSlide slide;
  const OnboardingSlideView({super.key, required this.slide});

  @override
  Widget build(BuildContext context) {
    switch (slide.media) {
      case SlideMedia.wordCarousel:
        return const _WordCarousel();
      case SlideMedia.assetImage:
        return Center(child: Image.asset(slide.assetPath, fit: BoxFit.contain));
      case SlideMedia.networkImage:
        return Center(
          child: CachedNetworkImage(imageUrl: slide.assetPath, fit: BoxFit.contain),
        );
      case SlideMedia.rive:
        return _RiveMedia(assetPath: slide.assetPath);
    }
  }
}

/// Loads and plays a Rive asset. Holds the [FileLoader] for the widget's
/// lifetime so it isn't recreated on rebuild.
class _RiveMedia extends StatefulWidget {
  final String assetPath;
  const _RiveMedia({required this.assetPath});

  @override
  State<_RiveMedia> createState() => _RiveMediaState();
}

class _RiveMediaState extends State<_RiveMedia> {
  late final fileLoader = FileLoader.fromAsset(
    widget.assetPath,
    riveFactory: Factory.rive,
  );

  @override
  Widget build(BuildContext context) {
    return RiveWidgetBuilder(
      fileLoader: fileLoader,
      builder: (context, state) => switch (state) {
        RiveLoading() => const Center(child: CircularProgressIndicator()),
        RiveFailed() => Center(child: Text('Failed to load: ${state.error}')),
        RiveLoaded() => RiveWidget(controller: state.controller, fit: Fit.cover),
      },
    );
  }
}

/// A rotating stack of vocabulary word cards used by the first slide. Reads the
/// already-loaded word list from [dashboardController].
class _WordCarousel extends StatefulWidget {
  const _WordCarousel();

  @override
  State<_WordCarousel> createState() => _WordCarouselState();
}

class _WordCarouselState extends State<_WordCarousel> with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 2000);

  late final AnimationController _controller;

  late final Animation<double> _textOpacity;
  late final Animation<double> _textScale;

  List<Word> _words = [];
  int _index = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: _duration,
      vsync: this,
    );

    _textOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_controller);

    _textScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween(1.0),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.95).chain(CurveTween(curve: Curves.easeIn)),
        weight: 25,
      ),
    ]).animate(_controller);

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() => _index++);

        _controller
          ..reset()
          ..forward();
      }
    });

    _words = [...dashboardController.words]..shuffle();

    if (_words.isNotEmpty) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) return const SizedBox.shrink();

    final word = _words[_index % _words.length];

    return Center(
      child: Container(
        height: 280,
        width: 150,
        decoration: BoxDecoration(
          color: Colors.primaries[_index % Colors.primaries.length],
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.black,
            width: 4,
          ),
        ),
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _textOpacity.value,
              child: Transform.scale(
                scale: _textScale.value,
                child: child,
              ),
            );
          },
          child: Text(
            word.word,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
