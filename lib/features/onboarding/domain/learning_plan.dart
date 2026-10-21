import 'package:flutter/foundation.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/onboarding/domain/onboarding_answers.dart';

/// Lectures per book in the bundled grammar data, used until the lectures
/// are loaded.
const kDefaultLectureCounts = {
  LectureType.n4: 68,
  LectureType.n3: 322,
  LectureType.n2: 146,
};
const kDefaultLectureTotal = 558;

/// Grammar points a self-studying learner gets comfortable with per month.
const _kSelfStudyPointsPerMonth = 26;

/// Minutes of practice one grammar point needs until it sticks.
const _kMinutesPerPoint = 4;

/// Estimate of how long the learner needs until real conversations feel
/// natural, alone and with daily practice.
@immutable
class LearningPlan {
  const LearningPlan({
    required this.totalPoints,
    required this.pointsToGo,
    required this.monthsAlone,
    required this.monthsWithJapanana,
    required this.targetDate,
  });

  factory LearningPlan.calculate({
    required OnboardingAnswers answers,
    required Map<LectureType, int> lectureCounts,
    required int totalPoints,
    required DateTime now,
  }) {
    final pointsToGo = answers.level.booksToGo.fold(
      0,
      (sum, book) => sum + (lectureCounts[book] ?? 0),
    );
    final monthsAlone = (pointsToGo / _kSelfStudyPointsPerMonth).ceil();
    final monthsWithJapanana =
        (pointsToGo * _kMinutesPerPoint / (answers.dailyMinutes * 30))
            .ceil()
            .clamp(1, monthsAlone < 1 ? 1 : monthsAlone);
    return LearningPlan(
      totalPoints: totalPoints,
      pointsToGo: pointsToGo,
      monthsAlone: monthsAlone < 1 ? 1 : monthsAlone,
      monthsWithJapanana: monthsWithJapanana,
      targetDate: DateTime(now.year, now.month + monthsWithJapanana),
    );
  }

  /// Grammar points in the app.
  final int totalPoints;

  /// Grammar points from the learner's level up.
  final int pointsToGo;
  final int monthsAlone;
  final int monthsWithJapanana;

  /// Month in which conversations should feel natural with Japanana.
  final DateTime targetDate;
}
