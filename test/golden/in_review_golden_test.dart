import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/in_review/presentation/in_review.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';

import 'golden_fixtures.dart';
import 'golden_utils.dart';

const _kOptions = ReviewSetupOptions(
  randomize: false,
  repeatOnFalseCard: false,
);

/// Time for the intro message, the usage question and the answer buttons to
/// finish animating.
const _kUsageStageDuration = Duration(seconds: 4);
const _kMessageDuration = Duration(seconds: 2);

Future<void> _pumpInReview(
  WidgetTester tester,
  ThemeData theme, {
  LectureType type = LectureType.n4,
}) async {
  await pumpGoldenScreen(
    tester,
    screen: InReview((type, _kOptions)),
    theme: theme,
  );
  await pumpFor(tester, _kUsageStageDuration);
}

Future<void> _answerCorrectly(WidgetTester tester, Lecture lecture) async {
  await tester.tap(find.text(lecture.usages.first).first);
  await pumpFor(tester, _kMessageDuration);
}

Future<void> _guessAllTranslations(
  WidgetTester tester,
  Lecture lecture,
) async {
  for (var i = 0; i < lecture.examples.length; i++) {
    await tester.tap(find.text('Try to guess'));
    await pumpFor(tester, _kMessageDuration);
  }
}

void main() {
  setUpGoldens();

  final firstN4Lecture = goldenLectures.first;

  goldenTest('In review usage question', (tester, theme, themeName) async {
    await _pumpInReview(tester, theme);

    await expectScreenGolden(
      tester,
      screen: 'in_review',
      name: 'usage',
      themeName: themeName,
    );
  });

  goldenTest('In review wrong answer', (tester, theme, themeName) async {
    await _pumpInReview(tester, theme);

    await tester.tap(find.text(goldenLectures[1].usages.first).first);
    await pumpFor(tester, const Duration(milliseconds: 500));

    await expectScreenGolden(
      tester,
      screen: 'in_review',
      name: 'wrong_answer',
      themeName: themeName,
    );
  });

  goldenTest('In review examples', (tester, theme, themeName) async {
    await _pumpInReview(tester, theme);
    await _answerCorrectly(tester, firstN4Lecture);

    await expectScreenGolden(
      tester,
      screen: 'in_review',
      name: 'examples',
      themeName: themeName,
    );
  });

  goldenTest('In review next lecture', (tester, theme, themeName) async {
    await _pumpInReview(tester, theme);
    await _answerCorrectly(tester, firstN4Lecture);
    await _guessAllTranslations(tester, firstN4Lecture);
    await pumpFor(tester, _kUsageStageDuration);

    await expectScreenGolden(
      tester,
      screen: 'in_review',
      name: 'next_lecture',
      themeName: themeName,
    );
  });

  goldenTest('In review finished', (tester, theme, themeName) async {
    final lecture = goldenLectures
        .firstWhere((l) => l.types.contains(LectureType.conversational));
    await _pumpInReview(tester, theme, type: LectureType.conversational);
    await _answerCorrectly(tester, lecture);
    await _guessAllTranslations(tester, lecture);
    await pumpFor(tester, _kMessageDuration);

    await expectScreenGolden(
      tester,
      screen: 'in_review',
      name: 'finished',
      themeName: themeName,
    );
  });
}
