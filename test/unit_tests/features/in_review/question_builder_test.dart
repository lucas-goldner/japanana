import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/in_review/domain/question_builder.dart';
import 'package:japanana/features/in_review/domain/review_question.dart';
import 'package:japanana/features/statistics/domain/study_records.dart';

import '../../../golden/golden_fixtures.dart';

void main() {
  final n4 = goldenLectures
      .where((l) => l.types.contains(LectureType.n4))
      .toList();
  QuestionBuilder builder({
    Set<String> seen = const {},
    Map<String, String> partners = const {},
  }) => QuestionBuilder(
    deck: n4,
    allLectures: goldenLectures,
    random: Random(1),
    seenLectureIds: seen,
    partners: partners,
  );

  test('gap fragments are the Japanese parts of a title', () {
    expect(gapFragments(goldenLectures[0]), ['んです']);
    expect(gapFragments(goldenLectures[1]), ['ていただけませんか']);
  });

  test('mixed-up partners are the most often picked wrong lecture', () {
    AnswerRecord wrong(String picked) => AnswerRecord(
      time: DateTime(2026),
      lectureId: 'n4-1',
      correct: false,
      firstAttempt: true,
      pickedLectureId: picked,
    );
    expect(mixedUpPartners([wrong('n4-2'), wrong('n4-3'), wrong('n4-2')]), {
      'n4-1': 'n4-2',
    });
  });

  test('every mode builds a question with the right answer in it', () {
    final lecture = n4.first;
    for (final mode in QuestionMode.values) {
      final question = builder(partners: {'n4-1': 'n4-2'})
          .build(lecture, forced: mode);
      expect(question.mode, mode);
      switch (mode) {
        case QuestionMode.choose:
          expect(question.choose!.options, contains(lecture.usages.first));
          expect(question.choose!.options.toSet(), hasLength(4));
        case QuestionMode.swipe:
          expect(question.swipe!.usage, isNotEmpty);
        case QuestionMode.gap:
          final gap = question.gap!;
          expect(
            '${gap.before}${gap.answer}${gap.after}',
            lecture.examples[gap.exampleIndex],
          );
          expect(gap.options, contains(gap.answer));
        case QuestionMode.meaning:
          final meaning = question.meaning!;
          expect(
            meaning.options[meaning.correctIndex],
            lecture.translations[meaning.exampleIndex],
          );
        case QuestionMode.pairs:
          expect(question.pairs!.other.id, 'n4-2');
      }
    }
  });

  test('a mode without the data it needs falls back to choose', () {
    final noExamples = n4.first.copyWith(examples: [], translations: []);
    final question = builder().build(noExamples, forced: QuestionMode.gap);
    expect(question.mode, QuestionMode.choose);
  });

  test('mixed-up lectures are asked as pairs', () {
    final question = builder(partners: {'n4-1': 'n4-2'}).build(n4.first);
    expect(question.mode, QuestionMode.pairs);
  });

  test('unseen lectures are never swiped or gap filled', () {
    for (var i = 0; i < 20; i++) {
      final mode = QuestionBuilder(
        deck: n4,
        allLectures: goldenLectures,
        random: Random(i),
      ).build(n4.first).mode;
      expect(mode, isNot(anyOf(QuestionMode.swipe, QuestionMode.gap)));
    }
  });

  test('memory cards pair each title with its usage', () {
    final cards = builder().memoryCards(n4)!;
    expect(cards, hasLength(6));
    for (final lecture in n4) {
      final pair = cards.where((c) => c.pairId == lecture.id).toList();
      expect(pair.map((c) => c.text), [
        if (pair.first.isTitle) ...[
          lecture.title,
          lecture.usages.first,
        ] else ...[
          lecture.usages.first,
          lecture.title,
        ],
      ]);
    }
    expect(builder().memoryCards(n4.take(2).toList()), isNull);
  });

  test('lightning statements say whether a usage fits', () {
    for (final statement in builder().lightningStatements(n4)) {
      final lecture = n4.firstWhere((l) => l.title == statement.title);
      expect(lecture.usages.contains(statement.usage), statement.fits);
    }
  });
}
