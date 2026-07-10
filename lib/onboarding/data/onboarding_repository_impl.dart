import 'package:vocabhub/controller/settings_controller.dart';
import 'package:vocabhub/onboarding/data/onboarding_content.dart';
import 'package:vocabhub/onboarding/domain/onboarding_repository.dart';
import 'package:vocabhub/onboarding/domain/onboarding_slide.dart';

/// Serves static onboarding content and delegates completion persistence to the
/// app's existing [SettingsController] (SharedPreferences-backed via
/// `SettingsService`), so there's a single source of truth for the onboarded
/// flag.
class OnboardingRepositoryImpl implements OnboardingRepository {
  OnboardingRepositoryImpl(this._settings);

  final SettingsController _settings;

  @override
  List<OnboardingSlide> slides() => kOnboardingSlides;

  @override
  bool get isComplete => _settings.isOnboarded;

  @override
  Future<void> complete() async {
    // The setter both updates in-memory state and persists to SharedPreferences.
    _settings.onBoarded = true;
  }
}
