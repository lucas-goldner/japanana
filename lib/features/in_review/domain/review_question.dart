import 'package:flutter/foundation.dart';
import 'package:japanana/core/domain/lecture.dart';

/// Ways a lecture can be asked about during a review.
enum QuestionMode {
  /// Pick the lecture's usage out of four.
  choose,

  /// Swipe whether a usage fits the lecture.
  swipe,

  /// Complete an example sentence with the right grammar.
  gap,

  /// Pick the translation of an example sentence.
  meaning,

  /// Tell apart two lectures the learner mixed up before.
  pairs,
}

/// Games played between lectures.
enum BreakKind { memory, lightning }

/// The four usages offered in [QuestionMode.choose].
@immutable
class ChooseQuestion {
  const ChooseQuestion({required this.options, required this.owners});

  final List<String> options;

  /// Lecture each option belongs to, for recording mix-ups.
  final List<String?> owners;
}

/// A usage that may or may not belong to the lecture.
@immutable
class SwipeQuestion {
  const SwipeQuestion({required this.usage, required this.fits, this.ownerId});

  final String usage;
  final bool fits;

  /// Lecture the usage belongs to when it doesn't fit.
  final String? ownerId;
}

/// An example sentence with the grammar cut out.
@immutable
class GapQuestion {
  const GapQuestion({
    required this.before,
    required this.after,
    required this.answer,
    required this.options,
    required this.owners,
    required this.translation,
    required this.exampleIndex,
  });

  final String before;
  final String after;
  final String answer;
  final List<String> options;
  final List<String?> owners;
  final String? translation;

  /// Example the gap was cut from, skipped in the examples that follow.
  final int exampleIndex;
}

/// An example sentence and translations to pick from.
@immutable
class MeaningQuestion {
  const MeaningQuestion({
    required this.sentence,
    required this.options,
    required this.correctIndex,
    required this.owners,
    required this.exampleIndex,
  });

  final String sentence;
  final List<String> options;
  final int correctIndex;
  final List<String?> owners;
  final int exampleIndex;
}

/// A translation to express with one of two lectures that look alike.
@immutable
class PairsQuestion {
  const PairsQuestion({
    required this.prompt,
    required this.other,
    required this.lectureFirst,
  });

  /// English sentence that needs the lecture's grammar.
  final String prompt;

  /// Lecture the learner mixed this one up with.
  final Lecture other;

  /// Whether the right lecture is shown on the left.
  final bool lectureFirst;
}

/// A lecture together with how it's asked about.
@immutable
class LectureQuestion {
  const LectureQuestion({
    required this.lecture,
    required this.mode,
    this.choose,
    this.swipe,
    this.gap,
    this.meaning,
    this.pairs,
  });

  final Lecture lecture;
  final QuestionMode mode;
  final ChooseQuestion? choose;
  final SwipeQuestion? swipe;
  final GapQuestion? gap;
  final MeaningQuestion? meaning;
  final PairsQuestion? pairs;

  /// Example the question already used, so the examples after it skip it.
  int? get usedExample => gap?.exampleIndex ?? meaning?.exampleIndex;
}

/// One card of the memory game.
@immutable
class MemoryCard {
  const MemoryCard({
    required this.pairId,
    required this.text,
    required this.isTitle,
  });

  final String pairId;
  final String text;

  /// Grammar title rather than its usage.
  final bool isTitle;
}

/// One statement of the lightning round.
@immutable
class LightningStatement {
  const LightningStatement({
    required this.title,
    required this.usage,
    required this.fits,
  });

  final String title;
  final String usage;
  final bool fits;
}
