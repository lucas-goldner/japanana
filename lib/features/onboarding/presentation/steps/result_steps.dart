import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:japanana/core/application/clock_provider.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/features/onboarding/application/onboarding_provider.dart';
import 'package:japanana/features/onboarding/domain/demo_result.dart';
import 'package:japanana/features/onboarding/presentation/widgets/motion.dart';
import 'package:japanana/features/onboarding/presentation/widgets/onboarding_widgets.dart';
import 'package:japanana/features/settings/application/store_provider.dart';
import 'package:japanana/features/settings/data/external_actions.dart';
import 'package:japanana/features/settings/domain/store_catalog.dart';

const _kStampSlamDelay = Duration(milliseconds: 600);
const _kStampSlamDuration = Duration(milliseconds: 450);
const _kStampRed = Color(0xffD05557);

class SnapshotStep extends HookConsumerWidget {
  const SnapshotStep({required this.result, required this.onNext, super.key});

  final DemoResult? result;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    final level = ref.watch(onboardingProvider.select((a) => a.level));
    final year = ref.watch(clockProvider)().year;
    final slam = useDelayedProgress(
      delay: _kStampSlamDelay,
      duration: _kStampSlamDuration,
      curve: Curves.linear,
    );
    final result = this.result;
    final rows = [
      if (result != null)
        (
          l10n.onbSnapshotFirstTry,
          result.firstTry ? l10n.onbSnapshotRight : l10n.onbSnapshotMissed,
        ),
      (l10n.onbSnapshotLevel, level.label),
      if (result?.mixedUpWith case final mixedUp?)
        (l10n.onbSnapshotWatch, '${result!.lecture.title} / ${mixedUp.title}')
      else if (result?.nextLecture case final next?)
        (l10n.onbSnapshotNext, next.title),
    ];
    final row = context.onbBody.copyWith(fontSize: 15);

    return StepLayout(
      title: l10n.onbSnapshotTitle,
      titleAlign: TextAlign.center,
      body: Column(
        children: [
          const SizedBox(height: 26),
          Opacity(
            opacity: slam > 0 ? 1 : 0,
            child: Transform.rotate(
              angle:
                  (-14 + 10 * Curves.easeOutCubic.transform(slam)) * pi / 180,
              child: Transform.scale(
                scale: 1.8 - 0.8 * Curves.easeOutBack.transform(slam),
                child: SizedBox(
                  width: 190,
                  height: 228,
                  child: CustomPaint(
                    painter: _StampPainter(shadow: neo.shadow),
                    child: Padding(
                      padding: const EdgeInsets.all(26),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'JAPANANA · $year',
                            style: const TextStyle(
                              fontFamily: 'NotoSansJP',
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 1.6,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            '初',
                            style: TextStyle(
                              fontFamily: 'NotoSansJP',
                              fontWeight: FontWeight.bold,
                              fontSize: 88,
                              height: 1.15,
                              color: Colors.white,
                            ),
                          ),
                          FittedBox(
                            child: Text(
                              l10n.onbStampBottom,
                              style: const TextStyle(
                                fontFamily: 'NotoSansJP',
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.2,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Reveal(
            delay: const Duration(milliseconds: 1300),
            offset: const Offset(0, 30),
            child: Container(
              margin: EdgeInsets.only(right: neo.shadowOffset.dx),
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
              decoration: neo.decoration(),
              child: Column(
                children: [
                  for (final (label, value) in rows)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Text(label, style: row),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              value,
                              style: row,
                              textAlign: TextAlign.end,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
          if (result != null)
            Reveal(
              delay: const Duration(milliseconds: 1600),
              child: Builder(
                builder: (context) => OnboardingCta(
                  label: '${l10n.onbShareStamp} ↗',
                  style: CtaStyle.card,
                  onPressed: () {
                    final box = context.findRenderObject() as RenderBox?;
                    ref
                        .read(externalActionsProvider)
                        .shareText(
                          l10n.onbShareText(result.lecture.title),
                          shareOrigin: box == null
                              ? null
                              : box.localToGlobal(Offset.zero) & box.size,
                        );
                  },
                ),
              ),
            ),
          const SizedBox(height: 18),
        ],
      ),
      cta: Reveal(
        delay: const Duration(milliseconds: 1800),
        child: OnboardingCta(
          label: l10n.onbSeePlan,
          style: CtaStyle.ink,
          onPressed: onNext,
        ),
      ),
    );
  }
}

/// Red postage stamp with perforated edges and a dashed inner frame.
class _StampPainter extends CustomPainter {
  _StampPainter({required this.shadow});

  final Color shadow;

  @override
  void paint(Canvas canvas, Size size) {
    const hole = 6.0;
    const pitch = 19.0;
    var stamp = Path()..addRect(Offset.zero & size);
    final holes = Path();
    for (var x = pitch / 2; x < size.width; x += pitch) {
      holes
        ..addOval(Rect.fromCircle(center: Offset(x, 0), radius: hole))
        ..addOval(
          Rect.fromCircle(center: Offset(x, size.height), radius: hole),
        );
    }
    for (var y = pitch / 2; y < size.height; y += pitch) {
      holes
        ..addOval(Rect.fromCircle(center: Offset(0, y), radius: hole))
        ..addOval(Rect.fromCircle(center: Offset(size.width, y), radius: hole));
    }
    stamp = Path.combine(PathOperation.difference, stamp, holes);
    canvas
      ..drawPath(stamp.shift(const Offset(6, 6)), Paint()..color = shadow)
      ..drawPath(stamp, Paint()..color = _kStampRed);

    final frame = Rect.fromLTWH(16, 16, size.width - 32, size.height - 32);
    final dash = Paint()
      ..color = Colors.white.withValues(alpha: 0.7)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    for (final metric in (Path()..addRect(frame)).computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 10) {
        canvas.drawPath(metric.extractPath(d, d + 6), dash);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _StampPainter oldDelegate) =>
      oldDelegate.shadow != shadow;
}

class PlanStep extends HookConsumerWidget {
  const PlanStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    final plan = ref.watch(learningPlanProvider(null));
    final level = ref.watch(onboardingProvider.select((a) => a.level));
    final locale = Localizations.localeOf(context).toString();
    final line = useDelayedProgress(
      delay: const Duration(milliseconds: 1200),
      duration: const Duration(milliseconds: 1400),
      curve: Curves.easeInOutCubic,
    );
    final goal = useDelayedProgress(
      delay: const Duration(milliseconds: 2600),
      duration: const Duration(milliseconds: 400),
    );
    final pulse = useLoop(const Duration(milliseconds: 1050));

    return StepLayout(
      title: l10n.onbPlanTitle,
      subtitle: l10n.onbPlanSubtitle,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Reveal(
            delay: const Duration(milliseconds: 750),
            offset: const Offset(0, 10),
            blur: 14,
            child: Text(
              DateFormat.yMMMM(locale).format(plan.targetDate),
              style: context.onbBody.copyWith(fontSize: 44, height: 1.2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 26),
              child: Reveal(
                delay: const Duration(milliseconds: 900),
                child: Container(
                  margin: EdgeInsets.only(right: neo.shadowOffset.dx),
                  padding: const EdgeInsets.all(16),
                  decoration: neo.decoration(),
                  child: CustomPaint(
                    size: Size.infinite,
                    painter: _PlanCurvePainter(
                      progress: line,
                      goalOpacity: goal,
                      pulse: sin(pulse * 2 * pi) * goal,
                      ink: neo.onCard,
                      start: neo.accent,
                      end: _kStampRed,
                      dotBorder: neo.border,
                      startLabel: l10n.onbPlanToday(level.label),
                      endLabel: DateFormat.yMMM(locale).format(plan.targetDate),
                      goalLabel: l10n.onbPlanGoal,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      cta: OnboardingCta(label: l10n.onbPlanCta, onPressed: onNext),
    );
  }
}

/// Learning curve from today to natural conversations, drawn in over time.
class _PlanCurvePainter extends CustomPainter {
  _PlanCurvePainter({
    required this.progress,
    required this.goalOpacity,
    required this.pulse,
    required this.ink,
    required this.start,
    required this.end,
    required this.dotBorder,
    required this.startLabel,
    required this.endLabel,
    required this.goalLabel,
  });

  final double progress;
  final double goalOpacity;
  final double pulse;
  final Color ink;
  final Color start;
  final Color end;
  final Color dotBorder;
  final String startLabel;
  final String endLabel;
  final String goalLabel;

  void _label(
    Canvas canvas,
    String text,
    Offset anchor, {
    TextAlign align = TextAlign.left,
    double opacity = 1,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'NotoSansJP',
          fontWeight: FontWeight.bold,
          fontSize: 12,
          color: ink.withValues(alpha: opacity),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final dx = align == TextAlign.right ? anchor.dx - painter.width : anchor.dx;
    painter.paint(canvas, Offset(dx, anchor.dy));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height - 24;
    final axis = Paint()
      ..color = ink
      ..strokeWidth = 3;
    canvas.drawLine(Offset(0, h), Offset(w, h), axis);

    final from = Offset(8, h - 14);
    final to = Offset(w - 12, h * 0.14);
    final curve = Path()
      ..moveTo(from.dx, from.dy)
      ..cubicTo(w * 0.3, h * 0.92, w * 0.42, h * 0.72, w * 0.58, h * 0.5)
      ..cubicTo(w * 0.74, h * 0.28, w * 0.86, h * 0.16, to.dx, to.dy);
    final stroke = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    for (final metric in curve.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), stroke);
    }

    final border = Paint()
      ..color = dotBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas
      ..drawCircle(from, 8, Paint()..color = start)
      ..drawCircle(from, 8, border);
    if (goalOpacity > 0) {
      final radius = 10 + pulse * 2;
      canvas
        ..drawCircle(
          to,
          radius,
          Paint()..color = end.withValues(alpha: goalOpacity),
        )
        ..drawCircle(
          to,
          radius,
          border..color = dotBorder.withValues(alpha: goalOpacity),
        );
      _label(
        canvas,
        goalLabel,
        Offset(to.dx - 18, to.dy - 24),
        align: TextAlign.right,
        opacity: goalOpacity,
      );
    }
    _label(canvas, startLabel, Offset(0, h + 6));
    _label(canvas, endLabel, Offset(w, h + 6), align: TextAlign.right);
  }

  @override
  bool shouldRepaint(covariant _PlanCurvePainter oldDelegate) => true;
}

class PaywallStep extends HookConsumerWidget {
  const PaywallStep({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    final catalog = ref.watch(storeProvider).value;
    final plans = [...?catalog?.subscriptions]
      ..sort(
        (a, b) => (a.kind == StoreItemKind.yearly ? 0 : 1).compareTo(
          b.kind == StoreItemKind.yearly ? 0 : 1,
        ),
      );
    final canSubscribe = plans.isNotEmpty && !(catalog?.isSupporter ?? false);
    final selected = useState<String?>(null);
    final selectedPlan =
        plans.where((plan) => plan.id == selected.value).firstOrNull ??
        plans.firstOrNull;
    final busy = useState(false);

    Future<void> subscribe() async {
      final plan = selectedPlan;
      if (plan == null || busy.value) return;
      final messenger = ScaffoldMessenger.of(context);
      final failed = l10n.storeUnavailable;
      busy.value = true;
      try {
        if (await ref.read(storeProvider.notifier).purchase(plan)) {
          onFinished();
        }
      } on Exception {
        messenger.showSnackBar(SnackBar(content: Text(failed)));
      } finally {
        if (context.mounted) busy.value = false;
      }
    }

    final timeline = canSubscribe
        ? [
            (l10n.onbTrialToday, l10n.onbTrialTodayText),
            (l10n.onbTrialDay5, l10n.onbTrialDay5Text),
            (l10n.onbTrialDay7, l10n.onbTrialDay7Text),
          ]
        : [
            ('💬', l10n.onbFixCantSpeak),
            ('🧠', l10n.onbFixForget),
            ('🔀', l10n.onbFixMixUp),
          ];

    return StepLayout(
      topPadding: 24,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          Reveal(
            delay: const Duration(milliseconds: 200),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: neo
                      .decoration(
                        color: neo.accent,
                        shadowColor: neo.accentShadow,
                        borderRadius: BorderRadius.circular(12),
                      )
                      .copyWith(
                        boxShadow: [
                          BoxShadow(
                            color: neo.accentShadow,
                            offset: const Offset(3, 3),
                          ),
                        ],
                      ),
                  child: const Text('🍌', style: TextStyle(fontSize: 24)),
                ),
                const SizedBox(width: 10),
                Text(
                  'Japanana',
                  style: context.onbTitle.copyWith(fontSize: 24),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          BlurWords(
            l10n.onbPaywallTitle,
            style: context.onbTitle,
            delay: const Duration(milliseconds: 400),
          ),
          const SizedBox(height: 10),
          for (final (index, (label, text)) in timeline.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Reveal(
                delay: Duration(milliseconds: 1000 + index * 250),
                offset: const Offset(20, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (canSubscribe)
                      Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == 0 ? neo.accent : neo.card,
                          border: Border.all(color: neo.border, width: 3),
                        ),
                      )
                    else
                      SizedBox(
                        width: 30,
                        child: Text(
                          label,
                          style: const TextStyle(fontSize: 22),
                        ),
                      ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (canSubscribe)
                            Text(
                              label,
                              style: context.onbBody.copyWith(fontSize: 15),
                            ),
                          Text(
                            text,
                            style: canSubscribe
                                ? context.onbSubtitle.copyWith(fontSize: 13)
                                : context.onbBody.copyWith(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          if (canSubscribe) ...[
            const SizedBox(height: 10),
            for (final (index, plan) in plans.indexed)
              Padding(
                padding: const EdgeInsets.only(top: 18),
                child: Reveal(
                  delay: Duration(milliseconds: 1900 + index * 200),
                  offset: const Offset(0, 24),
                  child: _PlanCard(
                    plan: plan,
                    selected: plan.id == selectedPlan?.id,
                    bestValue: plan.kind == StoreItemKind.yearly,
                    onTap: () => selected.value = plan.id,
                  ),
                ),
              ),
          ],
        ],
      ),
      cta: Reveal(
        delay: const Duration(milliseconds: 2300),
        offset: const Offset(0, 24),
        child: canSubscribe
            ? Pulse(
                child: OnboardingCta(
                  label: l10n.onbStartTrial,
                  enabled: !busy.value,
                  onPressed: subscribe,
                ),
              )
            : OnboardingCta(label: l10n.onbContinue, onPressed: onFinished),
      ),
      secondary: canSubscribe
          ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OnboardingTextButton(
                  label: l10n.restorePurchases,
                  onPressed: () => ref.read(storeProvider.notifier).restore(),
                ),
                Text('·', style: context.onbSubtitle),
                OnboardingTextButton(
                  label: l10n.onbMaybeLater,
                  onPressed: onFinished,
                ),
              ],
            )
          : null,
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.bestValue,
    required this.onTap,
  });

  final StoreItem plan;
  final bool selected;
  final bool bestValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final neo = context.neo;
    final foreground = selected ? context.onbOnInk : neo.onCard;
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: EdgeInsets.only(right: neo.shadowOffset.dx),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: neo.decoration(
              color: selected ? context.onbInk : neo.card,
              shadowColor: selected ? neo.accentShadow : neo.shadow,
            ),
            child: Row(
              children: [
                Text(
                  plan.kind == StoreItemKind.yearly
                      ? l10n.subscriptionYearly
                      : l10n.subscriptionMonthly,
                  style: context.onbBody.copyWith(color: foreground),
                ),
                const Spacer(),
                Text(
                  plan.price,
                  style: context.onbBody.copyWith(color: foreground),
                ),
              ],
            ),
          ),
          if (bestValue)
            Positioned(
              top: -12,
              right: 18,
              child: NeoPill(
                label: l10n.onbBestValue,
                color: _kStampRed,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}
