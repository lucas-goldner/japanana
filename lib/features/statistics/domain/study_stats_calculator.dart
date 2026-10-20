import 'dart:math' as math;

import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/domain/mistake.dart';
import 'package:japanana/features/statistics/domain/study_records.dart';
import 'package:japanana/features/statistics/domain/study_stats.dart';

/// Days shown in the activity heatmap.
const kStatsHistoryDays = 16 * 7;

/// Weeks shown in the accuracy chart.
const kStatsAccuracyWeeks = 12;

/// Consecutive right first tries that count a lecture as mastered.
const _kMasteryStreak = 3;

/// Sessions longer than this count as this long, so a review left open
/// doesn't inflate the study time.
const _kMaxSessionMinutes = 60;

const _kWeakLectures = 4;
const _kSparklineAnswers = 8;
const _kConfusionPairs = 3;

/// Decks shown in the mastery chart.
const masteryDecks = [
  LectureType.n4,
  LectureType.n3,
  LectureType.n2,
  LectureType.writing,
  LectureType.conversational,
];

DateTime _day(DateTime time) => DateTime(time.year, time.month, time.day);

StudyStats calculateStudyStats({
  required StudyLog log,
  required List<Lecture> lectures,
  required List<Mistake> mistakes,
  required DateTime now,
}) {
  final today = _day(now);
  final lecturesById = {for (final lecture in lectures) lecture.id: lecture};
  final firstTries = [
    for (final answer in log.answers)
      if (answer.firstAttempt) answer,
  ];

  // Activity per day.
  final correctByDay = <DateTime, int>{};
  final wrongByDay = <DateTime, int>{};
  for (final answer in log.answers) {
    (answer.correct ? correctByDay : wrongByDay)
        .update(_day(answer.time), (count) => count + 1, ifAbsent: () => 1);
  }
  final days = [
    for (var offset = kStatsHistoryDays - 1; offset >= 0; offset--)
      () {
        final day = DateTime(today.year, today.month, today.day - offset);
        return DayActivity(
          day: day,
          correct: correctByDay[day] ?? 0,
          wrong: wrongByDay[day] ?? 0,
        );
      }(),
  ];

  // Streaks: the current one is kept alive until the end of the day after
  // the last review.
  final studiedDays = {...correctByDay.keys, ...wrongByDay.keys};
  var currentStreak = 0;
  var cursor = studiedDays.contains(today)
      ? today
      : DateTime(today.year, today.month, today.day - 1);
  while (studiedDays.contains(cursor)) {
    currentStreak++;
    cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
  }
  var longestStreak = 0;
  var run = 0;
  DateTime? previous;
  for (final day in studiedDays.toList()..sort()) {
    run = previous != null && day.difference(previous).inHours.abs() <= 25
        ? run + 1
        : 1;
    longestStreak = math.max(longestStreak, run);
    previous = day;
  }

  // Cards this week compared to last week.
  int correctBetween(int fromDaysAgo, int toDaysAgo) => [
        for (var offset = fromDaysAgo; offset < toDaysAgo; offset++)
          days[days.length - 1 - offset].correct,
      ].fold(0, (sum, count) => sum + count);
  final thisWeek = correctBetween(0, 7);
  final lastWeek = correctBetween(7, 14);

  // Mastery per lecture from its first tries.
  final firstTriesByLecture = <String, List<bool>>{};
  for (final answer in firstTries) {
    (firstTriesByLecture[answer.lectureId] ??= []).add(answer.correct);
  }
  bool isMastered(String id) {
    final results = firstTriesByLecture[id];
    return results != null &&
        results.length >= _kMasteryStreak &&
        results.sublist(results.length - _kMasteryStreak).every((ok) => ok);
  }

  final decks = [
    for (final type in masteryDecks)
      () {
        final deckLectures =
            lectures.where((lecture) => lecture.types.contains(type));
        final mastered = deckLectures.where((l) => isMastered(l.id)).length;
        final seen = deckLectures
            .where((l) => firstTriesByLecture.containsKey(l.id))
            .length;
        return DeckMastery(
          type: type,
          unseen: deckLectures.length - seen,
          learning: seen - mastered,
          mastered: mastered,
        );
      }(),
  ];

  // Accuracy per week, counted back from today.
  final weekTotals = List.filled(kStatsAccuracyWeeks, 0);
  final weekCorrect = List.filled(kStatsAccuracyWeeks, 0);
  for (final answer in firstTries) {
    final week = today.difference(_day(answer.time)).inDays ~/ 7;
    if (week < 0 || week >= kStatsAccuracyWeeks) continue;
    weekTotals[week]++;
    if (answer.correct) weekCorrect[week]++;
  }
  final weeklyAccuracy = [
    for (var week = kStatsAccuracyWeeks - 1; week >= 0; week--)
      if (weekTotals[week] == 0)
        null
      else
        weekCorrect[week] / weekTotals[week],
  ];

  // Weak spots.
  final weakLectures = [
    for (final MapEntry(key: id, value: results) in firstTriesByLecture.entries)
      if (lecturesById[id] case final lecture?
          when results.length >= 2 && results.contains(false))
        WeakLecture(
          title: lecture.title,
          errorRate: results.where((ok) => !ok).length / results.length,
          recentAnswers: results.sublist(
            math.max(0, results.length - _kSparklineAnswers),
          ),
        ),
  ]..sort((a, b) => b.errorRate.compareTo(a.errorRate));

  final confusionCounts = <(String, String), int>{};
  for (final answer in log.answers) {
    final picked = answer.pickedLectureId;
    if (answer.correct || picked == null || picked == answer.lectureId) {
      continue;
    }
    confusionCounts.update(
      (answer.lectureId, picked),
      (count) => count + 1,
      ifAbsent: () => 1,
    );
  }
  final confusionPairs = [
    for (final MapEntry(key: (expected, picked), value: count)
        in confusionCounts.entries)
      if ((lecturesById[expected], lecturesById[picked])
          case (final expectedLecture?, final pickedLecture?))
        ConfusionPair(
          expected: expectedLecture.title,
          picked: pickedLecture.title,
          count: count,
        ),
  ]..sort((a, b) => b.count.compareTo(a.count));

  final recentMistakes = [
    for (final mistake in [...mistakes]
      ..sort((a, b) => b.lastMistakeDate.compareTo(a.lastMistakeDate)))
      if (lecturesById[mistake.lectureId] case final lecture?)
        RecentMistake(title: lecture.title, when: mistake.lastMistakeDate),
  ];

  return StudyStats(
    currentStreak: currentStreak,
    longestStreak: longestStreak,
    cardsReviewed: log.answers.where((answer) => answer.correct).length,
    firstTryAccuracy: firstTries.isEmpty
        ? null
        : firstTries.where((answer) => answer.correct).length /
            firstTries.length,
    minutesStudied: log.sessions
        .map(
          (session) => math.min(
            session.end.difference(session.start).inSeconds / 60,
            _kMaxSessionMinutes,
          ),
        )
        .fold<double>(0, (sum, minutes) => sum + minutes)
        .round(),
    lecturesMastered: firstTriesByLecture.keys.where(isMastered).length,
    cardsChangeThisWeek:
        lastWeek == 0 ? null : (thisWeek - lastWeek) / lastWeek,
    days: days,
    decks: decks,
    weeklyAccuracy: weeklyAccuracy,
    weakLectures: weakLectures.take(_kWeakLectures).toList(),
    confusionPairs: confusionPairs.take(_kConfusionPairs).toList(),
    recentMistakes: recentMistakes,
  );
}
