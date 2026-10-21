@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/review_setup/presentation/review_setup.dart';

import 'golden_fixtures.dart';
import 'golden_utils.dart';

void main() {
  setUpGoldens();

  goldenTest('Review setup', (tester, theme, themeName) async {
    await pumpGoldenScreen(
      tester,
      screen: const ReviewSetup(LectureType.n4),
      theme: theme,
    );
    await pumpFor(tester, const Duration(milliseconds: 500));

    await expectScreenGolden(
      tester,
      screen: 'review_setup',
      name: 'default',
      themeName: themeName,
    );
  });

  goldenTest(
    'Review setup with options and a running session',
    (tester, theme, themeName) async {
      await pumpGoldenScreen(
        tester,
        screen: const ReviewSetup(LectureType.n4),
        theme: theme,
        preferences: goldenSessionPreferences(LectureType.n4),
      );
      await pumpFor(tester, const Duration(milliseconds: 500));

      await tester.tap(find.byType(Checkbox).first);
      await pumpFor(tester, const Duration(milliseconds: 500));

      await expectScreenGolden(
        tester,
        screen: 'review_setup',
        name: 'session',
        themeName: themeName,
      );
    },
  );
}
