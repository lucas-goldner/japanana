import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/features/review_selection/presentation/review_selection.dart';

import 'golden_fixtures.dart';
import 'golden_utils.dart';

const _kIntroAnimationsDuration = Duration(seconds: 6);

void main() {
  setUpGoldens();

  goldenTest('Review selection', (tester, theme, themeName) async {
    await pumpGoldenScreen(
      tester,
      screen: const ReviewSelection(),
      theme: theme,
    );
    await pumpFor(tester, _kIntroAnimationsDuration);

    await expectScreenGolden(
      tester,
      screen: 'review_selection',
      name: 'default',
      themeName: themeName,
    );
  });

  goldenTest(
    'Review selection with remembered lectures and mistakes',
    (tester, theme, themeName) async {
      await pumpGoldenScreen(
        tester,
        screen: const ReviewSelection(),
        theme: theme,
        preferences: goldenMistakePreferences(),
      );
      await pumpFor(tester, _kIntroAnimationsDuration);

      await expectScreenGolden(
        tester,
        screen: 'review_selection',
        name: 'all_books',
        themeName: themeName,
      );
    },
  );

  goldenTest('Review selection with open book', (
    tester,
    theme,
    themeName,
  ) async {
    await pumpGoldenScreen(
      tester,
      screen: const ReviewSelection(),
      theme: theme,
    );
    await pumpFor(tester, _kIntroAnimationsDuration);

    const n3Spine = 'N\n3';
    await tester.tap(find.text(n3Spine), warnIfMissed: false);
    await pumpFor(tester, const Duration(seconds: 2));

    await expectScreenGolden(
      tester,
      screen: 'review_selection',
      name: 'open_book',
      themeName: themeName,
    );
  });
}
