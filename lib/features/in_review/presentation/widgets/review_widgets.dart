import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/features/in_review/domain/review_question.dart';

const kReviewFont = 'NotoSansJP';
const _kShakeDuration = Duration(milliseconds: 420);

extension QuestionModeLabel on QuestionMode {
  String label(BuildContext context) => switch (this) {
    QuestionMode.choose => context.l10n.reviewModeChoose,
    QuestionMode.swipe => context.l10n.reviewModeSwipe,
    QuestionMode.gap => context.l10n.reviewModeGap,
    QuestionMode.meaning => context.l10n.reviewModeMeaning,
    QuestionMode.pairs => context.l10n.reviewModePairs,
  };
}

extension BreakKindLabel on BreakKind {
  String label(BuildContext context) => switch (this) {
    BreakKind.memory => context.l10n.reviewModeMemory,
    BreakKind.lightning => context.l10n.reviewModeLightning,
  };
}

/// Ink fill: black in light mode, banana in dark mode.
extension ReviewInk on BuildContext {
  bool get isDark => theme.brightness == Brightness.dark;
  Color get inkFill => isDark ? neo.accent : neo.border;
  Color get onInkFill => isDark ? neo.onAccent : neo.accent;
}

/// Divider that starts a section, with the topic and the kind of question.
class SectionHeader extends StatelessWidget {
  const SectionHeader({required this.title, this.label, super.key});

  final String title;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    Widget line() => Expanded(child: Container(height: 3, color: neo.border));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Column(
        children: [
          Row(
            children: [
              line(),
              Flexible(
                flex: 4,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Container(
                    key: ValueKey(title),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: neo.decoration(
                      color: context.colorScheme.tertiary,
                      borderRadius: BorderRadius.circular(999),
                      shadowColor: neo.accentShadow,
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: kReviewFont,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              line(),
            ],
          ),
          if (label != null) ...[
            const SizedBox(height: 10),
            ReviewPill(label: label!),
          ],
        ],
      ),
    );
  }
}

/// Small outlined label.
class ReviewPill extends StatelessWidget {
  const ReviewPill({
    required this.label,
    this.color,
    this.foregroundColor,
    super.key,
  });

  final String label;
  final Color? color;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: color ?? context.neo.card,
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: context.neo.border, width: 2),
    ),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        fontFamily: kReviewFont,
        fontWeight: FontWeight.bold,
        fontSize: 11,
        letterSpacing: 0.8,
        color: foregroundColor ?? context.neo.onCard,
      ),
    ),
  );
}

enum ChoiceState { idle, wrong, right, dimmed }

/// Answer button that turns pink and struck through when wrong and green
/// when right. It keeps that look in the history.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    required this.label,
    required this.state,
    required this.onTap,
    this.fontSize = 16,
    this.center = false,
    super.key,
  });

  final String label;
  final ChoiceState state;
  final VoidCallback? onTap;
  final double fontSize;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final feedback = state == ChoiceState.wrong || state == ChoiceState.right;
    return Opacity(
      opacity: state == ChoiceState.dimmed ? 0.5 : 1,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          NeoButton(
            onPressed: onTap ?? () {},
            color: switch (state) {
              ChoiceState.wrong => neo.wrongFill,
              ChoiceState.right => neo.correctFill,
              _ => null,
            },
            foregroundColor: feedback ? neo.onFeedback : null,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: SizedBox(
              width: double.infinity,
              child: Text(
                label,
                textAlign: center ? TextAlign.center : TextAlign.start,
                style: TextStyle(
                  fontFamily: kReviewFont,
                  fontSize: fontSize,
                  decoration: state == ChoiceState.wrong
                      ? TextDecoration.lineThrough
                      : null,
                  decorationThickness: 2,
                ),
              ),
            ),
          ),
          if (state == ChoiceState.wrong)
            const Positioned(top: -12, right: -8, child: MistakeMarker()),
          if (state == ChoiceState.right)
            const Positioned(top: -12, right: -8, child: RightMarker()),
        ],
      ),
    );
  }
}

class MistakeMarker extends StatelessWidget {
  const MistakeMarker({super.key});

  @override
  Widget build(BuildContext context) => _Marker(
    color: context.colorScheme.error,
    icon: Icons.close,
    iconColor: Colors.white,
    angle: 0.2,
  );
}

class RightMarker extends StatelessWidget {
  const RightMarker({super.key});

  @override
  Widget build(BuildContext context) => _Marker(
    color: context.neo.card,
    icon: Icons.check,
    iconColor: context.neo.onCard,
    angle: -0.1,
  );
}

class _Marker extends StatelessWidget {
  const _Marker({
    required this.color,
    required this.icon,
    required this.iconColor,
    required this.angle,
  });

  final Color color;
  final IconData icon;
  final Color iconColor;
  final double angle;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: 36,
        height: 36,
        decoration: neo
            .decoration(color: color, shape: BoxShape.circle)
            .copyWith(
              boxShadow: [
                BoxShadow(color: neo.shadow, offset: const Offset(3, 3)),
              ],
            ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
    );
  }
}

/// Shakes its child sideways whenever [trigger] changes.
class Shake extends HookWidget {
  const Shake({required this.trigger, required this.child, super.key});

  final int trigger;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(duration: _kShakeDuration);
    useEffect(() {
      if (trigger > 0) controller.forward(from: 0);
      return null;
    }, [trigger]);
    final value = useAnimation(controller);
    final offset = value == 0 || value == 1
        ? 0.0
        : 10 * (1 - value) * (value * 24).remainder(2).compareTo(1);
    return Transform.translate(offset: Offset(offset, 0), child: child);
  }
}

/// Streak of right first answers, shown in the app bar.
class ComboMeter extends StatelessWidget {
  const ComboMeter({required this.combo, super.key});

  final int combo;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final active = combo > 1;
    return TweenAnimationBuilder<double>(
      key: ValueKey(combo),
      tween: Tween(begin: active ? 1.35 : 1, end: 1),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) =>
          Transform.scale(scale: scale, child: child),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: active ? neo.accent : neo.card,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: neo.border, width: 2.5),
          boxShadow: [
            if (active)
              BoxShadow(color: neo.accentShadow, offset: const Offset(3, 3)),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.local_fire_department,
              size: 16,
              color: active ? neo.onAccent : neo.onCard.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 2),
            Text(
              '×$combo',
              style: TextStyle(
                fontFamily: kReviewFont,
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: active
                    ? neo.onAccent
                    : neo.onCard.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fades and slides its child in after [delay], once.
class ReviewReveal extends HookWidget {
  const ReviewReveal({
    required this.child,
    this.delay = Duration.zero,
    super.key,
  });

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final total = delay + const Duration(milliseconds: 450);
    final controller = useAnimationController(duration: total);
    useEffect(() {
      controller.forward();
      return null;
    }, const []);
    final value = Interval(
      delay.inMicroseconds / total.inMicroseconds,
      1,
      curve: Curves.easeOutCubic,
    ).transform(useAnimation(controller));
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(0, 40 * (1 - value)),
        child: child,
      ),
    );
  }
}
