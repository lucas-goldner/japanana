import 'package:japanana/features/statistics/presentation/statistics.dart';

import 'golden_fixtures.dart';
import 'golden_utils.dart';

void main() {
  setUpGoldens();

  goldenTest('Statistics without mistakes', (tester, theme, themeName) async {
    await pumpGoldenScreen(tester, screen: const Statistics(), theme: theme);
    await pumpFor(tester, const Duration(seconds: 1));

    await expectScreenGolden(
      tester,
      screen: 'statistics',
      name: 'empty',
      themeName: themeName,
    );
  });

  goldenTest('Statistics with mistakes', (tester, theme, themeName) async {
    await pumpGoldenScreen(
      tester,
      screen: const Statistics(),
      theme: theme,
      preferences: goldenMistakePreferences(),
    );
    await pumpFor(tester, const Duration(seconds: 1));

    await expectScreenGolden(
      tester,
      screen: 'statistics',
      name: 'mistakes',
      themeName: themeName,
    );
  });
}
