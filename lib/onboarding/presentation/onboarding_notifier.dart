import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabhub/onboarding/presentation/onboarding_providers.dart';
import 'package:vocabhub/onboarding/presentation/onboarding_state.dart';

/// Orchestrates the onboarding tour: loads slides, tracks the current page, and
/// persists completion. Never mutates state in place.
class OnboardingNotifier extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    final slides = ref.read(getOnboardingSlidesProvider)();
    return OnboardingState(slides: slides);
  }

  /// Called when the PageView settles on a new page.
  void onPageChanged(int index) {
    if (index == state.index) return;
    state = state.copyWith(index: index);
  }

  /// Persists that onboarding is finished. Navigation is the caller's job (it
  /// needs a BuildContext). Guards against double taps.
  Future<void> complete() async {
    if (state.isCompleting) return;
    state = state.copyWith(isCompleting: true);
    await ref.read(completeOnboardingProvider)();
    state = state.copyWith(isCompleting: false);
  }
}

final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(OnboardingNotifier.new);
