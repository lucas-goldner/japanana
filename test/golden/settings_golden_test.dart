import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/features/settings/presentation/settings.dart';

import 'golden_utils.dart';

void main() {
  setUpGoldens();

  goldenTest('Settings', (tester, theme, themeName) async {
    await pumpGoldenScreen(tester, screen: const Settings(), theme: theme);
    await pumpFor(tester, const Duration(milliseconds: 500));

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'default',
      themeName: themeName,
    );
  });

  goldenTest('Settings sheet', (tester, theme, themeName) async {
    await pumpGoldenScreen(tester, screen: const Settings(), theme: theme);
    await pumpFor(tester, const Duration(milliseconds: 500));

    await tester.tap(find.text('Theme'), warnIfMissed: false);
    await pumpFor(tester, const Duration(seconds: 1));

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'sheet',
      themeName: themeName,
    );
  });
}
