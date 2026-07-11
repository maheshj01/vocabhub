import 'package:vocabhub/onboarding/domain/onboarding_slide.dart';

/// Immutable UI state for the onboarding tour. The notifier rewrites it; widgets
/// only read it.
class OnboardingState {
  final List<OnboardingSlide> slides;

  /// Currently visible slide.
  final int index;

  /// True while completion is being persisted (drives the CTA spinner).
  final bool isCompleting;

  const OnboardingState({
    this.slides = const [],
    this.index = 0,
    this.isCompleting = false,
  });

  int get count => slides.length;

  bool get isLastSlide => slides.isNotEmpty && index == slides.length - 1;

  OnboardingSlide? get currentSlide => (index >= 0 && index < slides.length) ? slides[index] : null;

  OnboardingState copyWith({
    List<OnboardingSlide>? slides,
    int? index,
    bool? isCompleting,
  }) {
    return OnboardingState(
      slides: slides ?? this.slides,
      index: index ?? this.index,
      isCompleting: isCompleting ?? this.isCompleting,
    );
  }
}
