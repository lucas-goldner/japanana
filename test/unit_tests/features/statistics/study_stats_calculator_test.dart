import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/domain/mistake.dart';
import 'package:japanana/features/statistics/domain/study_records.dart';
import 'package:japanana/features/statistics/domain/study_stats_calculator.dart';

final _now = DateTime(2026, 10, 20, 12);

Lecture _lecture(String id, List<LectureType> types) => Lecture(
      id: id,
      title: 'title $id',
      usages: ['usage $id'],
      examples: const [],
      translations: const [],
      types: types,
    );

final _lectures = [
  _lecture('a', [LectureType.n4]),
  _lecture('b', [LectureType.n4]),
  _lecture('c', [LectureType.n3]),
];

AnswerRecord _answer(
  String id, {
  required int daysAgo,
  bool correct = true,
  bool firstAttempt = true,
  String? picked,
}) =>
    AnswerRecord(
      time: _now.subtract(Duration(days: daysAgo)),
      lectureId: id,
      correct: correct,
      firstAttempt: firstAttempt,
      pickedLectureId: picked,
    );

void main() {
  test('empty log gives empty stats', () {
    final stats = calculateStudyStats(
      log: const StudyLog(),
      lectures: _lectures,
      mistakes: const [],
      now: _now,
    );

    expect(stats.hasActivity, isFalse);
    expect(stats.currentStreak, 0);
    expect(stats.firstTryAccuracy, isNull);
    expect(stats.cardsChangeThisWeek, isNull);
    expect(stats.days, hasLength(kStatsHistoryDays));
    expect(stats.weeklyAccuracy.nonNulls, isEmpty);
    expect(stats.decks.first.unseen, 2);
  });

  test('streak survives until the day after the last review', () {
    final stats = calculateStudyStats(
      log: StudyLog(
        answers: [
          for (final daysAgo in [10, 3, 2, 1]) _answer('a', daysAgo: daysAgo),
        ],
      ),
      lectures: _lectures,
      mistakes: const [],
      now: _now,
    );

    expect(stats.currentStreak, 3);
    expect(stats.longestStreak, 3);
  });

  test('a missed day breaks the streak', () {
    final stats = calculateStudyStats(
      log: StudyLog(answers: [_answer('a', daysAgo: 2)]),
      lectures: _lectures,
      mistakes: const [],
      now: _now,
    );

    expect(stats.currentStreak, 0);
    expect(stats.longestStreak, 1);
  });

  test('counts cards, first try accuracy and weekly change', () {
    final stats = calculateStudyStats(
      log: StudyLog(
        answers: [
          _answer('a', daysAgo: 8),
          _answer('a', daysAgo: 1, correct: false, picked: 'b'),
          _answer('a', daysAgo: 1, firstAttempt: false),
          _answer('b', daysAgo: 0),
          _answer('c', daysAgo: 0),
        ],
      ),
      lectures: _lectures,
      mistakes: const [],
      now: _now,
    );

    expect(stats.cardsReviewed, 4);
    expect(stats.firstTryAccuracy, 3 / 4);
    // 3 cards this week against 1 last week.
    expect(stats.cardsChangeThisWeek, 2);
    expect(stats.days.last.correct, 2);
    expect(stats.days[stats.days.length - 2].wrong, 1);
  });

  test('three right first tries in a row master a lecture', () {
    final stats = calculateStudyStats(
      log: StudyLog(
        answers: [
          _answer('a', daysAgo: 4, correct: false),
          for (final daysAgo in [3, 2, 1]) _answer('a', daysAgo: daysAgo),
          _answer('b', daysAgo: 1),
        ],
      ),
      lectures: _lectures,
      mistakes: const [],
      now: _now,
    );

    final n4 = stats.decks.firstWhere((deck) => deck.type == LectureType.n4);
    expect(stats.lecturesMastered, 1);
    expect((n4.mastered, n4.learning, n4.unseen), (1, 1, 0));
  });

  test('ranks weak lectures and confusion pairs', () {
    final stats = calculateStudyStats(
      log: StudyLog(
        answers: [
          for (var i = 0; i < 3; i++)
            _answer('a', daysAgo: i, correct: false, picked: 'b'),
          _answer('a', daysAgo: 0),
          _answer('c', daysAgo: 1, correct: false, picked: 'a'),
          _answer('c', daysAgo: 0),
          _answer('c', daysAgo: 0),
          _answer('c', daysAgo: 0),
        ],
      ),
      lectures: _lectures,
      mistakes: const [],
      now: _now,
    );

    expect(stats.weakLectures.map((l) => l.title), ['title a', 'title c']);
    expect(stats.weakLectures.first.errorRate, 3 / 4);
    expect(stats.confusionPairs.first.expected, 'title a');
    expect(stats.confusionPairs.first.picked, 'title b');
    expect(stats.confusionPairs.first.count, 3);
  });

  test('sessions are capped at an hour', () {
    final start = _now.subtract(const Duration(hours: 5));
    final stats = calculateStudyStats(
      log: StudyLog(
        sessions: [
          SessionRecord(
            start: start,
            end: start.add(const Duration(minutes: 12)),
            cardsCompleted: 5,
          ),
          SessionRecord(
            start: start,
            end: start.add(const Duration(hours: 3)),
            cardsCompleted: 2,
          ),
        ],
      ),
      lectures: _lectures,
      mistakes: const [],
      now: _now,
    );

    expect(stats.minutesStudied, 72);
  });

  test('recent mistakes skip lectures that no longer exist', () {
    final stats = calculateStudyStats(
      log: const StudyLog(),
      lectures: _lectures,
      mistakes: [
        Mistake(lectureId: 'gone', mistakeCount: 2, lastMistakeDate: _now),
        Mistake(
          lectureId: 'b',
          mistakeCount: 1,
          lastMistakeDate: _now.subtract(const Duration(hours: 2)),
        ),
      ],
      now: _now,
    );

    expect(stats.recentMistakes.map((m) => m.title), ['title b']);
  });
}
