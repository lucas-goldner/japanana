import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/features/onboarding/application/onboarding_provider.dart';
import 'package:japanana/features/onboarding/presentation/widgets/motion.dart';
import 'package:japanana/features/onboarding/presentation/widgets/onboarding_widgets.dart';
import 'package:japanana/features/settings/application/app_settings_provider.dart';

/// Evening time suggested for the daily reminder.
const kSuggestedReminderTime = TimeOfDay(hour: 20, minute: 30);
const _kBuildDuration = Duration(milliseconds: 3200);
const _kBuildHold = Duration(milliseconds: 500);

class ReminderStep extends ConsumerWidget {
  const ReminderStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final time = MaterialLocalizations.of(context).formatTimeOfDay(
      kSuggestedReminderTime,
      alwaysUse24HourFormat: MediaQuery.alwaysUse24HourFormatOf(context),
    );

    Future<void> remind() async {
      final texts = (
        title: l10n.reminderNotificationTitle,
        body: l10n.reminderNotificationBody,
      );
      // Moves on whether or not notifications were allowed.
      await ref
          .read(appSettingsProvider.notifier)
          .setReminderTime(kSuggestedReminderTime, texts: texts);
      onNext();
    }

    return StepLayout(
      title: l10n.onbReminderTitle,
      subtitle: l10n.onbReminderSubtitle,
      body: Align(
        alignment: const Alignment(0, -0.45),
        child: Reveal(
          delay: const Duration(milliseconds: 900),
          offset: const Offset(0, -90),
          blur: 0,
          curve: Curves.easeOutBack,
          child: _MockNotification(
            title: l10n.reminderNotificationTitle,
            body: l10n.reminderNotificationBody,
            time: time,
          ),
        ),
      ),
      cta: OnboardingCta(label: l10n.onbReminderCta(time), onPressed: remind),
      secondary: OnboardingTextButton(label: l10n.onbNotNow, onPressed: onNext),
    );
  }
}

/// What the daily reminder looks like on the lock screen.
class _MockNotification extends StatelessWidget {
  const _MockNotification({
    required this.title,
    required this.body,
    required this.time,
  });

  final String title;
  final String body;
  final String time;

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xff1B1B1F);
    const text = TextStyle(fontFamily: 'NotoSansJP', fontSize: 14, color: ink);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x4D000000),
            blurRadius: 30,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: context.neo.accent,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(width: 2),
            ),
            child: const Text('🍌', style: TextStyle(fontSize: 22)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Japanana',
                      style: text.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: text.copyWith(color: const Color(0xff6B6B70)),
                    ),
                  ],
                ),
                Text(title, style: text.copyWith(fontWeight: FontWeight.bold)),
                Text(body, style: text.copyWith(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BuildingStep extends HookConsumerWidget {
  const BuildingStep({required this.onNext, super.key});

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    final answers = ref.watch(onboardingProvider);
    final controller = useAnimationController(
      duration: _kBuildDuration + _kBuildHold,
    );
    useEffect(() {
      void listener(AnimationStatus status) {
        if (status == AnimationStatus.completed) onNext();
      }

      controller
        ..addStatusListener(listener)
        ..forward();
      return () => controller.removeStatusListener(listener);
    }, const []);
    final value = useAnimation(controller);
    final total = _kBuildDuration + _kBuildHold;
    final progress = Interval(
      0,
      _kBuildDuration.inMicroseconds / total.inMicroseconds,
      curve: Curves.easeInOutCubic,
    ).transform(value);
    final steps = [
      l10n.onbBuildingStep1(answers.level.label),
      l10n.onbBuildingStep2,
      l10n.onbBuildingStep3(answers.dailyMinutes),
    ];

    return StepLayout(
      body: Column(
        children: [
          const SizedBox(height: 30),
          SizedBox.square(
            dimension: 210,
            child: CustomPaint(
              painter: _RingPainter(
                progress: progress,
                card: neo.card,
                border: neo.border,
                shadow: neo.shadow,
                fill: neo.accent,
              ),
              child: Center(
                child: Text(
                  '${(progress * 100).round()}%',
                  style: context.onbBody.copyWith(fontSize: 42),
                ),
              ),
            ),
          ),
          const SizedBox(height: 34),
          BlurWords(
            l10n.onbBuildingTitle,
            style: context.onbTitle.copyWith(fontSize: 28),
            textAlign: TextAlign.center,
            delay: const Duration(milliseconds: 300),
          ),
          const SizedBox(height: 26),
          for (final (index, step) in steps.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 14, left: 14),
              child: Reveal(
                delay: Duration(milliseconds: 600 + index * 300),
                offset: const Offset(20, 0),
                child: Row(
                  children: [
                    _Check(done: progress > 0.3 + index * 0.3),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: context.onbBody.copyWith(fontSize: 15),
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

class _Check extends StatelessWidget {
  const _Check({required this.done});

  final bool done;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: done ? neo.correctFill : neo.card,
        shape: BoxShape.circle,
        border: Border.all(color: neo.border, width: 3),
      ),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        scale: done ? 1 : 0,
        child: Icon(Icons.check, size: 16, color: neo.onFeedback),
      ),
    );
  }
}

/// Outlined ring that fills clockwise with [progress].
class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.card,
    required this.border,
    required this.shadow,
    required this.fill,
  });

  final double progress;
  final Color card;
  final Color border;
  final Color shadow;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final unit = size.width / 220;
    final center = size.center(Offset.zero);
    canvas
      ..drawCircle(
        center + Offset(6 * unit, 6 * unit),
        92 * unit,
        Paint()..color = shadow,
      )
      ..drawCircle(center, 92 * unit, Paint()..color = card)
      ..drawCircle(
        center,
        92 * unit,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 6 * unit,
      )
      ..drawArc(
        Rect.fromCircle(center: center, radius: 76 * unit),
        -pi / 2,
        2 * pi * progress,
        false,
        Paint()
          ..color = fill
          ..style = PaintingStyle.stroke
          ..strokeWidth = 20 * unit,
      );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.card != card ||
      oldDelegate.fill != fill;
}
