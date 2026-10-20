import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:japanana/core/extensions.dart';

class OpenStatisticsButton extends HookWidget {
  const OpenStatisticsButton({
    super.key,
    this.onPressed,
  });

  final VoidCallback? onPressed;

  static const barCount = 5;
  static const baseHeight = 80.0;
  static const amplitude = 50.0;

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 8),
    )..repeat();
    final animationValue = useAnimation(controller);

    double barHeight(int i) =>
        baseHeight +
        amplitude * math.sin(2 * math.pi * (animationValue + i / barCount));

    final letters = ['S', 't', 'a', 't', 's'];

    double verticalLetterOffset(int i) => math.sin(
          2 * math.pi * (animationValue + i / barCount),
        );

    return GestureDetector(
      onTap: () => onPressed?.call(),
      child: SizedBox(
        width: 140,
        height: 200,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: List.generate(barCount, (i) {
            final h = barHeight(i);
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.bottomCenter,
              children: [
                Container(
                  width: 24,
                  height: h,
                  decoration: context.neo.decoration(
                    color: i.isEven
                        ? context.neo.card
                        : context.colorScheme.tertiary,
                    borderRadius: BorderRadius.zero,
                  ).copyWith(
                    boxShadow: [
                      BoxShadow(
                        color: context.neo.shadow,
                        offset: const Offset(3, 3),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: h + verticalLetterOffset(i),
                  child: Text(
                    letters[i],
                    style: context.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: context.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
