/// Which kind of media a slide renders. Replaces the old index-based branching
/// (`index == 0`, `index != 1`, …) with an explicit, reorder-safe field.
enum SlideMedia { rive, assetImage, networkImage, wordCarousel }

/// Pure-Dart description of a single onboarding slide.
///
/// Deliberately free of Flutter/`dart:ui` imports so content and ordering stay
/// trivially unit-testable. Colors are 32-bit ARGB ints; the presentation layer
/// turns them into `Color`s.
class OnboardingSlide {
  final String title;
  final String description;

  /// A Rive asset path, or (for [SlideMedia.networkImage]) an image URL. Unused
  /// by [SlideMedia.wordCarousel].
  final String assetPath;

  final SlideMedia media;

  /// Rive artboard animation names (informational; the default artboard plays).
  final List<String> riveAnimations;

  /// Background as an ARGB value, e.g. `0xFF151421`.
  final int backgroundColorValue;

  /// When true the background is light, so title/description render in dark ink.
  final bool darkText;

  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.assetPath,
    required this.media,
    required this.backgroundColorValue,
    this.riveAnimations = const [],
    this.darkText = false,
  });
}
