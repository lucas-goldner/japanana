# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Japanana is a Flutter application for learning Japanese grammar through interactive review sessions. The app supports multiple languages (English, German, Japanese) and uses a flashcard-style review system with animations and progress tracking.

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
- **l10n/**: Localization files (app_en.arb, app_de.arb, app_ja.arb)
- **router.dart**: Navigation configuration using go_router

### Feature Modules (`lib/features/`)
Each feature follows the same structure:
- **domain/**: Feature-specific models and business logic
- **data/**: Feature-specific data handling
- **presentation/**: UI screens and widgets

Key features:
- **in_review/**: Main review screen with card animations and chat-style interface
- **review_setup/**: Configuration screen for review options
- **lecture_list/**: Display and management of grammar lectures
- **statistics/**: User progress tracking with mistake analytics

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
- Scribble-style UI elements for playful learning experience

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
- Test data fixtures in JSON format

### Statistics and Mistake Tracking
The app includes a comprehensive mistake tracking system:
- **Mistake Model** (`core/domain/mistake.dart`): Stores lecture ID, mistake count, and timestamp
- **Statistics Provider** (`core/application/statistics_provider.dart`): 
  - `mistakenLecturesProvider`: Manages mistakes with SharedPreferences persistence
  - `statisticsProvider`: Provides sorted mistake data for UI consumption
- **Automatic Tracking**: Wrong usage selections in review sessions are automatically tracked
- **Statistics Screen**: Displays mistakes sorted by recency with color-coded frequency indicators
- **Navigation**: Stats button in review selection navigates to `/statistics` route