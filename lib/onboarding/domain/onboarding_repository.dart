import 'package:vocabhub/onboarding/domain/onboarding_slide.dart';

/// Domain contract for onboarding content and completion state. The
/// implementation lives in the data layer (`OnboardingRepositoryImpl`).
abstract class OnboardingRepository {
  /// The ordered slides shown in the tour.
  List<OnboardingSlide> slides();

  /// Whether the user has finished onboarding before.
  bool get isComplete;

  /// Persists that the user has finished onboarding.
  Future<void> complete();
}
