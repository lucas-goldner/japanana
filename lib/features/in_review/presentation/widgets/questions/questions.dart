import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/features/in_review/domain/review_question.dart';
import 'package:japanana/features/in_review/presentation/widgets/review_widgets.dart';

const _kOptionStagger = Duration(milliseconds: 150);
const _kSwipeThreshold = 80.0;
const _kSwipeSettle = Duration(milliseconds: 280);
const _kStampGreen = Color(0xff2E9A4B);

/// Reports one pick. [pickedLectureId] is the lecture whose content was
/// picked by mistake.
typedef AttemptCallback = void Function({
  required bool correct,
  String? pickedLectureId,
});

TextStyle _body(BuildContext context, {double size = 16}) => TextStyle(
  fontFamily: kReviewFont,
  fontWeight: FontWeight.bold,
  fontSize: size,
  height: 1.4,
  color: context.neo.onCard,
);

TextStyle _muted(BuildContext context, {double size = 14}) => TextStyle(
  fontFamily: kReviewFont,
  fontSize: size,
  height: 1.45,
  color: context.neo.onCard.withValues(alpha: 0.75),
);

/// Classic question: pick the lecture's usage out of four.
class ChooseQuestionView extends HookWidget {
  const ChooseQuestionView({
    required this.question,
    required this.onAttempt,
    required this.onSolved,
    super.key,
  });

  final LectureQuestion question;
  final AttemptCallback onAttempt;
  final VoidCallback onSolved;

  @override
  Widget build(BuildContext context) {
    final choose = question.choose!;
    final wrong = useState<Set<int>>({});
    final right = useState<int?>(null);

    void pick(int index) {
      if (right.value != null || wrong.value.contains(index)) return;
      final correct = question.lecture.usages.contains(choose.options[index]);
      onAttempt(
        correct: correct,
        pickedLectureId: correct ? null : choose.owners[index],
      );
      if (correct) {
        right.value = index;
        onSolved();
      } else {
        wrong.value = {...wrong.value, index};
      }
    }

    return Column(
      children: [
        for (final (index, option) in choose.options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 18, right: 5),
            child: ReviewReveal(
              delay: _kOptionStagger * index,
              child: ChoiceTile(
                label: option,
                state: right.value == index
                    ? ChoiceState.right
                    : wrong.value.contains(index)
                    ? ChoiceState.wrong
                    : right.value != null
                    ? ChoiceState.dimmed
                    : ChoiceState.idle,
                onTap: () => pick(index),
              ),
            ),
          ),
      ],
    );
  }
}

/// Swipe right when the usage fits the lecture, left when it doesn't.
class SwipeQuestionView extends HookWidget {
  const SwipeQuestionView({
    required this.question,
    required this.onAttempt,
    required this.onSolved,
    super.key,
  });

  final LectureQuestion question;
  final AttemptCallback onAttempt;
  final VoidCallback onSolved;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final neo = context.neo;
    final swipe = question.swipe!;
    final drag = useState<double>(0);
    final verdict = useState<bool?>(null);
    final settle = useAnimationController(duration: _kSwipeSettle);
    final curved = useMemoized(
      () => CurvedAnimation(parent: settle, curve: Curves.easeOut),
    );
    final settleValue = useAnimation(curved);
    final settleFrom = useRef<double>(0);

    void decide({required bool fits}) {
      if (verdict.value != null) return;
      final correct = fits == swipe.fits;
      settleFrom.value = drag.value;
      verdict.value = fits;
      drag.value = 0;
      settle.forward(from: 0);
      onAttempt(
        correct: correct,
        pickedLectureId: !correct && fits ? swipe.ownerId : null,
      );
      onSolved();
    }

    final decided = verdict.value;
    final restingOffset = decided == null ? 0.0 : (decided ? 26.0 : -26.0);
    final offset = decided == null
        ? drag.value
        : settleFrom.value + (restingOffset - settleFrom.value) * settleValue;
    final correct = decided != null && decided == swipe.fits;
    final stampFits = decided ?? drag.value > 0;
    final stampOpacity = decided != null
        ? 1.0
        : (drag.value.abs() / _kSwipeThreshold).clamp(0.0, 1.0);
    final stampColor = stampFits ? _kStampGreen : context.colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        GestureDetector(
          onHorizontalDragUpdate: decided == null
              ? (details) => drag.value += details.delta.dx
              : null,
          onHorizontalDragEnd: decided == null
              ? (_) {
                  if (drag.value.abs() > _kSwipeThreshold) {
                    decide(fits: drag.value > 0);
                  } else {
                    drag.value = 0;
                  }
                }
              : null,
          child: Transform.translate(
            offset: Offset(offset, 0),
            child: Transform.rotate(
              angle: offset / 400 * 0.5,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.fromLTRB(12, 4, 17, 8),
                padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                decoration: neo.decoration(
                  color: decided == null
                      ? neo.card
                      : correct
                      ? neo.correctFill
                      : neo.wrongFill,
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          question.lecture.title,
                          style: _body(context, size: 36).copyWith(
                            color: decided == null ? null : neo.onFeedback,
                          ),
                        ),
                        Container(
                          height: 3,
                          margin: const EdgeInsets.symmetric(vertical: 14),
                          color: decided == null ? neo.border : neo.onFeedback,
                        ),
                        Text(
                          swipe.usage,
                          style: _body(context, size: 18).copyWith(
                            color: decided == null ? null : neo.onFeedback,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: -8,
                      right: -6,
                      child: Opacity(
                        opacity: stampOpacity,
                        child: Transform.rotate(
                          angle: stampFits ? 0.24 : -0.24,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: neo.card,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: stampColor, width: 3),
                            ),
                            child: Text(
                              (stampFits
                                      ? l10n.reviewSwipeFits
                                      : l10n.reviewSwipeNope)
                                  .toUpperCase(),
                              style: TextStyle(
                                fontFamily: kReviewFont,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: stampColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (decided == null) ...[
          const SizedBox(height: 8),
          Text(
            l10n.reviewSwipeHint,
            textAlign: TextAlign.center,
            style: _muted(context, size: 13),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _RoundButton(
                icon: Icons.close,
                color: neo.wrongFill,
                label: l10n.reviewSwipeNope,
                onPressed: () => decide(fits: false),
              ),
              const SizedBox(width: 44),
              _RoundButton(
                icon: Icons.check,
                color: neo.correctFill,
                label: l10n.reviewSwipeFits,
                onPressed: () => decide(fits: true),
              ),
            ],
          ),
        ] else if (!swipe.fits || !correct)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Text(
              l10n.reviewSwipeActual(
                question.lecture.title,
                question.lecture.usages.firstOrNull ?? '',
              ),
              style: _muted(context),
            ),
          ),
      ],
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: SizedBox.square(
      dimension: 72,
      child: NeoButton(
        onPressed: onPressed,
        color: color,
        minHeight: 72,
        padding: EdgeInsets.zero,
        child: Icon(icon, size: 32, color: context.neo.onFeedback),
      ),
    ),
  );
}

/// Example sentence with the grammar cut out; tap or drag a chip into it.
class GapQuestionView extends HookWidget {
  const GapQuestionView({
    required this.question,
    required this.onAttempt,
    required this.onSolved,
    super.key,
  });

  final LectureQuestion question;
  final AttemptCallback onAttempt;
  final VoidCallback onSolved;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final neo = context.neo;
    final gap = question.gap!;
    final wrong = useState<Set<int>>({});
    final solved = useState(false);
    final shakes = useState(0);

    void place(int index) {
      if (solved.value || wrong.value.contains(index)) return;
      final correct = gap.options[index] == gap.answer;
      onAttempt(
        correct: correct,
        pickedLectureId: correct ? null : gap.owners[index],
      );
      if (correct) {
        solved.value = true;
        onSolved();
      } else {
        wrong.value = {...wrong.value, index};
        shakes.value++;
      }
    }

    final sentence = _body(context, size: 24);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 5),
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
          decoration: neo.decoration(),
          child: Column(
            children: [
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 6,
                children: [
                  if (gap.before.isNotEmpty) Text(gap.before, style: sentence),
                  Shake(
                    trigger: shakes.value,
                    child: DragTarget<int>(
                      onWillAcceptWithDetails: (_) => !solved.value,
                      onAcceptWithDetails: (details) => place(details.data),
                      builder: (context, candidates, _) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        constraints: const BoxConstraints(minWidth: 96),
                        height: 46,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10),

                        decoration: BoxDecoration(
                          color: solved.value
                              ? neo.correctFill
                              : candidates.isNotEmpty
                              ? neo.accent.withValues(alpha: 0.5)
                              : neo.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: neo.border, width: 3),
                        ),
                        child: Center(
                          widthFactor: 1,
                          child: Text(
                            solved.value ? gap.answer : ' ',
                            style: sentence.copyWith(color: neo.onFeedback),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (gap.after.isNotEmpty) Text(gap.after, style: sentence),
                ],
              ),
              if (gap.translation != null) ...[
                const SizedBox(height: 14),
                Text(
                  gap.translation!,
                  textAlign: TextAlign.center,
                  style: _muted(context, size: 15),
                ),
              ],
            ],
          ),
        ),
        if (!solved.value) ...[
          const SizedBox(height: 18),
          Text(
            l10n.reviewGapHint,
            textAlign: TextAlign.center,
            style: _muted(context, size: 13),
          ),
        ],
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 12,
          runSpacing: 14,
          children: [
            for (final (index, option) in gap.options.indexed)
              ReviewReveal(
                delay: _kOptionStagger * index,
                child: _GapChip(
                  label: option,
                  state: wrong.value.contains(index)
                      ? ChoiceState.wrong
                      : solved.value && option == gap.answer
                      ? ChoiceState.right
                      : solved.value
                      ? ChoiceState.dimmed
                      : ChoiceState.idle,
                  index: index,
                  onTap: () => place(index),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _GapChip extends StatelessWidget {
  const _GapChip({
    required this.label,
    required this.state,
    required this.index,
    required this.onTap,
  });

  final String label;
  final ChoiceState state;
  final int index;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    Widget chip({bool lifted = false}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: neo.decoration(
        color: lifted
            ? neo.accent
            : switch (state) {
                ChoiceState.wrong => neo.wrongFill,
                ChoiceState.right => neo.correctFill,
                _ => neo.card,
              },
        shadowColor: lifted ? neo.accentShadow : neo.shadow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: _body(context, size: 20).copyWith(
          color: lifted
              ? neo.onAccent
              : state == ChoiceState.idle || state == ChoiceState.dimmed
              ? neo.onCard
              : neo.onFeedback,
          decoration: state == ChoiceState.wrong
              ? TextDecoration.lineThrough
              : null,
          decorationThickness: 2,
        ),
      ),
    );
    final interactive = state == ChoiceState.idle;
    return Opacity(
      opacity: state == ChoiceState.dimmed ? 0.45 : 1,
      child: interactive
          ? Draggable<int>(
              data: index,
              feedback: Material(
                color: Colors.transparent,
                child: Transform.rotate(
                  angle: -0.08,
                  child: chip(lifted: true),
                ),
              ),
              childWhenDragging: Opacity(opacity: 0.3, child: chip()),
              child: GestureDetector(onTap: onTap, child: chip()),
            )
          : chip(),
    );
  }
}

/// Pick the translation of an example sentence.
class MeaningQuestionView extends HookWidget {
  const MeaningQuestionView({
    required this.question,
    required this.onAttempt,
    required this.onSolved,
    super.key,
  });

  final LectureQuestion question;
  final AttemptCallback onAttempt;
  final VoidCallback onSolved;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final meaning = question.meaning!;
    final wrong = useState<Set<int>>({});
    final solved = useState(false);

    void pick(int index) {
      if (solved.value || wrong.value.contains(index)) return;
      final correct = index == meaning.correctIndex;
      onAttempt(
        correct: correct,
        pickedLectureId: correct ? null : meaning.owners[index],
      );
      if (correct) {
        solved.value = true;
        onSolved();
      } else {
        wrong.value = {...wrong.value, index};
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          margin: const EdgeInsets.only(right: 5, bottom: 22),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
          decoration: neo.decoration(),
          child: Column(
            children: [
              Text(
                meaning.sentence,
                textAlign: TextAlign.center,
                style: _body(context, size: 26),
              ),
              const SizedBox(height: 12),
              ReviewPill(
                label: question.lecture.title,
                color: neo.accent,
                foregroundColor: neo.onAccent,
              ),
            ],
          ),
        ),
        for (final (index, option) in meaning.options.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 18, right: 5),
            child: ReviewReveal(
              delay: _kOptionStagger * index,
              child: ChoiceTile(
                label: option,
                state: solved.value && index == meaning.correctIndex
                    ? ChoiceState.right
                    : wrong.value.contains(index)
                    ? ChoiceState.wrong
                    : solved.value
                    ? ChoiceState.dimmed
                    : ChoiceState.idle,
                onTap: () => pick(index),
              ),
            ),
          ),
      ],
    );
  }
}

/// Two lectures the learner mixed up: which one says the prompt?
class PairsQuestionView extends HookWidget {
  const PairsQuestionView({
    required this.question,
    required this.onAttempt,
    required this.onSolved,
    super.key,
  });

  final LectureQuestion question;
  final AttemptCallback onAttempt;
  final VoidCallback onSolved;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final neo = context.neo;
    final pairs = question.pairs!;
    final picked = useState<String?>(null);
    final lectures = pairs.lectureFirst
        ? [question.lecture, pairs.other]
        : [pairs.other, question.lecture];

    void pick(String id) {
      if (picked.value != null) return;
      picked.value = id;
      final correct = id == question.lecture.id;
      onAttempt(
        correct: correct,
        pickedLectureId: correct ? null : pairs.other.id,
      );
      onSolved();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: ReviewPill(
            label: l10n.reviewPairsBadge,
            color: const Color(0xffB8474A),
            foregroundColor: Colors.white,
          ),
        ),
        const SizedBox(height: 14),
        Container(
          margin: const EdgeInsets.only(right: 5),
          padding: const EdgeInsets.all(20),
          decoration: neo.decoration(),
          child: Text('“${pairs.prompt}”', style: _body(context, size: 20)),
        ),
        const SizedBox(height: 22),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (final (index, lecture) in lectures.indexed) ...[
                if (index == 1) const SizedBox(width: 16),
                Expanded(
                  child: _PairOption(
                    lecture: lecture.title,
                    usage: lecture.usages.firstOrNull,
                    state: picked.value == null
                        ? ChoiceState.idle
                        : lecture.id == question.lecture.id
                        ? ChoiceState.right
                        : picked.value == lecture.id
                        ? ChoiceState.wrong
                        : ChoiceState.dimmed,
                    onTap: () => pick(lecture.id),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PairOption extends StatelessWidget {
  const _PairOption({
    required this.lecture,
    required this.usage,
    required this.state,
    required this.onTap,
  });

  final String lecture;
  final String? usage;
  final ChoiceState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final feedback = state == ChoiceState.right || state == ChoiceState.wrong;
    final foreground = feedback ? neo.onFeedback : neo.onCard;
    return Opacity(
      opacity: state == ChoiceState.dimmed ? 0.6 : 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            right: 5,
            child: NeoButton(
              onPressed: onTap,
              minHeight: 130,
              padding: const EdgeInsets.all(12),
              color: switch (state) {
                ChoiceState.right => neo.correctFill,
                ChoiceState.wrong => neo.wrongFill,
                _ => null,
              },
              child: const SizedBox.shrink(),
            ),
          ),
          IgnorePointer(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 22, 19, 22),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lecture,
                    textAlign: TextAlign.center,
                    style: _body(
                      context,
                      size: max(16, 26 - lecture.length * 0.6),
                    ).copyWith(color: foreground),
                  ),
                  if (state != ChoiceState.idle && usage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      usage!,
                      textAlign: TextAlign.center,
                      style: _muted(
                        context,
                        size: 12,
                      ).copyWith(color: foreground.withValues(alpha: 0.8)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (state == ChoiceState.right)
            const Positioned(top: -12, right: -6, child: RightMarker()),
          if (state == ChoiceState.wrong)
            const Positioned(top: -12, right: -6, child: MistakeMarker()),
        ],
      ),
    );
  }
}
