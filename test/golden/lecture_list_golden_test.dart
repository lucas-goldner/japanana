import 'package:japanana/features/lecture_detail/presentation/lecture_detail.dart';
import 'package:japanana/features/lecture_list/presentation/lecture_list.dart';

import 'golden_fixtures.dart';
import 'golden_utils.dart';

void main() {
  setUpGoldens();

  goldenTest('Lecture list', (tester, theme, themeName) async {
    await pumpGoldenScreen(
      tester,
      screen: const LectureList(),
      theme: theme,
    );
    await pumpFor(tester, const Duration(milliseconds: 500));

    await expectScreenGolden(
      tester,
      screen: 'lecture_list',
      name: 'default',
      themeName: themeName,
    );
  });

  goldenTest('Lecture detail', (tester, theme, themeName) async {
    await pumpGoldenScreen(
      tester,
      screen: LectureDetail(goldenLectures.first),
      theme: theme,
    );
    await pumpFor(tester, const Duration(milliseconds: 500));

    await expectScreenGolden(
      tester,
      screen: 'lecture_detail',
      name: 'default',
      themeName: themeName,
    );
  });

  goldenTest('Lecture detail of remembered lecture', (
    tester,
    theme,
    themeName,
  ) async {
    await pumpGoldenScreen(
      tester,
      screen: LectureDetail(goldenLectures[3]),
      theme: theme,
      preferences: goldenMistakePreferences(),
    );
    await pumpFor(tester, const Duration(milliseconds: 500));

    await expectScreenGolden(
      tester,
      screen: 'lecture_detail',
      name: 'remembered',
      themeName: themeName,
    );
  });
}
