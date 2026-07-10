import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vocabhub/main.dart';
import 'package:vocabhub/onboarding/data/onboarding_repository_impl.dart';
import 'package:vocabhub/onboarding/domain/onboarding_repository.dart';
import 'package:vocabhub/onboarding/domain/usecases/complete_onboarding.dart';
import 'package:vocabhub/onboarding/domain/usecases/get_onboarding_slides.dart';

/// Wiring for the onboarding feature. The repository adapts the app's global
/// [settingsController] as its completion store.
final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => OnboardingRepositoryImpl(settingsController),
);

final getOnboardingSlidesProvider = Provider<GetOnboardingSlides>(
  (ref) => GetOnboardingSlides(ref.watch(onboardingRepositoryProvider)),
);

final completeOnboardingProvider = Provider<CompleteOnboarding>(
  (ref) => CompleteOnboarding(ref.watch(onboardingRepositoryProvider)),
);
