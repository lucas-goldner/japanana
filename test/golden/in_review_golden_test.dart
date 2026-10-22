import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/in_review/domain/review_question.dart';
import 'package:japanana/features/in_review/domain/session_recap.dart';
import 'package:japanana/features/in_review/presentation/in_review.dart';
import 'package:japanana/features/in_review/presentation/recap/recap_frame.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';

import 'golden_fixtures.dart';
import 'golden_utils.dart';

const _kOptions = ReviewSetupOptions(
  randomize: false,
  repeatOnFalseCard: false,
);

/// Time for the intro message, the question and its answers to animate in.
const _kQuestionDuration = Duration(seconds: 3);
const _kMessageDuration = Duration(seconds: 2);

final _n4 = goldenLectures.where((l) => l.types.contains(LectureType.n4));

Future<void> _pumpInReview(
  WidgetTester tester,
  ThemeData theme, {
  LectureType type = LectureType.n4,
  List<QuestionMode> modes = const [QuestionMode.choose],
  int breakEvery = kBreakEvery,
  Map<String, Object> preferences = const {},
  List<Lecture>? lectures,
}) async {
  await pumpGoldenScreen(
    tester,
    lectures: lectures,
    screen: InReview(
      (type, _kOptions),
      modeSequence: modes,
      breakEvery: breakEvery,
    ),
    theme: theme,
    preferences: preferences,
  );
  await pumpFor(tester, _kQuestionDuration);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  final rect = tester.getRect(finder);
  if (rect.top < 120 || rect.bottom > kGoldenScreenSize.height - 40) {
    await tester.ensureVisible(finder);
    await tester.pump();
  }
  await tester.tap(finder);
}

/// A wrong usage offered for [lecture].
Finder _wrongOption(Lecture lecture) => find
    .byWidgetPredicate(
      (widget) =>
          widget is Text &&
          !lecture.usages.contains(widget.data) &&
          goldenLectures.any((l) => l.usages.contains(widget.data)),
    )
    .last;

/// Answers a choose question right and guesses every example.
Future<void> _completeChoose(WidgetTester tester, Lecture lecture) async {
  await _tap(tester, find.text(lecture.usages.first).last);
  await pumpFor(tester, _kMessageDuration);
  for (var i = 0; i < lecture.examples.length; i++) {
    await _tap(tester, find.text('TRY TO GUESS'));
    await pumpFor(tester, _kMessageDuration);
  }
  await pumpFor(tester, _kQuestionDuration);
}

Future<void> _expect(WidgetTester tester, String name, String themeName) =>
    expectScreenGolden(
      tester,
      screen: 'in_review',
      name: name,
      themeName: themeName,
    );

void main() {
  setUpGoldens();

  final first = _n4.first;

  goldenTest('In review pick one', (tester, theme, themeName) async {
    await _pumpInReview(tester, theme);
    await _expect(tester, 'usage', themeName);
  });

  goldenTest('In review wrong answer', (tester, theme, themeName) async {
    await _pumpInReview(tester, theme);
    await _tap(tester, _wrongOption(first));
    await pumpFor(tester, const Duration(milliseconds: 500));
    await _expect(tester, 'wrong_answer', themeName);
  });

  goldenTest('In review examples', (tester, theme, themeName) async {
    await _pumpInReview(tester, theme);
    await _tap(tester, _wrongOption(first));
    await pumpFor(tester, const Duration(milliseconds: 300));
    await _tap(tester, find.text(first.usages.first).last);
    await pumpFor(tester, _kMessageDuration);
    await _expect(tester, 'examples', themeName);
  });

  goldenTest('In review next lecture', (tester, theme, themeName) async {
    await _pumpInReview(tester, theme);
    await _completeChoose(tester, first);
    await _expect(tester, 'next_lecture', themeName);
  });

  goldenTest('In review swipe', (tester, theme, themeName) async {
    await _pumpInReview(tester, theme, modes: [QuestionMode.swipe]);
    await _expect(tester, 'swipe', themeName);
    await _tap(tester, find.bySemanticsLabel('Fits'));
    await pumpFor(tester, _kMessageDuration);
    await _expect(tester, 'swipe_answered', themeName);
  });

  goldenTest('In review fill the gap', (tester, theme, themeName) async {
    await _pumpInReview(tester, theme, modes: [QuestionMode.gap]);
    await _expect(tester, 'gap', themeName);
    await _tap(tester, find.text('んです').last);
    await pumpFor(tester, _kMessageDuration);
    await _expect(tester, 'gap_solved', themeName);
  });

  goldenTest('In review meaning', (tester, theme, themeName) async {
    await _pumpInReview(tester, theme, modes: [QuestionMode.meaning]);
    await _expect(tester, 'meaning', themeName);
  });

  goldenTest('In review mixed-up pair', (tester, theme, themeName) async {
    await _pumpInReview(
      tester,
      theme,
      modes: [QuestionMode.pairs],
      preferences: goldenStudyLogPreferences(),
    );
    await _expect(tester, 'pairs', themeName);
    await _tap(tester, find.text(goldenLectures[1].title).last);
    await pumpFor(tester, _kMessageDuration);
    await _expect(tester, 'pairs_answered', themeName);
  });

  goldenTest('In review memory break', (tester, theme, themeName) async {
    // Every fixture lecture as N4, so lectures are left after the break.
    final deck = [
      for (final lecture in goldenLectures)
        lecture.copyWith(types: [LectureType.n4]),
    ];
    await _pumpInReview(tester, theme, breakEvery: 3, lectures: deck);
    for (final lecture in deck.take(3)) {
      await _completeChoose(tester, lecture);
    }
    await _expect(tester, 'memory', themeName);
  });

  goldenTest('In review lightning round', (tester, theme, themeName) async {
    await _pumpInReview(tester, theme, breakEvery: 1);
    for (final lecture in _n4.take(2)) {
      await _completeChoose(tester, lecture);
    }
    await _expect(tester, 'lightning', themeName);
    await _tap(tester, find.text('START'));
    await pumpFor(tester, const Duration(milliseconds: 600));
    await _tap(tester, find.bySemanticsLabel('Fits'));
    await pumpFor(tester, const Duration(seconds: 2));
    await _expect(tester, 'lightning_running', themeName);
    await pumpFor(tester, const Duration(seconds: 30));
  });

  goldenTest('In review finished', (tester, theme, themeName) async {
    final lecture = goldenLectures.firstWhere(
      (l) => l.types.contains(LectureType.conversational),
    );
    await _pumpInReview(tester, theme, type: LectureType.conversational);
    await _tap(tester, _wrongOption(lecture));
    await pumpFor(tester, const Duration(milliseconds: 300));
    await _completeChoose(tester, lecture);
    await _expect(tester, 'finished', themeName);

    // Scrolling back up snaps to the question and names it for a moment.
    await tester.drag(find.byType(CustomScrollView), const Offset(0, 300));
    await pumpFor(tester, const Duration(milliseconds: 800));
    await _expect(tester, 'scrolled_back', themeName);
    await pumpFor(tester, const Duration(seconds: 3));
  });

  goldenTest('Session recap frames', (tester, theme, themeName) async {
    final recap = SessionRecap(
      book: LectureType.n4,
      date: goldenNow,
      cards: 12,
      firstTryRight: 10,
      bestCombo: 7,
      learned: _n4.toList(),
      missed: [goldenLectures[1]],
    );
    await pumpGoldenScreen(
      tester,
      theme: theme,
      screen: Scaffold(
        body: Center(
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final progress in [0.12, 0.36, 0.56, 0.95])
                SizedBox(
                  width: kRecapSize.width * 0.48,
                  height: kRecapSize.height * 0.48,
                  child: FittedBox(
                    child: RecapFrame(recap: recap, progress: progress),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await expectScreenGolden(
      tester,
      screen: 'in_review',
      name: 'recap_frames',
      themeName: themeName,
    );
  });
}
