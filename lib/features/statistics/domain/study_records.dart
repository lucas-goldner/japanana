import 'dart:convert';

import 'package:flutter/foundation.dart';

/// One usage pick in a review.
@immutable
class AnswerRecord {
  const AnswerRecord({
    required this.time,
    required this.lectureId,
    required this.correct,
    required this.firstAttempt,
    this.pickedLectureId,
  });

  factory AnswerRecord.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return AnswerRecord(
      time: DateTime.parse(map['time'] as String),
      lectureId: map['lectureId'] as String,
      correct: map['correct'] as bool,
      firstAttempt: map['firstAttempt'] as bool,
      pickedLectureId: map['pickedLectureId'] as String?,
    );
  }

  final DateTime time;
  final String lectureId;
  final bool correct;

  /// Whether this was the first pick for the card.
  final bool firstAttempt;

  /// For wrong picks: the lecture whose usage was picked instead.
  final String? pickedLectureId;

  String toJson() => jsonEncode({
        'time': time.toIso8601String(),
        'lectureId': lectureId,
        'correct': correct,
        'firstAttempt': firstAttempt,
        if (pickedLectureId != null) 'pickedLectureId': pickedLectureId,
      });
}

/// One review session from opening to leaving the review screen.
@immutable
class SessionRecord {
  const SessionRecord({
    required this.start,
    required this.end,
    required this.cardsCompleted,
  });

  factory SessionRecord.fromJson(String source) {
    final map = jsonDecode(source) as Map<String, dynamic>;
    return SessionRecord(
      start: DateTime.parse(map['start'] as String),
      end: DateTime.parse(map['end'] as String),
      cardsCompleted: map['cardsCompleted'] as int,
    );
  }

  final DateTime start;
  final DateTime end;
  final int cardsCompleted;

  String toJson() => jsonEncode({
        'start': start.toIso8601String(),
        'end': end.toIso8601String(),
        'cardsCompleted': cardsCompleted,
      });
}

@immutable
class StudyLog {
  const StudyLog({this.answers = const [], this.sessions = const []});

  /// Oldest first.
  final List<AnswerRecord> answers;

  /// Oldest first.
  final List<SessionRecord> sessions;
}
