# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Japanana is a Flutter application for learning Japanese grammar through interactive review sessions. The app supports English and Japanese and uses a flashcard-style review system with animations and progress tracking.

## Common Development Commands

### Running the Application
```bash
# Get dependencies and submodules
git submodule update --init --recursive
flutter pub get

# Run the app
flutter run

# Run with specific device
flutter run -d 'iPhone 15'
```

### Testing
```bash
# Run unit tests
flutter test

# Regenerate golden screenshots (light and dark) after intended UI changes
flutter test test/golden --update-goldens

# Run integration tests with Patrol
patrol test -t integration_test/patrol -d 'iPhone 15'

# Run integration tests without uninstalling
patrol test -t integration_test/patrol -d 'iPhone 15' --no-uninstall
```

### Code Generation and Building
```bash
# Generate localization files
flutter gen-l10n

# Run build runner for code generation
flutter pub run build_runner build --delete-conflicting-outputs

# Build for release
flutter build apk    # Android
flutter build ios    # iOS  
flutter build macos  # macOS
flutter build web    # Web
```

### Code Quality
```bash
# Run linting
flutter analyze

# Format code
flutter format .
```

## Architecture Overview

The project follows Clean Architecture with clear separation of concerns:

### Core Module (`lib/core/`)
- **application/**: State management with Riverpod providers
- **data/**: Repository implementations and data sources
- **domain/**: Domain models (Lecture, LectureType) and repository interfaces
- **presentation/**: Shared UI components, themes, and styling
- **l10n/**: Localization files (app_en.arb, app_ja.arb)
- **router.dart**: Navigation configuration using go_router

### Feature Modules (`lib/features/`)
Each feature follows the same structure:
- **domain/**: Feature-specific models and business logic
- **data/**: Feature-specific data handling
- **presentation/**: UI screens and widgets

Key features:
- **in_review/**: Main review screen: one scrolling chat with mixed question types, game breaks and a shareable recap
- **review_setup/**: Configuration screen for review options
- **lecture_list/**: Display and management of grammar lectures
- **statistics/**: User progress tracking with mistake analytics
- **onboarding/**: First launch flow that sells the app and builds a personal plan

### State Management Pattern
The app uses Riverpod with Flutter Hooks for state management:
- Providers are defined in `application/` directories
- UI components use `HookConsumerWidget` for reactive state
- Local UI state managed with hooks (useState, useEffect, useAnimationController)

### Navigation
- Uses go_router for declarative routing
- Routes defined in `core/router.dart`
- Navigation keys in `core/keys.dart`

### Styling and Theming
- Custom theme defined in `core/presentation/style/japanana_theme.dart`
- Material 3 design system
- Custom animations including page curl effects
- Neubrutalism style: thick outlines, flat fills and hard offset shadows on graph paper backgrounds
  - Tokens live in the `NeoTheme` extension (`core/presentation/style/neo_theme.dart`, `context.neo`); use `context.neo.decoration()` for outlined cards and `NeoButton` (`core/presentation/widgets/neo_button.dart`) for buttons
  - Avoid hardcoded colors so both themes stay correct
- Light and dark ("midnight notebook") themes; the app follows the system setting

## Important Technical Details

### Localization
- Always use `context.l10n` for user-facing strings
- Extract context-dependent strings before async operations to avoid BuildContext issues
- Run `flutter gen-l10n` after modifying .arb files

### Animation Constants
Animation timings are defined as constants at the top of widget files:
```dart
const _kButtonAnimationDuration = Duration(milliseconds: 900);
const _kButtonAnimationDelay = 0.2;
const _kButtonSlideDistance = 80.0;
```

### Japanese Text Handling
- Uses kana_kit package for Japanese text processing
- Font family switching based on content (NotoSansJP for Japanese)

### Testing Approach
- Unit tests for business logic and providers
- Integration tests using Patrol for user flows
- Golden tests in `test/golden/` render every screen in light and dark mode with fixture data (`golden_fixtures.dart`); rendered on Linux to match GitHub Actions. Linux compares them exactly; on macOS (local runs and Codemagic) `test/golden/flutter_test_config.dart` allows up to 4% differing pixels because macOS anti-aliases text differently. Regenerate goldens on Linux only
- Test data fixtures in JSON format

### Settings
Each item on the settings canvas (`features/settings/`) opens a sheet or an external action:
- **Language** (System / English / 日本語) and **Theme** (System / Light / Dark): `appSettingsProvider`, persisted in SharedPreferences and applied in `main.dart`
- **App Icon** (iOS only, hidden elsewhere): the default icon is Nana "Sparkle"; the alternates (`AppIcon` in `settings/domain/app_icon.dart`) are icon sets `AppIcon-<Name>.appiconset` in `ios/Runner/Assets.xcassets`, listed in `ASSETCATALOG_COMPILER_ALTERNATE_APPICON_NAMES` in the Xcode project, and switched through `AppIconService` (method channel `japanana/app_icon`, `AppIconSwitcher` in `AppDelegate.swift`); previews live in `assets/images/app_icons/`. To add an icon: add the icon set, its name to that build setting, an `AppIcon` value and a preview
- **Notifications** and **Daily Reminder**: local notifications through `ReminderService` (flutter_local_notifications)
- **Reset Progress** and **Export & Sync**: `ProgressController` + `ProgressBackup` (JSON backup file on every platform, iCloud on iOS/macOS via icloud_storage_plus)
- **Subscription** (supporter badge) and **Donation** (tips): RevenueCat via `PurchasesService` and `storeProvider`
- **Send Feedback**, **Rate the App** and the link items: `ExternalActions` (url_launcher, in_app_review)
- **See Changelog**: `assets/changelog/changelog.json` with English and Japanese entries; add an entry for every release
- Platform services sit behind providers so tests override them with the fakes in `test/golden/golden_fakes.dart`
- `SharedPreferences` is loaded in `main()` and provided at the root `ProviderScope` (`preferencesProvider`); don't add nested scopes with overrides, providers without declared dependencies can't see them
- Links, the support email, the App Store id and the iCloud container live in `core/app_config.dart` (placeholders marked TODO)
- RevenueCat keys are passed at build time: `--dart-define=REVENUECAT_APPLE_API_KEY=... --dart-define=REVENUECAT_GOOGLE_API_KEY=...`; without them the store sheets show "store unavailable"

### Onboarding
Every user starts on `/onboarding` once (`features/onboarding/`), existing learners included; `main()` picks the start route with `shouldShowOnboarding(prefs)`, which is false once `onboarding_completed` is set:
- **Steps** (`OnboardingStep` in `onboarding_screen.dart`, widgets in `presentation/steps/`): hook, goal, level, years, speaking gap, pain cards, the math, fixes, comparison, sample reviews (native rating prompt), daily minutes, reminder (sets the 20:30 reminder), plan building, a real first conversation, snapshot stamp (share), plan date and the supporter paywall (always dismissable, falls back to "Continue" when the store is unavailable)
- **Answers** (`OnboardingAnswers`, `onboardingProvider`) persist as JSON under `onboarding_answers`; `LearningPlan` estimates months alone vs with daily practice from the lecture counts (`learningPlanProvider`)
- The demo step records its answers in the study log and mistakes like a review
- **Motion** (`presentation/widgets/motion.dart`): `Reveal`, `BlurWords`, `RollingNumber`, `Float`, `Pulse`, `useDelayedProgress`; keep blur wrappers in the tree (`ImageFiltered(enabled:)`) so finishing an animation doesn't remount children
- Each step paints its own tinted graph paper (`StepTint`); the reminder step is always night themed. The approved motion prototype was the reference for timings and copy
- Golden tests start at any step with `OnboardingScreen(initialStep: ...)`

### Review Session
The review (`features/in_review/`) is one scrolling history; every lecture and game is a section that stays on screen, so mistakes can be read again at the end:
- **Question types** (`QuestionMode`, built by `QuestionBuilder` in `domain/question_builder.dart`): pick one of four (the classic), swipe whether a usage fits, fill the gap (grammar cut out of an example; needs the title's Japanese in the sentence), what does it mean (pick the translation) and which one is it (two lectures the learner mixed up, from the study log's `pickedLectureId`). Unseen lectures only get pick one or meaning; mixed-up lectures get pairs; the same type never repeats twice in a row. Gap and pairs hide the title until answered
- After the question the lecture's examples follow as before (try to guess, translations, extras), skipping the example the question already used
- **Breaks** every `kBreakEvery` (10) lectures alternate a memory game (title ↔ usage pairs from the last cards) and a 30 second lightning round (best score in `lightning_best_score`)
- **Scrolling**: new sections scroll to just below the app bar; when the user stops scrolling it snaps to a section start nearby and briefly shows a small topic label; a combo meter (right first tries in a row) sits in the app bar
- **Summary** at the end: cards, first-try %, best combo, missed lectures (tap to jump back) and **Share my recap**
- **Recap video** (`presentation/recap/`): `RecapFrame` is a pure function of progress; `RecapShareScreen` renders 240 frames at 720×1280 and encodes them through `RecapVideoEncoder` (method channel `japanana/recap_video`, AVFoundation code in `ios/Runner/AppDelegate.swift` and `macos/Runner/MainFlutterWindow.swift`, kept there so the Xcode project needs no new files). Other platforms share a PNG of the stats frame
- Golden tests force question types with `InReview(..., modeSequence:, breakEvery:)`

### Statistics and Mistake Tracking
The statistics screen (`features/statistics/`) is a dashboard built from a local study log:
- **Study log** (`statistics/application/study_log_provider.dart`): every usage pick (`AnswerRecord`: lecture, right or wrong, first try or not, which lecture's usage was picked instead) and every review session (`SessionRecord`) is recorded by the review screen and stored in SharedPreferences (`study_answers`, `study_sessions`); included in backups and reset
- **Calculator** (`statistics/domain/study_stats_calculator.dart`): pure function turning the log, lectures and mistakes into `StudyStats` (streaks, first-try accuracy, minutes studied, mastery per book, weekly accuracy, weak lectures, mixed-up pairs); a lecture counts as mastered after 3 right first tries in a row
- **Dashboard** (`statistics_dashboard.dart`, charts in `widgets/neo_charts.dart`): streak, big numbers, activity heatmap, cards per day (7/30 days), mastery by book, accuracy by week, then weak spots with the recent mistakes preview; every chart has a "not enough data yet" state
- **Mistakes** (`core/domain/mistake.dart`, `mistakenLecturesProvider`): still tracked per lecture; they feed the recent mistakes list (`RecentMistakesScreen`, opened from "See all") and the Recent Mistakes review started by "Review weak spots"
- Time comes from `clockProvider` so goldens use a fixed date (`goldenNow` in `golden_fixtures.dart`, with a generated study log in `goldenStudyLogPreferences`)
- **Navigation**: Stats button in review selection navigates to `/statistics` route
