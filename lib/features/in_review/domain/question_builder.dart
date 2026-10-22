import 'dart:math';

import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/in_review/domain/review_question.dart';
import 'package:japanana/features/statistics/domain/study_records.dart';

const _kChooseOptionCount = 4;
const _kGapOptionCount = 3;
const _kMeaningOptionCount = 3;
const _kMemoryPairs = 6;
const _kMinMemoryPairs = 3;

/// Runs of Japanese characters, used to find a grammar form in a sentence.
final _japaneseRun = RegExp('[ぁ-んァ-ヶー一-龯々〜]+');

/// Japanese parts of a lecture title long enough to cut out of a sentence,
/// longest first.
List<String> gapFragments(Lecture lecture) {
  final runs =
      _japaneseRun
          .allMatches(lecture.title)
          .map((match) => match.group(0)!.replaceAll('〜', ''))
          .where((run) => run.runes.length >= 2)
          .toSet()
          .toList()
        ..sort((a, b) => b.length.compareTo(a.length));
  return runs;
}

/// For each lecture, the lecture it was most often mixed up with.
Map<String, String> mixedUpPartners(List<AnswerRecord> answers) {
  final counts = <String, Map<String, int>>{};
  for (final answer in answers) {
    final picked = answer.pickedLectureId;
    if (answer.correct || picked == null || picked == answer.lectureId) {
      continue;
    }
    final perLecture = counts.putIfAbsent(answer.lectureId, () => {});
    perLecture[picked] = (perLecture[picked] ?? 0) + 1;
  }
  return {
    for (final MapEntry(:key, :value) in counts.entries)
      key:
          (value.entries.toList()..sort((a, b) => b.value - a.value)).first.key,
  };
}

/// Builds the questions of a review from its lectures.
class QuestionBuilder {
  QuestionBuilder({
    required this.deck,
    required this.allLectures,
    required this.random,
    this.seenLectureIds = const {},
    this.partners = const {},
  });

  /// Lectures of this review.
  final List<Lecture> deck;

  /// Every lecture, for wrong options and mixed-up partners.
  final List<Lecture> allLectures;
  final Random random;

  /// Lectures answered in earlier reviews.
  final Set<String> seenLectureIds;
  final Map<String, String> partners;

  List<Lecture> get _pool => deck.length >= _kChooseOptionCount
      ? deck
      : [...deck, ...allLectures.where((l) => !deck.any((d) => d.id == l.id))];

  /// Picks a mode for [lecture] and builds its question. [previous] is
  /// avoided so the same kind of question doesn't repeat back to back.
  LectureQuestion build(
    Lecture lecture, {
    QuestionMode? previous,
    QuestionMode? forced,
  }) {
    final mode = forced ?? _pickMode(lecture, previous);
    return _buildFor(lecture, mode) ??
        LectureQuestion(
          lecture: lecture,
          mode: QuestionMode.choose,
          choose: _choose(lecture),
        );
  }

  QuestionMode _pickMode(Lecture lecture, QuestionMode? previous) {
    if (_pairs(lecture) != null) return QuestionMode.pairs;
    final seen = seenLectureIds.contains(lecture.id);
    final options = [
      QuestionMode.choose,
      if (seen) QuestionMode.swipe,
      if (seen && _gap(lecture) != null) QuestionMode.gap,
      if (_meaning(lecture) != null) QuestionMode.meaning,
    ];
    if (options.length > 1) options.remove(previous);
    return options[random.nextInt(options.length)];
  }

  LectureQuestion? _buildFor(Lecture lecture, QuestionMode mode) =>
      switch (mode) {
        QuestionMode.choose => LectureQuestion(
          lecture: lecture,
          mode: mode,
          choose: _choose(lecture),
        ),
        QuestionMode.swipe => LectureQuestion(
          lecture: lecture,
          mode: mode,
          swipe: _swipe(lecture),
        ),
        QuestionMode.gap => switch (_gap(lecture)) {
          final gap? => LectureQuestion(lecture: lecture, mode: mode, gap: gap),
          null => null,
        },
        QuestionMode.meaning => switch (_meaning(lecture)) {
          final meaning? => LectureQuestion(
            lecture: lecture,
            mode: mode,
            meaning: meaning,
          ),
          null => null,
        },
        QuestionMode.pairs => switch (_pairs(lecture)) {
          final pairs? => LectureQuestion(
            lecture: lecture,
            mode: mode,
            pairs: pairs,
          ),
          null => null,
        },
      };

  ChooseQuestion _choose(Lecture lecture) {
    final options = <String>[];
    final owners = <String?>[];
    if (lecture.usages.isNotEmpty) {
      options.add(lecture.usages[random.nextInt(lecture.usages.length)]);
      owners.add(lecture.id);
    }
    final others = [
      for (final other in _pool)
        if (other.id != lecture.id)
          for (final usage in other.usages) (usage, other.id),
    ]..shuffle(random);
    for (final (usage, owner) in others) {
      if (options.length >= _kChooseOptionCount) break;
      if (options.contains(usage) || lecture.usages.contains(usage)) continue;
      options.add(usage);
      owners.add(owner);
    }
    final order = List.generate(options.length, (i) => i)..shuffle(random);
    return ChooseQuestion(
      options: [for (final i in order) options[i]],
      owners: [for (final i in order) owners[i]],
    );
  }

  SwipeQuestion _swipe(Lecture lecture) {
    final decoys = [
      for (final other in _pool)
        if (other.id != lecture.id)
          for (final usage in other.usages)
            if (!lecture.usages.contains(usage)) (usage, other.id),
    ];
    if (lecture.usages.isNotEmpty && (decoys.isEmpty || random.nextBool())) {
      return SwipeQuestion(
        usage: lecture.usages[random.nextInt(lecture.usages.length)],
        fits: true,
      );
    }
    final (usage, owner) = decoys[random.nextInt(decoys.length)];
    return SwipeQuestion(usage: usage, fits: false, ownerId: owner);
  }

  GapQuestion? _gap(Lecture lecture) {
    final fragments = gapFragments(lecture);
    for (final (index, example) in lecture.examples.indexed) {
      for (final fragment in fragments) {
        final at = example.indexOf(fragment);
        if (at < 0) continue;
        final wrong = <(String, String)>[];
        final candidates = [
          for (final other in _pool)
            if (other.id != lecture.id)
              if (gapFragments(other).firstOrNull case final f?) (f, other.id),
        ]..shuffle(random);
        for (final candidate in candidates) {
          if (wrong.length >= _kGapOptionCount - 1) break;
          if (candidate.$1 == fragment ||
              wrong.any((w) => w.$1 == candidate.$1)) {
            continue;
          }
          wrong.add(candidate);
        }
        if (wrong.length < _kGapOptionCount - 1) return null;
        final options = [(fragment, lecture.id), ...wrong]..shuffle(random);
        return GapQuestion(
          before: example.substring(0, at),
          after: example.substring(at + fragment.length),
          answer: fragment,
          options: [for (final o in options) o.$1],
          owners: [for (final o in options) o.$2],
          translation: index < lecture.translations.length
              ? lecture.translations[index]
              : null,
          exampleIndex: index,
        );
      }
    }
    return null;
  }

  MeaningQuestion? _meaning(Lecture lecture) {
    final count = min(lecture.examples.length, lecture.translations.length);
    if (count == 0) return null;
    final index = random.nextInt(count);
    final right = lecture.translations[index];
    final wrong = [
      for (final other in _pool)
        if (other.id != lecture.id)
          for (final translation in other.translations)
            if (translation != right) (translation, other.id),
    ]..shuffle(random);
    final picked = <(String, String?)>[(right, lecture.id)];
    for (final candidate in wrong) {
      if (picked.length >= _kMeaningOptionCount) break;
      if (picked.any((p) => p.$1 == candidate.$1)) continue;
      picked.add(candidate);
    }
    if (picked.length < 2) return null;
    picked.shuffle(random);
    return MeaningQuestion(
      sentence: lecture.examples[index],
      options: [for (final p in picked) p.$1],
      owners: [for (final p in picked) p.$2],
      correctIndex: picked.indexWhere((p) => p.$1 == right),
      exampleIndex: index,
    );
  }

  PairsQuestion? _pairs(Lecture lecture) {
    final partnerId = partners[lecture.id];
    if (partnerId == null || lecture.translations.isEmpty) return null;
    final other = allLectures.where((l) => l.id == partnerId).firstOrNull;
    if (other == null) return null;
    return PairsQuestion(
      prompt: lecture.translations.first,
      other: other,
      lectureFirst: lecture.id.hashCode.isEven,
    );
  }

  /// Cards of a memory game from [recent] lectures, or null when too few
  /// lectures have a usage.
  List<MemoryCard>? memoryCards(List<Lecture> recent) {
    final usable = recent.where((l) => l.usages.isNotEmpty).toList();
    final chosen = usable.length > _kMemoryPairs
        ? usable.sublist(usable.length - _kMemoryPairs)
        : usable;
    if (chosen.length < _kMinMemoryPairs) return null;
    return [
      for (final lecture in chosen) ...[
        MemoryCard(pairId: lecture.id, text: lecture.title, isTitle: true),
        MemoryCard(
          pairId: lecture.id,
          text: lecture.usages.first,
          isTitle: false,
        ),
      ],
    ]..shuffle(random);
  }

  /// True or false statements about [lectures] for the lightning round.
  List<LightningStatement> lightningStatements(
    List<Lecture> lectures, {
    int count = 60,
  }) {
    final usable = lectures.where((l) => l.usages.isNotEmpty).toList();
    if (usable.length < 2) return const [];
    return List.generate(count, (_) {
      final lecture = usable[random.nextInt(usable.length)];
      final fits = random.nextBool();
      final source = fits
          ? lecture
          : (usable.where((l) => l.id != lecture.id).toList()..shuffle(random))
                .first;
      return LightningStatement(
        title: lecture.title,
        usage: source.usages.first,
        fits: fits || lecture.usages.contains(source.usages.first),
      );
    });
  }
}
