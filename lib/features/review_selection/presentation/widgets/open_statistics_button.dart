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

  // Animation timing constants
  static const _kFlashDuration = Duration(milliseconds: 50); // Each flash cycle
  static const _kFlashCount = 3; // 3 flashes

  @override
  Widget build(BuildContext context) {
    final controller = useAnimationController(
      duration: const Duration(seconds: 8),
    )..repeat();
    final animationValue = useAnimation(controller);

    // Flash animation state
    final isFlashing = useState(false);
    final flashController = useAnimationController(
      duration: _kFlashDuration,
    );

    // Reset state when widget rebuilds (e.g., when returning to screen)
    useEffect(
      () {
        // Reset flash state to make button appear normal
        if (isFlashing.value) {
          isFlashing.value = false;
          flashController.reset();
        }
        return null;
      },
      const [],
    );

    double barHeight(int i) =>
        baseHeight +
        amplitude * math.sin(2 * math.pi * (animationValue + i / barCount));

    final letters = ['S', 't', 'a', 't', 's'];

    double verticalLetterOffset(int i) => math.sin(
          2 * math.pi * (animationValue + i / barCount),
        );

    // Handle press animation
    Future<void> handlePress() async {
      if (isFlashing.value) return;
      isFlashing.value = true;

      // Flash animation (3 times)
      for (var i = 0; i < _kFlashCount; i++) {
        await flashController.forward();
        await flashController.reverse();
      }

      // Keep it shown (full opacity)
      await flashController.forward();

      // Call onPressed
      onPressed?.call();

      // Reset after a delay so the animation completes before navigation
      await Future<void>.delayed(const Duration(milliseconds: 100));
      if (context.mounted) {
        isFlashing.value = false;
        flashController.reset();
      }
    }

    return GestureDetector(
      onTap: handlePress,
      child: AnimatedBuilder(
        animation: flashController,
        builder: (context, child) {
          final opacity = isFlashing.value ? flashController.value : 1.0;
          return Opacity(
            opacity: opacity,
            child: child,
          );
        },
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
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: context.colorScheme.primary,
                        width: 6,
                      ),
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
      ),
    );
  }
}
