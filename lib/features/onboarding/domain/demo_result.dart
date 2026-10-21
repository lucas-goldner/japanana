import 'package:flutter/foundation.dart';
import 'package:japanana/core/domain/lecture.dart';

/// Outcome of the first conversation in the onboarding.
@immutable
class DemoResult {
  const DemoResult({
    required this.lecture,
    required this.firstTry,
    this.mixedUpWith,
    this.nextLecture,
  });

  final Lecture lecture;

  /// Whether the right usage was picked without a wrong pick before.
  final bool firstTry;

  /// Lecture whose usage was picked by mistake.
  final Lecture? mixedUpWith;

  /// Lecture the first real review continues with.
  final Lecture? nextLecture;
}
