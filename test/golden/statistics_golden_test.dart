@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/features/statistics/presentation/recent_mistakes_screen.dart';
import 'package:japanana/features/statistics/presentation/statistics.dart';

import 'golden_fixtures.dart';
import 'golden_utils.dart';

void main() {
  setUpGoldens();

  final filledPreferences = {
    ...goldenMistakePreferences(),
    ...goldenStudyLogPreferences(),
  };

  goldenTest('Statistics without data', (tester, theme, themeName) async {
    await pumpGoldenScreen(tester, screen: const Statistics(), theme: theme);
    await pumpFor(tester, const Duration(seconds: 1));

    await expectScreenGolden(
      tester,
      screen: 'statistics',
      name: 'empty',
      themeName: themeName,
    );
  });

  goldenTest('Statistics dashboard', (tester, theme, themeName) async {
    await pumpGoldenScreen(
      tester,
      screen: const Statistics(),
      theme: theme,
      preferences: filledPreferences,
    );
    await pumpFor(tester, const Duration(seconds: 1));

    await expectScreenGolden(
      tester,
      screen: 'statistics',
      name: 'dashboard_top',
      themeName: themeName,
    );

    for (final section in ['middle', 'bottom', 'end']) {
      await tester.drag(find.byType(ListView), const Offset(0, -640));
      await pumpFor(tester, const Duration(milliseconds: 500));
      await expectScreenGolden(
        tester,
        screen: 'statistics',
        name: 'dashboard_$section',
        themeName: themeName,
      );
    }
  });

  goldenTest('Statistics dashboard in Japanese', (
    tester,
    theme,
    themeName,
  ) async {
    await pumpGoldenScreen(
      tester,
      screen: const Statistics(),
      theme: theme,
      locale: const Locale('ja'),
      preferences: filledPreferences,
    );
    await pumpFor(tester, const Duration(seconds: 1));

    await expectScreenGolden(
      tester,
      screen: 'statistics',
      name: 'dashboard_japanese',
      themeName: themeName,
    );
  });

  goldenTest('Recent mistakes', (tester, theme, themeName) async {
    await pumpGoldenScreen(
      tester,
      screen: const RecentMistakesScreen(),
      theme: theme,
      preferences: goldenMistakePreferences(),
    );
    await pumpFor(tester, const Duration(seconds: 1));

    await expectScreenGolden(
      tester,
      screen: 'statistics',
      name: 'recent_mistakes',
      themeName: themeName,
    );
  });
}
