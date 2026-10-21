import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/features/onboarding/application/onboarding_provider.dart';
import 'package:japanana/features/onboarding/domain/onboarding_answers.dart';
import 'package:japanana/features/onboarding/presentation/widgets/motion.dart';
import 'package:japanana/features/onboarding/presentation/widgets/onboarding_widgets.dart';

const _kOptionDelay = Duration(milliseconds: 650);
const _kOptionStagger = Duration(milliseconds: 90);
const _kCardFlyDuration = Duration(milliseconds: 320);
const _kSwipeThreshold = 90.0;
const _kMaxYears = 10;
const _kMinuteChoices = [5, 10, 15, 20];

/// Colors of the level books, from N5 to N1.
const kLevelColors = [
  Color(0xff45A099),
  Color(0xff87BF29),
  Color(0xffFA9716),
  Color(0xffF64A69),
  Color(0xff8F50E9),
];

class GoalStep extends ConsumerWidget {
  const GoalStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final goal = ref.watch(onboardingProvider.select((a) => a.goal));
    final options = [
      (OnboardingGoal.talk, '🗣', l10n.onbGoalTalk),
      (OnboardingGoal.travel, '✈️', l10n.onbGoalTravel),
      (OnboardingGoal.anime, '📺', l10n.onbGoalAnime),
      (OnboardingGoal.work, '💼', l10n.onbGoalWork),
      (OnboardingGoal.jlpt, '📝', l10n.onbGoalJlpt),
    ];
    return StepLayout(
      title: l10n.onbGoalTitle,
      subtitle: l10n.onbGoalSubtitle,
      body: ListView(
        padding: const EdgeInsets.only(top: 14, bottom: 16),
        children: [
          for (final (index, (value, emoji, label)) in options.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Reveal(
                delay: _kOptionDelay + _kOptionStagger * index,
                offset: const Offset(30, 0),
                blur: 6,
                child: OnboardingOption(
                  emoji: emoji,
                  label: label,
                  selected: goal == value,
                  onTap: () => ref
                      .read(onboardingProvider.notifier)
                      .update((answers) => answers.copyWith(goal: value)),
                ),
              ),
            ),
        ],
      ),
      cta: OnboardingCta(
        label: l10n.onbContinue,
        enabled: goal != null,
        onPressed: onNext,
      ),
    );
  }
}

class LevelStep extends HookConsumerWidget {
  const LevelStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final level = ref.watch(onboardingProvider.select((a) => a.level));
    final controller = usePageController(
      initialPage: level.index,
      viewportFraction: 0.6,
    );
    final descriptions = [
      l10n.onbLevelN5,
      l10n.onbLevelN4,
      l10n.onbLevelN3,
      l10n.onbLevelN2,
      l10n.onbLevelN1,
    ];
    return StepLayout(
      title: l10n.onbLevelTitle,
      subtitle: l10n.onbLevelSubtitle,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 320,
            child: Reveal(
              delay: const Duration(milliseconds: 500),
              offset: const Offset(80, 0),
              blur: 6,
              child: OverflowBox(
                maxWidth: MediaQuery.sizeOf(context).width,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    final page =
                        controller.hasClients &&
                            controller.position.haveDimensions
                        ? controller.page ?? level.index.toDouble()
                        : level.index.toDouble();
                    return PageView.builder(
                      controller: controller,
                      itemCount: JlptLevel.values.length,
                      onPageChanged: (index) => ref
                          .read(onboardingProvider.notifier)
                          .update(
                            (answers) => answers.copyWith(
                              level: JlptLevel.values[index],
                            ),
                          ),
                      itemBuilder: (context, index) {
                        final distance = index - page;
                        final near = distance.abs().clamp(0.0, 1.0);
                        return Opacity(
                          opacity: 1 - distance.abs().clamp(0.0, 1.5) * 0.35,
                          child: Transform.rotate(
                            angle: distance * 4 * pi / 180,
                            child: Transform.scale(
                              scale: 1 - near * 0.12,
                              child: GestureDetector(
                                onTap: () => controller.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOutCubic,
                                ),
                                child: _LevelBook(
                                  level: JlptLevel.values[index],
                                  description: descriptions[index],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final value in JlptLevel.values)
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 12,
                  height: 12,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value == level
                        ? context.neo.border
                        : context.neo.card,
                    border: Border.all(color: context.neo.border, width: 2),
                  ),
                ),
            ],
          ),
        ],
      ),
      cta: OnboardingCta(
        label: l10n.onbLevelConfirm,
        style: CtaStyle.ink,
        onPressed: onNext,
      ),
    );
  }
}

class _LevelBook extends StatelessWidget {
  const _LevelBook({required this.level, required this.description});

  final JlptLevel level;
  final String description;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return Container(
      margin: const EdgeInsets.fromLTRB(9, 10, 14, 15),
      decoration: neo.decoration(color: kLevelColors[level.index]),
      clipBehavior: Clip.antiAlias,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(width: 22, color: Colors.black.withValues(alpha: 0.18)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 14, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    level.label,
                    style: const TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.bold,
                      fontSize: 68,
                      height: 1.1,
                      color: Colors.white,
                      shadows: [Shadow(offset: Offset(3, 3))],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    description,
                    style: const TextStyle(
                      fontFamily: 'NotoSansJP',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      height: 1.35,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class YearsStep extends HookConsumerWidget {
  const YearsStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final years = ref.watch(onboardingProvider.select((a) => a.years));
    final controller = usePageController(
      initialPage: years,
      viewportFraction: 0.3,
    );
    final style = context.onbBody.copyWith(fontSize: 22);
    return StepLayout(
      title: l10n.onbYearsTitle,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Reveal(
            delay: const Duration(milliseconds: 500),
            child: Text(l10n.onbYearsLead, style: style),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 150,
            child: Reveal(
              delay: const Duration(milliseconds: 650),
              offset: const Offset(60, 0),
              child: OverflowBox(
                maxWidth: MediaQuery.sizeOf(context).width,
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (context, _) {
                    final page =
                        controller.hasClients &&
                            controller.position.haveDimensions
                        ? controller.page ?? years.toDouble()
                        : years.toDouble();
                    return PageView.builder(
                      controller: controller,
                      itemCount: _kMaxYears + 1,
                      onPageChanged: (index) => ref
                          .read(onboardingProvider.notifier)
                          .update((answers) => answers.copyWith(years: index)),
                      itemBuilder: (context, index) {
                        final distance = (index - page).abs();
                        return GestureDetector(
                          onTap: () => controller.animateToPage(
                            index,
                            duration: const Duration(milliseconds: 350),
                            curve: Curves.easeOutCubic,
                          ),
                          child: Center(
                            child: Opacity(
                              opacity: 1 - distance.clamp(0.0, 2.0) * 0.42,
                              child: Transform.scale(
                                scale: 1 - distance.clamp(0.0, 1.0) * 0.35,
                                child: FittedBox(
                                  child: Text(
                                    index == _kMaxYears ? '$index+' : '$index',
                                    style: context.onbBody.copyWith(
                                      fontSize: 112,
                                      height: 1.2,
                                      color: distance < 0.5
                                          ? context.neo.onCard
                                          : context.neo.onCard.withValues(
                                              alpha: 0.4,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Reveal(
            delay: const Duration(milliseconds: 800),
            child: Text(l10n.onbYearsUnit(years), style: style),
          ),
        ],
      ),
      cta: OnboardingCta(label: l10n.onbContinue, onPressed: onNext),
    );
  }
}

class GapStep extends HookConsumerWidget {
  const GapStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    final value = ref.watch(
      onboardingProvider.select((a) => a.speakingConfidence),
    );
    void set(double next) => ref
        .read(onboardingProvider.notifier)
        .update(
          (answers) =>
              answers.copyWith(speakingConfidence: next.clamp(0.0, 1.0)),
        );
    final label = value > 0.66
        ? l10n.onbGapNaturalLabel
        : value > 0.33
        ? l10n.onbGapTranslateLabel
        : l10n.onbGapFreezeLabel;
    final small = context.onbBody.copyWith(fontSize: 13);
    return StepLayout(
      title: l10n.onbGapTitle,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Reveal(
            delay: const Duration(milliseconds: 500),
            scale: 0.4,
            offset: Offset.zero,
            blur: 0,
            curve: Curves.easeOutBack,
            child: SizedBox.square(
              dimension: 190,
              child: CustomPaint(
                painter: _FacePainter(
                  mood: value * 2 - 1,
                  fill: neo.accent,
                  ink: neo.onAccent,
                  shadow: neo.shadow,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth - 38;
              void fromDx(double dx) => set((dx - 19) / width);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapDown: (details) => fromDx(details.localPosition.dx),
                onHorizontalDragUpdate: (details) =>
                    fromDx(details.localPosition.dx),
                child: SizedBox(
                  height: 44,
                  child: Stack(
                    alignment: Alignment.centerLeft,
                    children: [
                      Container(
                        height: 16,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: neo.card,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: neo.border, width: 3),
                        ),
                      ),
                      Positioned(
                        left: value * width,
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: neo.decoration(
                            color: neo.accent,
                            shadowColor: neo.accentShadow,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: Text('${l10n.onbGapFreeze} 🥶', style: small)),
              Expanded(
                child: Text(
                  l10n.onbGapTranslate,
                  style: small,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Text(
                  l10n.onbGapNatural,
                  style: small,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              label,
              key: ValueKey(label),
              textAlign: TextAlign.center,
              style: context.onbBody.copyWith(fontSize: 20),
            ),
          ),
        ],
      ),
      cta: OnboardingCta(label: l10n.onbContinue, onPressed: onNext),
    );
  }
}

/// Round face whose mouth goes from a frown at -1 to a smile at 1.
class _FacePainter extends CustomPainter {
  _FacePainter({
    required this.mood,
    required this.fill,
    required this.ink,
    required this.shadow,
  });

  final double mood;
  final Color fill;
  final Color ink;
  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 200;
    final center = Offset(100 * unit, 100 * unit);
    canvas
      ..drawCircle(
        center + Offset(6 * unit, 6 * unit),
        88 * unit,
        Paint()..color = shadow,
      )
      ..drawCircle(center, 88 * unit, Paint()..color = fill)
      ..drawCircle(
        center,
        88 * unit,
        Paint()
          ..color = ink
          ..style = PaintingStyle.stroke
          ..strokeWidth = 7 * unit,
      )
      ..drawCircle(
        Offset(70 * unit, 85 * unit),
        10 * unit,
        Paint()..color = ink,
      )
      ..drawCircle(
        Offset(130 * unit, 85 * unit),
        10 * unit,
        Paint()..color = ink,
      );
    final mouth = Path()
      ..moveTo(60 * unit, (132 - mood * 4) * unit)
      ..quadraticBezierTo(
        100 * unit,
        (132 + mood * 26) * unit,
        140 * unit,
        (132 - mood * 4) * unit,
      );
    canvas.drawPath(
      mouth,
      Paint()
        ..color = ink
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8 * unit
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant _FacePainter oldDelegate) =>
      oldDelegate.mood != mood ||
      oldDelegate.fill != fill ||
      oldDelegate.ink != ink ||
      oldDelegate.shadow != shadow;
}

class PainsStep extends HookConsumerWidget {
  const PainsStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    final pains = [
      (OnboardingPain.cantSpeak, l10n.onbPainCantSpeak),
      (OnboardingPain.textbook, l10n.onbPainTextbook),
      (OnboardingPain.forget, l10n.onbPainForget),
      (OnboardingPain.mixUp, l10n.onbPainMixUp),
    ];
    final index = useState(0);
    final drag = useState(Offset.zero);
    final flyTarget = useState<Offset?>(null);
    final fly = useAnimationController(duration: _kCardFlyDuration);
    final flyProgress = useAnimation(
      CurvedAnimation(parent: fly, curve: Curves.easeInCubic),
    );
    final width = MediaQuery.sizeOf(context).width;

    Future<void> decide({required bool agreed}) async {
      if (flyTarget.value != null || index.value >= pains.length) return;
      final pain = pains[index.value].$1;
      flyTarget.value = Offset(agreed ? width * 1.2 : -width * 1.2, -40);
      await ref
          .read(onboardingProvider.notifier)
          .togglePain(pain, agreed: agreed);
      await fly.forward(from: 0);
      drag.value = Offset.zero;
      flyTarget.value = null;
      fly.reset();
      if (index.value == pains.length - 1) {
        onNext();
      } else {
        index.value++;
      }
    }

    final topOffset = flyTarget.value == null
        ? drag.value
        : Offset.lerp(drag.value, flyTarget.value, flyProgress)!;
    final agreeing =
        flyTarget.value?.dx.isNegative == false ||
        (flyTarget.value == null && drag.value.dx > 0);
    final stampOpacity = flyTarget.value != null
        ? (agreeing ? 1.0 : 0.0)
        : (drag.value.dx / _kSwipeThreshold).clamp(0.0, 1.0);

    return StepLayout(
      title: l10n.onbPainsTitle,
      subtitle: l10n.onbPainsSubtitle,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(14, 28, 14, 28),
        child: Reveal(
          delay: const Duration(milliseconds: 500),
          offset: const Offset(0, 40),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              for (
                var i = min(index.value + 2, pains.length - 1);
                i >= index.value;
                i--
              )
                Builder(
                  builder: (context) {
                    final depth = i - index.value;
                    final isTop = depth == 0;
                    final card = _PainCard(
                      text: '“${pains[i].$2}”',
                      stampLabel: l10n.onbPainAgree,
                      stampOpacity: isTop ? stampOpacity : 0,
                    );
                    if (!isTop) {
                      return Positioned.fill(
                        child: Transform.translate(
                          offset: Offset(0, depth * 14.0),
                          child: Transform.rotate(
                            angle: (i.isOdd ? 3 : -3) * pi / 180,
                            child: Transform.scale(
                              scale: 1 - depth * 0.05,
                              child: card,
                            ),
                          ),
                        ),
                      );
                    }
                    return Positioned.fill(
                      child: GestureDetector(
                        onPanUpdate: (details) => drag.value += details.delta,
                        onPanEnd: (_) {
                          if (drag.value.dx.abs() > _kSwipeThreshold) {
                            decide(agreed: drag.value.dx > 0);
                          } else {
                            drag.value = Offset.zero;
                          }
                        },
                        child: Transform.translate(
                          offset: topOffset,
                          child: Transform.rotate(
                            angle: topOffset.dx / width * 22 * pi / 180,
                            child: card,
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      cta: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _RoundButton(
            icon: Icons.close,
            color: neo.wrongFill,
            onPressed: () => decide(agreed: false),
          ),
          const SizedBox(width: 40),
          _RoundButton(
            icon: Icons.check,
            color: neo.correctFill,
            onPressed: () => decide(agreed: true),
          ),
        ],
      ),
    );
  }
}

class _PainCard extends StatelessWidget {
  const _PainCard({
    required this.text,
    required this.stampLabel,
    required this.stampOpacity,
  });

  final String text;
  final String stampLabel;
  final double stampOpacity;

  @override
  Widget build(BuildContext context) {
    const stampColor = Color(0xff2E9A4B);
    return Container(
      decoration: context.neo.decoration(),
      padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 34),
      child: Stack(
        children: [
          Center(
            child: Text(
              text,
              style: context.onbBody.copyWith(fontSize: 25, height: 1.35),
            ),
          ),
          Positioned(
            top: -10,
            right: -6,
            child: Opacity(
              opacity: stampOpacity,
              child: Transform.rotate(
                angle: 12 * pi / 180,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.neo.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: stampColor, width: 3),
                  ),
                  child: Text(
                    stampLabel,
                    style: const TextStyle(
                      fontFamily: 'NotoSansJP',
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
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: 76,
    child: NeoButton(
      onPressed: onPressed,
      color: color,
      minHeight: 76,
      padding: EdgeInsets.zero,
      child: Icon(icon, size: 34, color: context.neo.onFeedback),
    ),
  );
}

class RhythmStep extends HookConsumerWidget {
  const RhythmStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    final minutes = ref.watch(onboardingProvider.select((a) => a.dailyMinutes));
    final intro = useDelayedProgress(
      duration: const Duration(milliseconds: 1100),
      delay: const Duration(milliseconds: 700),
      curve: Curves.easeInOutCubic,
    );
    return StepLayout(
      title: l10n.onbRhythmTitle,
      subtitle: l10n.onbRhythmSubtitle,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Reveal(
            delay: const Duration(milliseconds: 450),
            scale: 0.3,
            offset: Offset.zero,
            blur: 0,
            curve: Curves.easeOutBack,
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: minutes.toDouble()),
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                final shown = value * intro;
                return SizedBox.square(
                  dimension: 230,
                  child: CustomPaint(
                    painter: _DialPainter(
                      fraction: shown / _kMinuteChoices.last,
                      card: neo.card,
                      border: neo.border,
                      shadow: neo.shadow,
                      arc: neo.correctFill,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${shown.round()}',
                          style: context.onbBody.copyWith(
                            fontSize: 54,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          l10n.onbMinPerDay,
                          style: context.onbBody.copyWith(
                            fontSize: 13,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 34),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (final (index, choice) in _kMinuteChoices.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Reveal(
                    delay:
                        const Duration(milliseconds: 800) +
                        const Duration(milliseconds: 80) * index,
                    child: GestureDetector(
                      onTap: () => ref
                          .read(onboardingProvider.notifier)
                          .update(
                            (answers) => answers.copyWith(dailyMinutes: choice),
                          ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 62,
                        height: 46,
                        alignment: Alignment.center,
                        decoration: neo
                            .decoration(
                              color: choice == minutes
                                  ? context.onbInk
                                  : neo.card,
                              shadowColor: choice == minutes
                                  ? neo.accentShadow
                                  : neo.shadow,
                            )
                            .copyWith(
                              boxShadow: [
                                BoxShadow(
                                  color: choice == minutes
                                      ? neo.accentShadow
                                      : neo.shadow,
                                  offset: const Offset(3, 3),
                                ),
                              ],
                            ),
                        child: Text(
                          '$choice',
                          style: context.onbBody.copyWith(
                            color: choice == minutes
                                ? context.onbOnInk
                                : neo.onCard,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      cta: OnboardingCta(
        label: l10n.onbRhythmCta,
        style: CtaStyle.ink,
        onPressed: onNext,
      ),
    );
  }
}

/// Ring that fills to [fraction] around the daily minutes.
class _DialPainter extends CustomPainter {
  _DialPainter({
    required this.fraction,
    required this.card,
    required this.border,
    required this.shadow,
    required this.arc,
  });

  final double fraction;
  final Color card;
  final Color border;
  final Color shadow;
  final Color arc;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 240;
    final center = size.center(Offset.zero);
    final outline = Paint()
      ..color = border
      ..style = PaintingStyle.stroke;
    canvas
      ..drawCircle(
        center + Offset(6 * unit, 6 * unit),
        100 * unit,
        Paint()..color = shadow,
      )
      ..drawCircle(center, 100 * unit, Paint()..color = card)
      ..drawCircle(center, 100 * unit, outline..strokeWidth = 6 * unit)
      ..drawArc(
        Rect.fromCircle(center: center, radius: 84 * unit),
        -pi / 2,
        2 * pi * fraction.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = arc
          ..style = PaintingStyle.stroke
          ..strokeWidth = 22 * unit,
      )
      ..drawCircle(center, 66 * unit, Paint()..color = card)
      ..drawCircle(center, 66 * unit, outline..strokeWidth = 4 * unit);
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) =>
      oldDelegate.fraction != fraction ||
      oldDelegate.card != card ||
      oldDelegate.border != border ||
      oldDelegate.arc != arc;
}
