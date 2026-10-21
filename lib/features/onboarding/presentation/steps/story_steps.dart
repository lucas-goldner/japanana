import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/features/onboarding/application/onboarding_provider.dart';
import 'package:japanana/features/onboarding/domain/onboarding_answers.dart';
import 'package:japanana/features/onboarding/presentation/widgets/motion.dart';
import 'package:japanana/features/onboarding/presentation/widgets/onboarding_widgets.dart';
import 'package:japanana/features/settings/data/external_actions.dart';

/// Daily minutes the comparisons assume before the learner picks their own.
const kComparisonMinutes = 10;
const _kReviewPromptDelay = Duration(milliseconds: 1800);
const _kHookSentence = 'バスが来なかったんです';

class HookStep extends StatelessWidget {
  const HookStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final neo = context.neo;
    final titleStyle = context.onbTitle.copyWith(fontSize: 38);
    Widget bubble(String text, int index, {bool ink = false}) => Reveal(
      delay: Duration(milliseconds: 200 + index * 350),
      duration: const Duration(milliseconds: 500),
      offset: const Offset(0, 20),
      scale: 0.25,
      blur: 0,
      curve: Curves.easeOutBack,
      child: Float(
        phase: index.toDouble(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: neo.decoration(
            color: ink ? context.onbInk : neo.card,
            shadowColor: ink ? neo.card : neo.shadow,
          ),
          child: Text(
            text,
            style: context.onbBody.copyWith(
              color: ink ? context.onbOnInk : neo.onCard,
            ),
          ),
        ),
      ),
    );

    return StepLayout(
      topPadding: 40,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          bubble(l10n.letsTalkAbout('んです'), 0),
          const SizedBox(height: 18),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: bubble(_kHookSentence, 1, ink: true),
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.only(left: 18),
            child: bubble(l10n.onbHookBubble, 2),
          ),
          const Spacer(),
          BlurWords(
            l10n.onbHookTitle,
            style: titleStyle,
            delay: const Duration(milliseconds: 1100),
          ),
          const SizedBox(height: 10),
          BlurWords(
            l10n.onbHookTitle2,
            style: titleStyle,
            delay: const Duration(milliseconds: 1600),
            highlightBuilder: (word) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: context.onbInk,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word,
                style: titleStyle.copyWith(color: context.onbOnInk),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
      cta: Reveal(
        delay: const Duration(milliseconds: 2300),
        offset: const Offset(0, 30),
        child: OnboardingCta(
          label: l10n.onbGetStarted,
          style: CtaStyle.ink,
          onPressed: onNext,
        ),
      ),
    );
  }
}

class MathStep extends ConsumerWidget {
  const MathStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final plan = ref.watch(learningPlanProvider(kComparisonMinutes));
    final dark = context.theme.brightness == Brightness.dark;
    final green = dark ? context.neo.correctFill : const Color(0xff1F8A44);
    final red = context.colorScheme.tertiary;
    final line = context.onbBody.copyWith(fontSize: 19);
    final big = context.onbBody.copyWith(fontSize: 64, height: 1.1);
    final unit = context.onbBody.copyWith(fontSize: 28);

    Widget number(
      int to,
      Color? color,
      String? suffix,
      Duration delay, {
      int from = 0,
    }) => Reveal(
      delay: delay - const Duration(milliseconds: 100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          RollingNumber(
            from: from,
            to: to,
            delay: delay,
            duration: const Duration(milliseconds: 1000),
            style: big.copyWith(color: color),
          ),
          if (suffix != null) ...[
            const SizedBox(width: 12),
            Flexible(
              child: Text(suffix, style: unit.copyWith(color: color)),
            ),
          ],
        ],
      ),
    );

    return StepLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            delay: const Duration(milliseconds: 200),
            child: Text(l10n.onbMathPointsLead, style: line),
          ),
          number(
            plan.totalPoints,
            null,
            null,
            const Duration(milliseconds: 400),
          ),
          Reveal(
            delay: const Duration(milliseconds: 600),
            child: Text(l10n.onbMathPointsTail, style: line),
          ),
          const SizedBox(height: 30),
          Reveal(
            delay: const Duration(milliseconds: 1400),
            child: Text(l10n.onbMathAloneLead, style: line),
          ),
          number(
            plan.monthsAlone,
            red,
            l10n.onbMonthsAway,
            const Duration(milliseconds: 1600),
          ),
          const SizedBox(height: 30),
          Reveal(
            delay: const Duration(milliseconds: 2500),
            child: Text(l10n.onbMathWithLead, style: line),
          ),
          number(
            plan.monthsWithJapanana,
            green,
            l10n.onbMonths,
            const Duration(milliseconds: 2700),
            from: plan.monthsAlone,
          ),
          const Spacer(),
          Reveal(
            delay: const Duration(milliseconds: 3000),
            child: Text(
              l10n.onbMathNote,
              style: context.onbSubtitle.copyWith(fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
      cta: Reveal(
        delay: const Duration(milliseconds: 3300),
        offset: const Offset(0, 30),
        child: OnboardingCta(
          label: l10n.onbMathCta,
          style: CtaStyle.ink,
          onPressed: onNext,
        ),
      ),
    );
  }
}

class FixStep extends ConsumerWidget {
  const FixStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final picked = ref.watch(onboardingProvider.select((a) => a.pains));
    final all = {
      OnboardingPain.cantSpeak: (
        l10n.onbPainCantSpeak,
        '💬',
        l10n.onbFixCantSpeak,
      ),
      OnboardingPain.textbook: (
        l10n.onbPainTextbook,
        '🎌',
        l10n.onbFixTextbook,
      ),
      OnboardingPain.forget: (l10n.onbPainForget, '🧠', l10n.onbFixForget),
      OnboardingPain.mixUp: (l10n.onbPainMixUp, '🔀', l10n.onbFixMixUp),
    };
    // Mirror back what the learner agreed with, or everything if nothing.
    final rows = [
      for (final MapEntry(:key, :value) in all.entries)
        if (picked.isEmpty || picked.contains(key)) value,
    ];
    return StepLayout(
      title: l10n.onbFixTitle,
      body: ListView(
        padding: const EdgeInsets.only(top: 12, bottom: 16),
        children: [
          for (final (index, (pain, emoji, fix)) in rows.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: _FixRow(
                pain: pain,
                emoji: emoji,
                fix: fix,
                delay: Duration(milliseconds: 600 + index * 550),
              ),
            ),
        ],
      ),
      cta: OnboardingCta(label: l10n.onbContinue, onPressed: onNext),
    );
  }
}

class _FixRow extends HookWidget {
  const _FixRow({
    required this.pain,
    required this.emoji,
    required this.fix,
    required this.delay,
  });

  final String pain;
  final String emoji;
  final String fix;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final strike = useDelayedProgress(
      delay: delay + const Duration(milliseconds: 350),
      duration: const Duration(milliseconds: 350),
    );
    return Reveal(
      delay: delay,
      offset: const Offset(30, 0),
      child: Container(
        margin: EdgeInsets.only(right: neo.shadowOffset.dx),
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
        decoration: neo.decoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomPaint(
              foregroundPainter: _StrikePainter(
                progress: strike,
                color: context.colorScheme.tertiary,
              ),
              child: Text(
                pain,
                style: context.onbSubtitle.copyWith(fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Reveal(
              delay: delay + const Duration(milliseconds: 550),
              offset: const Offset(20, 0),
              child: Row(
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      fix,
                      style: context.onbBody.copyWith(fontSize: 17),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Line drawn through the middle of every text line of its child.
class _StrikePainter extends CustomPainter {
  _StrikePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.5;
    const lineHeight = 14 * 1.45;
    final lines = max(1, (size.height / lineHeight).round());
    for (var i = 0; i < lines; i++) {
      final lineProgress = (progress * lines - i).clamp(0.0, 1.0);
      if (lineProgress == 0) break;
      final y = lineHeight * (i + 0.55);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * lineProgress, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StrikePainter oldDelegate) =>
      oldDelegate.progress != progress || oldDelegate.color != color;
}

class CompareStep extends HookConsumerWidget {
  const CompareStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    final plan = ref.watch(learningPlanProvider(kComparisonMinutes));
    final alone = useDelayedProgress(
      delay: const Duration(milliseconds: 800),
      duration: const Duration(milliseconds: 900),
    );
    final withApp = useDelayedProgress(
      delay: const Duration(milliseconds: 1400),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutBack,
    );
    final ratio = plan.monthsWithJapanana / plan.monthsAlone;

    Widget bar({
      required double fraction,
      required double progress,
      required Color color,
      required String value,
      required String label,
      required Duration valueDelay,
    }) => Expanded(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxHeight = constraints.maxHeight - 110;
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Reveal(
                delay: valueDelay,
                child: Text(
                  value,
                  style: context.onbBody.copyWith(fontSize: 22),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                height: max(0, maxHeight * fraction * progress),
                margin: EdgeInsets.only(right: neo.shadowOffset.dx),
                decoration: neo.decoration(
                  color: color,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: context.onbBody.copyWith(fontSize: 14),
                ),
              ),
            ],
          );
        },
      ),
    );

    return StepLayout(
      title: l10n.onbCompareTitle,
      subtitle: l10n.onbCompareSubtitle,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 30, 16, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            bar(
              fraction: 1,
              progress: alone,
              color: neo.card,
              value: l10n.onbMonthsShort(plan.monthsAlone),
              label: l10n.onbCompareAlone,
              valueDelay: const Duration(milliseconds: 1400),
            ),
            const SizedBox(width: 36),
            bar(
              fraction: max(ratio, 0.12),
              progress: withApp,
              color: neo.accent,
              value: l10n.onbMonthsShort(plan.monthsWithJapanana),
              label: l10n.onbCompareWith,
              valueDelay: const Duration(milliseconds: 2000),
            ),
          ],
        ),
      ),
      cta: OnboardingCta(label: l10n.onbContinue, onPressed: onNext),
    );
  }
}

class ProofStep extends HookConsumerWidget {
  const ProofStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    useEffect(() {
      // Asked once while the learner is feeling understood. The system
      // decides whether the prompt shows.
      final timer = Timer(_kReviewPromptDelay, () {
        final notifier = ref.read(onboardingProvider.notifier);
        if (notifier.reviewRequested) return;
        notifier.reviewRequested = true;
        ref.read(externalActionsProvider).requestReview();
      });
      return timer.cancel;
    }, const []);
    final reviews = [
      (l10n.onbReview1Tag, l10n.onbReview1),
      (l10n.onbReview2Tag, l10n.onbReview2),
      (l10n.onbReview3Tag, l10n.onbReview3),
    ];
    return StepLayout(
      title: l10n.onbProofTitle,
      body: ListView(
        padding: const EdgeInsets.only(top: 10, bottom: 16),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Reveal(
              delay: const Duration(milliseconds: 450),
              child: NeoPill(label: l10n.onbProofSample),
            ),
          ),
          for (final (index, (tag, quote)) in reviews.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Reveal(
                delay: Duration(milliseconds: 650 + index * 250),
                offset: const Offset(0, 30),
                rotation: index.isOdd ? 3 : -3,
                child: Container(
                  margin: EdgeInsets.only(right: neo.shadowOffset.dx),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                  decoration: neo.decoration(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          NeoPill(
                            label: tag,
                            color: neo.accent,
                            foregroundColor: neo.onAccent,
                          ),
                          const Spacer(),
                          const Text(
                            '★★★★★',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xffE8A800),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        quote,
                        style: context.onbBody.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.normal,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      cta: OnboardingCta(label: l10n.onbContinue, onPressed: onNext),
    );
  }
}
