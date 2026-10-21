import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:japanana/core/domain/lecture.dart';

enum OnboardingGoal { talk, travel, anime, work, jlpt }

enum OnboardingPain { cantSpeak, textbook, forget, mixUp }

/// JLPT level the learner places themselves at.
enum JlptLevel {
  n5,
  n4,
  n3,
  n2,
  n1;

  String get label => name.toUpperCase();

  /// Book the first lessons come from. There are no N5 and N1 books, so
  /// beginners start with N4 and advanced learners review N2.
  LectureType get startingBook => switch (this) {
    JlptLevel.n5 || JlptLevel.n4 => LectureType.n4,
    JlptLevel.n3 => LectureType.n3,
    JlptLevel.n2 || JlptLevel.n1 => LectureType.n2,
  };

  /// Books still ahead of a learner at this level, starting book included.
  List<LectureType> get booksToGo => switch (this) {
    JlptLevel.n5 ||
    JlptLevel.n4 => const [LectureType.n4, LectureType.n3, LectureType.n2],
    JlptLevel.n3 => const [LectureType.n3, LectureType.n2],
    JlptLevel.n2 || JlptLevel.n1 => const [LectureType.n2],
  };
}

/// Everything the learner told us during onboarding.
@immutable
class OnboardingAnswers {
  const OnboardingAnswers({
    this.goal,
    this.level = JlptLevel.n4,
    this.years = 1,
    this.speakingConfidence = 0.5,
    this.pains = const {},
    this.dailyMinutes = 10,
  });

  factory OnboardingAnswers.fromJson(String source) {
    final json = jsonDecode(source) as Map<String, dynamic>;
    return OnboardingAnswers(
      goal: OnboardingGoal.values.asNameMap()[json['goal']],
      level: JlptLevel.values.asNameMap()[json['level']] ?? JlptLevel.n4,
      years: json['years'] as int? ?? 1,
      speakingConfidence:
          (json['speakingConfidence'] as num?)?.toDouble() ?? 0.5,
      pains: {
        for (final pain in json['pains'] as List<dynamic>? ?? <dynamic>[])
          if (OnboardingPain.values.asNameMap()[pain] case final pain?) pain,
      },
      dailyMinutes: json['dailyMinutes'] as int? ?? 10,
    );
  }

  final OnboardingGoal? goal;
  final JlptLevel level;

  /// Years spent studying so far.
  final int years;

  /// 0 freezes up when spoken to, 1 answers naturally.
  final double speakingConfidence;

  /// Struggles the learner said sound like them.
  final Set<OnboardingPain> pains;
  final int dailyMinutes;

  OnboardingAnswers copyWith({
    OnboardingGoal? goal,
    JlptLevel? level,
    int? years,
    double? speakingConfidence,
    Set<OnboardingPain>? pains,
    int? dailyMinutes,
  }) => OnboardingAnswers(
    goal: goal ?? this.goal,
    level: level ?? this.level,
    years: years ?? this.years,
    speakingConfidence: speakingConfidence ?? this.speakingConfidence,
    pains: pains ?? this.pains,
    dailyMinutes: dailyMinutes ?? this.dailyMinutes,
  );

  String toJson() => jsonEncode({
    'goal': goal?.name,
    'level': level.name,
    'years': years,
    'speakingConfidence': speakingConfidence,
    'pains': [for (final pain in pains) pain.name],
    'dailyMinutes': dailyMinutes,
  });

  @override
  bool operator ==(Object other) =>
      other is OnboardingAnswers &&
      other.goal == goal &&
      other.level == level &&
      other.years == years &&
      other.speakingConfidence == speakingConfidence &&
      setEquals(other.pains, pains) &&
      other.dailyMinutes == dailyMinutes;

  @override
  int get hashCode => Object.hash(
    goal,
    level,
    years,
    speakingConfidence,
    Object.hashAllUnordered(pains),
    dailyMinutes,
  );
}
