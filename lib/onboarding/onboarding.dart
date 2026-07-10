/// Onboarding feature (Clean Architecture): domain (slides + contracts), data
/// (static content + SettingsController-backed completion), presentation
/// (Riverpod notifier + responsive welcome/tour UI).
///
/// Public entry points for the rest of the app are the two pages below.
library onboarding;

export 'presentation/onboarding_page.dart';
export 'presentation/welcome_page.dart';
