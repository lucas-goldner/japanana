import 'package:flutter/foundation.dart';
import 'package:japanana/core/domain/lecture.dart';

/// Cards answered on one day.
@immutable
class DayActivity {
  const DayActivity({
    required this.day,
    required this.correct,
    required this.wrong,
  });

  final DateTime day;
  final int correct;
  final int wrong;

  int get total => correct + wrong;
}

/// How far the learner got through one deck.
@immutable
class DeckMastery {
  const DeckMastery({
    required this.type,
    required this.unseen,
    required this.learning,
    required this.mastered,
  });

  final LectureType type;
  final int unseen;
  final int learning;
  final int mastered;

  int get total => unseen + learning + mastered;
}

/// A lecture the learner often gets wrong.
@immutable
class WeakLecture {
  const WeakLecture({
    required this.title,
    required this.errorRate,
    required this.recentAnswers,
  });

  final String title;

  /// Share of wrong first answers, 0 to 1.
  final double errorRate;

  /// Last answers, oldest first; true means correct.
  final List<bool> recentAnswers;
}

/// Two lectures whose usages the learner mixes up.
@immutable
class ConfusionPair {
  const ConfusionPair({
    required this.expected,
    required this.picked,
    required this.count,
  });

  final String expected;
  final String picked;
  final int count;
}

@immutable
class RecentMistake {
  const RecentMistake({required this.title, required this.when});

  final String title;
  final DateTime when;
}

/// Everything the statistics screen shows.
@immutable
class StudyStats {
  const StudyStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.cardsReviewed,
    required this.firstTryAccuracy,
    required this.minutesStudied,
    required this.lecturesMastered,
    required this.cardsChangeThisWeek,
    required this.days,
    required this.decks,
    required this.weeklyAccuracy,
    required this.weakLectures,
    required this.confusionPairs,
    required this.recentMistakes,
  });

  final int currentStreak;
  final int longestStreak;
  final int cardsReviewed;

  /// Share of cards answered right on the first try, 0 to 1, or null before
  /// the first answer.
  final double? firstTryAccuracy;
  final int minutesStudied;
  final int lecturesMastered;

  /// Cards reviewed this week compared to last week, e.g. 0.18 for +18%, or
  /// null when nothing was reviewed last week.
  final double? cardsChangeThisWeek;

  /// One entry per day, oldest first, ending today.
  final List<DayActivity> days;
  final List<DeckMastery> decks;

  /// First try accuracy per week, oldest first; null for weeks without
  /// answers.
  final List<double?> weeklyAccuracy;
  final List<WeakLecture> weakLectures;
  final List<ConfusionPair> confusionPairs;
  final List<RecentMistake> recentMistakes;

  bool get hasActivity => cardsReviewed > 0 || days.any((day) => day.total > 0);
}
