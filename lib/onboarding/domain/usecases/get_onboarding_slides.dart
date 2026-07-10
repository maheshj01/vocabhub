import 'package:vocabhub/onboarding/domain/onboarding_repository.dart';
import 'package:vocabhub/onboarding/domain/onboarding_slide.dart';

/// Returns the ordered onboarding slides.
class GetOnboardingSlides {
  const GetOnboardingSlides(this._repository);
  final OnboardingRepository _repository;

  List<OnboardingSlide> call() => _repository.slides();
}
