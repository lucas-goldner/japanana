import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/core/application/shared_preferences_provider.dart';
import 'package:japanana/core/data/shared_preferences_repository_impl.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/onboarding/application/onboarding_provider.dart';
import 'package:japanana/features/onboarding/presentation/onboarding_screen.dart';
import 'package:japanana/features/review_selection/presentation/review_selection.dart';
import 'package:japanana/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pumps the app with the same provider setup and start screen as main().
Future<void> _pumpApp(WidgetTester tester, Map<String, Object> values) async {
  SharedPreferences.setMockInitialValues(values);
  final preferences = await SharedPreferences.getInstance();

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(preferences),
        sharedPreferencesProvider.overrideWithValue(
          SharedPreferencesRepositoryImpl(preferences),
        ),
      ],
      child: JapananaApp(
        router: createRouter(
          initialLocation: shouldShowOnboarding(preferences)
              ? AppRoutes.onboarding.path
              : null,
        ),
      ),
    ),
  );
  // Let the intro animations and their delayed callbacks finish.
  for (var i = 0; i < 140; i++) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  testWidgets('app starts on the review selection screen', (tester) async {
    await _pumpApp(tester, {
      'settings_theme_mode': 'dark',
      onboardingCompletedKey: true,
    });

    expect(tester.takeException(), isNull);
    expect(find.byType(ReviewSelection), findsOneWidget);
  });

  testWidgets('a fresh install starts with the onboarding', (tester) async {
    await _pumpApp(tester, {});

    expect(tester.takeException(), isNull);
    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}
