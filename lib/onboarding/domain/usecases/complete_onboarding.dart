import 'package:vocabhub/onboarding/domain/onboarding_repository.dart';

/// Marks onboarding as finished (persisted via the repository).
class CompleteOnboarding {
  const CompleteOnboarding(this._repository);
  final OnboardingRepository _repository;

  Future<void> call() => _repository.complete();
}
