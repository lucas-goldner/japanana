import 'package:flutter/foundation.dart';
import 'package:japanana/core/domain/lecture.dart';

/// What happened in a review session, for the summary and the recap video.
@immutable
class SessionRecap {
  const SessionRecap({
    required this.book,
    required this.date,
    required this.cards,
    required this.firstTryRight,
    required this.bestCombo,
    required this.learned,
    required this.missed,
  });

  final LectureType book;
  final DateTime date;

  /// Lectures answered in the session.
  final int cards;

  /// Lectures answered right without a wrong pick first.
  final int firstTryRight;
  final int bestCombo;

  /// Lectures of the session in order.
  final List<Lecture> learned;

  /// Lectures with at least one wrong pick.
  final List<Lecture> missed;

  int get firstTryPercent =>
      cards == 0 ? 0 : (firstTryRight * 100 / cards).round();

  /// Up to [count] lectures to show off, right on the first try first.
  List<Lecture> highlights({int count = 3}) {
    final withExamples = learned.where((l) => l.examples.isNotEmpty);
    return [
      ...withExamples.where((l) => !missed.contains(l)),
      ...withExamples.where(missed.contains),
    ].take(count).toList();
  }
}
