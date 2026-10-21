import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/application/clock_provider.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/application/random_provider.dart';
import 'package:japanana/core/application/statistics_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/features/onboarding/application/onboarding_provider.dart';
import 'package:japanana/features/onboarding/domain/demo_result.dart';
import 'package:japanana/features/onboarding/presentation/widgets/motion.dart';
import 'package:japanana/features/onboarding/presentation/widgets/onboarding_widgets.dart';
import 'package:japanana/features/statistics/application/study_log_provider.dart';

const _kOptionCount = 3;

/// Examples longer than this make the first conversation feel heavy.
const _kMaxExampleLength = 22;
const _kBubbleDelay = Duration(milliseconds: 700);

/// A lecture of the learner's level and the usages offered for it.
typedef _Question = ({
  Lecture lecture,
  List<({String usage, Lecture owner})> options,
  Lecture? next,
});

_Question? _pickQuestion(List<Lecture> lectures, LectureType book, Random r) {
  final usable = lectures
      .where((l) => l.usages.isNotEmpty && l.examples.isNotEmpty)
      .toList();
  final ofBook = usable.where((l) => l.types.contains(book)).toList();
  if (ofBook.isEmpty) return null;
  final short = ofBook
      .where((l) => l.examples.first.length <= _kMaxExampleLength)
      .toList();
  final pool = short.isEmpty ? ofBook : short;
  final lecture = pool[r.nextInt(pool.length)];
  final others =
      (ofBook.length > _kOptionCount ? ofBook : usable)
          .where((l) => l.id != lecture.id)
          .toList()
        ..shuffle(r);
  final options = [
    (usage: lecture.usages.first, owner: lecture),
    for (final other in others.take(_kOptionCount - 1))
      (usage: other.usages.first, owner: other),
  ]..shuffle(r);
  return (
    lecture: lecture,
    options: options,
    next: others.length >= _kOptionCount ? others[_kOptionCount - 1] : null,
  );
}

class DemoStep extends HookConsumerWidget {
  const DemoStep({required this.onFinished, super.key});

  final ValueChanged<DemoResult> onFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    final lectures = ref.watch(lectureProvider);
    final level = ref.watch(onboardingProvider.select((a) => a.level));
    final random = ref.watch(randomProvider);
    final question = useMemoized(
      () => _pickQuestion(lectures, level.startingBook, random),
      [lectures.isEmpty, level],
    );
    final start = useMemoized(() => ref.read(clockProvider)());
    final wrongPicks = useState<List<int>>([]);
    final answered = useState(false);

    useEffect(() {
      if (lectures.isEmpty) {
        ref.read(lectureProvider.notifier).fetchLectures();
      }
      return null;
    }, const []);

    if (question == null) {
      return const StepLayout(body: SizedBox.shrink());
    }

    Future<void> pick(int index) async {
      if (answered.value || wrongPicks.value.contains(index)) return;
      final option = question.options[index];
      final correct = option.owner.id == question.lecture.id;
      final studyLog = ref.read(studyLogProvider.notifier);
      await studyLog.recordAnswer(
        lectureId: question.lecture.id,
        correct: correct,
        firstAttempt: wrongPicks.value.isEmpty,
        pickedLectureId: correct ? null : option.owner.id,
      );
      if (correct) {
        answered.value = true;
        await studyLog.recordSession(start: start, cardsCompleted: 1);
      } else {
        wrongPicks.value = [...wrongPicks.value, index];
        await ref
            .read(mistakenLecturesProvider.notifier)
            .addMistake(question.lecture.id);
      }
    }

    final mixedUp = wrongPicks.value.isEmpty
        ? null
        : question.options[wrongPicks.value.first].owner;

    return Stack(
      children: [
        StepLayout(
          topPadding: kOnboardingChromeHeight + 52,
          body: SingleChildScrollView(
            padding: const EdgeInsets.only(top: 20, bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Bubble(
                  text: l10n.letsTalkAbout(question.lecture.title),
                  delay: const Duration(milliseconds: 300),
                ),
                const SizedBox(height: 14),
                _Bubble(
                  text: l10n.whichKindOfUsage,
                  delay: const Duration(milliseconds: 900),
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: answered.value
                      ? _Answer(
                          key: const ValueKey('answer'),
                          usage: question.lecture.usages.first,
                          example: question.lecture.examples.first,
                          translation: question.lecture.translations.isEmpty
                              ? null
                              : question.lecture.translations.first,
                          praise: l10n.onbDemoGood,
                        )
                      : Column(
                          key: const ValueKey('options'),
                          children: [
                            for (final (index, option)
                                in question.options.indexed)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Reveal(
                                  delay: Duration(
                                    milliseconds: 1400 + index * 150,
                                  ),
                                  offset: const Offset(0, 40),
                                  blur: 0,
                                  child: _UsageOption(
                                    usage: option.usage,
                                    wrong: wrongPicks.value.contains(index),
                                    onTap: () => pick(index),
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
          cta: answered.value
              ? Reveal(
                  delay: _kBubbleDelay * 3 + const Duration(milliseconds: 300),
                  offset: const Offset(0, 30),
                  child: OnboardingCta(
                    label: l10n.onbContinue,
                    style: CtaStyle.ink,
                    onPressed: () => onFinished(
                      DemoResult(
                        lecture: question.lecture,
                        firstTry: wrongPicks.value.isEmpty,
                        mixedUpWith: mixedUp,
                        nextLecture: question.next,
                      ),
                    ),
                  ),
                )
              : null,
        ),
        // Chat header below the progress bar, like the review screen.
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: kOnboardingChromeHeight),
            child: Container(
              height: 52,
              width: double.infinity,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: neo.border, width: neo.borderWidth),
                  bottom: BorderSide(color: neo.border, width: neo.borderWidth),
                ),
                color: context.colorScheme.secondary,
              ),
              child: Text(
                l10n.onbDemoTitle,
                style: context.onbTitle.copyWith(fontSize: 21),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.delay, this.user = false});

  final String text;
  final Duration delay;
  final bool user;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    const radius = Radius.circular(14);
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Reveal(
        delay: delay,
        duration: const Duration(milliseconds: 450),
        offset: const Offset(0, 10),
        scale: 0.2,
        blur: 0,
        curve: Curves.easeOutBack,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 290),
          margin: EdgeInsets.only(right: neo.shadowOffset.dx),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: neo.decoration(
            color: user ? neo.accent : neo.card,
            shadowColor: user ? neo.accentShadow : neo.shadow,
            borderRadius: BorderRadius.only(
              topLeft: radius,
              topRight: radius,
              bottomLeft: user ? radius : Radius.zero,
              bottomRight: user ? Radius.zero : radius,
            ),
          ),
          child: Text(
            text,
            style: context.onbBody.copyWith(
              color: user ? neo.onAccent : neo.onCard,
            ),
          ),
        ),
      ),
    );
  }
}

class _UsageOption extends StatelessWidget {
  const _UsageOption({
    required this.usage,
    required this.wrong,
    required this.onTap,
  });

  final String usage;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            margin: EdgeInsets.only(right: neo.shadowOffset.dx),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: neo.decoration(color: wrong ? neo.wrongFill : neo.card),
            child: Text(
              usage,
              style: context.onbBody.copyWith(
                fontSize: 15,
                color: wrong ? neo.onFeedback : neo.onCard,
                decoration: wrong ? TextDecoration.lineThrough : null,
                decorationThickness: 2,
              ),
            ),
          ),
          if (wrong)
            Positioned(
              right: -6,
              top: -14,
              child: Reveal(
                duration: const Duration(milliseconds: 350),
                offset: Offset.zero,
                scale: 0.6,
                blur: 0,
                rotation: -40,
                curve: Curves.easeOutBack,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xffE53935),
                    shape: BoxShape.circle,
                    border: Border.all(color: neo.border, width: 3),
                  ),
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// The learner's answer followed by the lecture's example.
class _Answer extends StatelessWidget {
  const _Answer({
    required this.usage,
    required this.example,
    required this.translation,
    required this.praise,
    super.key,
  });

  final String usage;
  final String example;
  final String? translation;
  final String praise;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _Bubble(text: usage, delay: Duration.zero, user: true),
      const SizedBox(height: 14),
      _Bubble(text: example, delay: _kBubbleDelay),
      if (translation != null) ...[
        const SizedBox(height: 14),
        _Bubble(text: translation!, delay: _kBubbleDelay * 2, user: true),
      ],
      const SizedBox(height: 24),
      Center(
        child: Reveal(
          delay: _kBubbleDelay * 3,
          offset: Offset.zero,
          scale: 0.3,
          blur: 0,
          curve: Curves.easeOutBack,
          child: NeoPill(
            label: praise,
            fontSize: 14,
            uppercase: false,
            color: context.neo.correctFill,
            foregroundColor: context.neo.onFeedback,
          ),
        ),
      ),
    ],
  );
}
