# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project overview

Vocabhub is a Flutter/Dart app (Android, iOS, Web) that helps users build GRE/English vocabulary. The app uses:
- Supabase (Postgres) as the primary data store and auth source
- Firebase (Analytics, Crashlytics, Messaging, Remote Config) for telemetry, push notifications, and feature flags

The same Flutter codebase powers Android and the hosted web app at `vocabhub.web.app`.

Key docs:
- `README.md` – product overview, screenshots, links to Play Store, web app, and Figma designs
- `Contributing.md` – Firebase/Supabase provisioning instructions and schema SQL
- GitHub wiki – detailed setup and run instructions: "Project Specifications and Knowledge base"

## Environment & configuration

### Secrets and runtime configuration

API keys and URLs are expected to be passed via Dart environment defines and read from `lib/constants/const.dart`:
- `SUPABASE_PROJECT_URL`
- `SUPABASE_API_KEY`
- `SUPABASE_REDIRECT_URL`
- `SUPABASE_SERVICE_ROLE`
- `FIREBASE_VAPID_KEY`
- `ADMIN_EMAIL`
- `FCM_SERVER_KEY`
- `GOOGLE_SERVER_CLIENT_ID`

`Constants` reads them using `String.fromEnvironment`, so you must provide them via `--dart-define` (locally) or CI secrets (see `.github/workflows`).

The `Makefile` contains targets (`run`, `release_ios`, `release_android`, `test_integration`) that hard-code production values for these defines. Use it as a reference for which keys are required, but avoid copying the literal values into new files or scripts.

### Firebase setup (summary)

See `Contributing.md` for the full flow. High-level:
- Install Firebase CLI and `flutterfire_cli`
- Create a Firebase project and run `flutterfire configure`
- Move the generated `firebase_options.dart` into `lib/utils/firebase_options.dart` (CI does this via `FIREBASE_UTILS_OPTIONS`)
- Configure Firebase Remote Config keys:
  - `version` and `buildNumber` based on `pubspec.yaml`

### Supabase setup (summary)

`Contributing.md` contains SQL to initialize the Supabase schema. Core tables:
- `users_mobile` – user accounts and auth metadata
- `vocabsheet_mobile` – vocabulary words and metadata
- `edit_history`, `feedback`, `login`, `word_of_the_day`, `word_state` – edits, feedback, WOTD, and word mastery state

After applying the SQL, import the seed CSV referenced in `Contributing.md` into `vocabsheet_mobile`.

## Common commands

All commands are intended to be run from the repo root (`vocabhub`).

### Dependency management

```sh path=null start=null
flutter pub get
```

### Static analysis

```sh path=null start=null
flutter analyze
```

### Running the app (local development)

For day-to-day development, prefer calling `flutter` directly and supply your own non-production keys:

```sh path=null start=null
flutter run \
  --dart-define=SUPABASE_PROJECT_URL=<your-supabase-url> \
  --dart-define=SUPABASE_API_KEY=<your-supabase-anon-key> \
  --dart-define=SUPABASE_REDIRECT_URL=<your-redirect-url> \
  --dart-define=SUPABASE_SERVICE_ROLE=<your-service-role-key> \
  --dart-define=FIREBASE_VAPID_KEY=<your-firebase-vapid-key> \
  --dart-define=ADMIN_EMAIL=<admin-email> \
  --dart-define=FCM_SERVER_KEY=<your-fcm-server-key> \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<your-google-client-id>
```

Useful `Makefile` targets (inspect `Makefile` before using, as some embed production values):

```sh path=null start=null
# Launch Android emulator
make start-emu

# Start Flutter DevTools
make start-devtools

# Clean platform builds and re-fetch deps
make clean       # or: make clean_ios / make clean_android

# Regenerate gRPC client from proto definitions
make generate
```

### Web build (mirrors CI configuration)

The GitHub Actions workflows build the web app with the same Dart defines as mobile:

```sh path=null start=null
flutter build web --release \
  --dart-define=SUPABASE_PROJECT_URL=<supabase-url> \
  --dart-define=SUPABASE_API_KEY=<supabase-anon-key> \
  --dart-define=SUPABASE_REDIRECT_URL=<redirect-url> \
  --dart-define=SUPABASE_SERVICE_ROLE=<service-role-key> \
  --dart-define=FIREBASE_VAPID_KEY=<firebase-vapid-key> \
  --dart-define=ADMIN_EMAIL=<admin-email> \
  --dart-define=FCM_SERVER_KEY=<fcm-server-key> \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<google-client-id>
```

CI also uses Shorebird to patch Android builds; see `.github/workflows/firebase-hosting-merge.yml` for details.

### Testing

#### Unit/widget tests

Run all unit/widget tests:

```sh path=null start=null
flutter test
```

Run a single test file (example):

```sh path=null start=null
flutter test test/widget_test.dart
```

#### Integration tests

Integration tests live under `integration_test/` and are driven by `test_driver/integration_test.dart`.

From the Makefile (uses real production keys) there is a `test_integration` target. For safer local runs, invoke `flutter drive` with your own defines:

```sh path=null start=null
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  --no-build \
  --dart-define=SUPABASE_PROJECT_URL=<supabase-url> \
  --dart-define=SUPABASE_API_KEY=<supabase-anon-key> \
  --dart-define=SUPABASE_REDIRECT_URL=<redirect-url> \
  --dart-define=SUPABASE_SERVICE_ROLE=<service-role-key> \
  --dart-define=FIREBASE_VAPID_KEY=<firebase-vapid-key> \
  --dart-define=ADMIN_EMAIL=<admin-email> \
  --dart-define=FCM_SERVER_KEY=<fcm-server-key> \
  --dart-define=GOOGLE_SERVER_CLIENT_ID=<google-client-id>
```

## High-level architecture

### Entry point and app composition

- `lib/main.dart` is the main entry point.
  - Initializes Flutter bindings, `SharedPreferences`, Supabase (`Supabase.initialize`) and Firebase (`Firebase.initializeApp` using `DefaultFirebaseOptions.currentPlatform`).
  - Sets up global controllers (`DashboardController`, `SettingsController`, `ExploreController`, `AuthController`, `AddWordController`, `SearchFieldController`) and initializes their services.
  - Configures `FirebaseAnalytics`, `FirebaseCrashlytics`, `FirebaseMessaging`, and local notifications.
  - Wraps the app in a `ProviderScope` (Riverpod) and an `AppStateWidget` (custom InheritedWidget wrapper).
  - Builds `MaterialApp` with Material 3 themes, dynamic color based on `VocabThemeController`, and routes for notifications, privacy policy, bug reporting, settings, and "What’s New".

### State management and controllers

State is handled by a mix of Riverpod providers and imperative controllers:
- Riverpod providers are declared in `lib/main.dart`:
  - `userNotifierProvider` – current `UserModel`, shared across the app.
  - `appProvider` (`AppNotifier`/`AppController`) – app-level UI state (bottom nav index, FAB visibility, update banners, version info).
  - `appThemeProvider` – wraps `VocabThemeNotifier`/`VocabThemeController` for theming.
  - `collectionNotifier` – `CollectionsNotifier` using `ChangeNotifier` to manage custom word collections.
  - `sharedPreferencesProvider`, `themeUtilityProvider`, `appUtilityProvider` – utilities built around `SharedPreferences`.
- Global controllers (instantiated in `main`) live under `lib/controller/` and orchestrate feature-specific logic:
  - `DashboardController` – word-of-the-day selection, word lists, dashboard data.
  - `ExploreController` – explore page paging/scroll animation behavior.
  - `SettingsController` – theme, rating prompts, and user settings.
  - `AuthController` – auth state, login/logout, local user caching.
  - `AddWordController` – add-word form state, drafts, word submission.
  - `SearchFieldController` – search page text field and behavior.

`lib/services/appstate.dart` defines `AppState`, `AppStateScope`, and `AppStateWidget` for a small slice of global state (e.g., word of the day, settings controller) propagated via an `InheritedWidget`.

### Navigation and layout

- `lib/base_home.dart` implements the adaptive home layout and bottom navigation using `navbar_router`:
  - Defines an `AdaptiveLayout` `ConsumerStatefulWidget` that:
    - Checks for app updates via `FirebaseRemoteConfig` and shows update banners or "What’s New" via `WhatsNew` widget.
    - Prompts users to rate the app on Play Store after a configurable interval.
    - Shows a persistent bottom FAB for adding a word when appropriate.
  - Uses `NavbarRouter` with a destination map:
    - Tab 0 – `Dashboard` + `Notifications`
    - Tab 1 – `Search`, `AddWord`, `SearchView`
    - Tab 2 – `ExploreWords` (with a callback to prompt sign-in on scroll)
    - Tab 3 – `UserProfileNavigator` and `EditProfile` (only when the user is logged in)
  - Handles double-back-to-exit behavior on Android and scroll animations for the explore page.

There are separate mobile and desktop dashboard implementations (`DashboardMobile`, `DashboardDesktop`) selected via `ResponsiveBuilder`.

### Feature modules and UI structure

`lib/` is organized by cross-cutting concerns and feature areas:

- `navbar/` – Top-level sections reachable from the bottom navigation:
  - `dashboard/` – dashboard UI, word-of-the-day card (`WoDCard`), collections summary, bookmarks/mastered words cards.
  - `search/` – search screens listing and search bar UI.
  - `explore/` – explore flow with paginated word browsing and hands-free mode.
  - `profile/` – profile, settings, about page, bug reporting, licenses, and embedded web views.

- `pages/` – Standalone screens not directly tied to a nav section root:
  - `splashscreen.dart` – initial app screen, likely routing into `AdaptiveLayout`.
  - `login.dart` – sign-in flow (Google Sign-In, etc.).
  - `addword.dart` – add/edit word form.
  - `collections/` – manage and display custom word collections (including demo data and new collection flows).
  - `drafts.dart` – manage saved-but-unpublished words.
  - `notifications/` – notifications list, edit detail views, etc.

- `widgets/` – Reusable UI pieces used across multiple screens (word list tiles, word detail view, responsive layout helpers, custom buttons, swipe-up prompts, search widgets, etc.).

- `onboarding/` – Onboarding and welcome experience (`WelcomePage`, `OnboardingPage`, etc.), used extensively in integration tests.

- `themes/` – Theme management (`VocabTheme`, `VocabThemeController`, helpers for color schemes and theme selection).

- `constants/` – App-wide constants (`Constants`, UI strings, style helpers and mappings from enums to colors/icons).

- `models/` – Core domain models and their JSON-serializable counterparts:
  - `word.dart`, `user.dart`, `history.dart`, `collection.dart`, `notification.dart`, `report.dart`, `request.dart`, `version.dart` with generated `*.g.dart` files using `json_serializable`.

- `services/` – Data and side-effect layer:
  - `services.dart` library exports `main.dart` (for controllers) and individual service files under `services/services/`.
  - Service files wrap interactions with Supabase and external APIs for:
    - Authentication (`auth_service.dart`)
    - Dashboard/word-of-the-day (`dashboard_service.dart`)
    - Edit history (`edit_history.dart`)
    - Explore pagination (`explore_service.dart`)
    - Push notifications and FCM topic management (`pushnotification_service.dart`)
    - User data (`user.dart` service)
    - Vocab storage and retrieval (`vocabstore.dart`)
    - Settings, collections, and word state (`settings_service.dart`, `collections_service.dart`, `word_state_service.dart`)

- `utils/` – Utility functions and extensions:
  - `logger.dart` – logging helpers.
  - `extensions.dart` – UI and layout helpers (padding, spacers, etc.).
  - `size_utils.dart` – device size and breakpoint utilities.
  - `app_utils.dart`, `utility.dart`, `wordlist.dart` – various helpers around navigation, toasts, word lists, and more.

- `platform/` – Platform-specific helpers (currently stubbed `fileSaver` implementations for mobile and web that throw on unsupported operations).

### Testing architecture

- `test/widget_test.dart` – basic `VocabApp` smoke test (`pumpWidget(VocabApp())`, verify simple counter behavior). This is a template test and does not hit backend services.
- `integration_test/app_test.dart` – end-to-end flows exercising real app logic against configured backend services:
  - User onboarding (skip/take tour)
  - Sign-in flow via Google Sign-In UI
  - Persistence of logged-in state
  - Navigation between dashboard/search/explore/profile tabs
  - Drafts behavior for unfinished add-word flows
  - Successfully adding a word and then rejecting it from notifications
  - Creating and pinning collections, and adding words to them

The integration tests rely on full backend configuration and non-mocked Supabase/Firebase, so expect them to require correct Dart defines and seeded data.

## Notes for future Warp instances

- When modifying or adding commands, prefer using environment-based Dart defines (as in the GitHub workflows) instead of inlining secrets.
- For backend-related changes, cross-check both `Contributing.md` and the Supabase SQL in that file to ensure schema changes, seed data, and app code stay in sync.
- For significant feature work, identify the relevant controller in `lib/controller/` and the corresponding service(s) in `lib/services/services/` before editing UI widgets; most business rules live there rather than directly in the widgets.
