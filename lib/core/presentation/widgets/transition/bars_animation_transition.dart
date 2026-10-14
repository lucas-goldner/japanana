import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:japanana/core/extensions.dart';

const Duration _kBarsAnimationDuration = Duration(milliseconds: 250);

sealed class BarsAnimationTransition extends HookWidget {
  const BarsAnimationTransition({super.key});

  const factory BarsAnimationTransition.close({
    Key? key,
    VoidCallback? onAnimationComplete,
  }) = _CloseBarsAnimation;

  const factory BarsAnimationTransition.open({
    Key? key,
    VoidCallback? onAnimationComplete,
  }) = _OpenBarsAnimation;
}

class _CloseBarsAnimation extends BarsAnimationTransition {
  const _CloseBarsAnimation({
    super.key,
    this.onAnimationComplete,
  });

  final VoidCallback? onAnimationComplete;

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: _kBarsAnimationDuration,
    );

    useEffect(
      () {
        animationController.forward().then((_) {
          onAnimationComplete?.call();
        });
        return null;
      },
      [],
    );

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, _) {
        final progress = animationController.value;
        final screenSize = MediaQuery.of(context).size;

        return Stack(
          children: [
            // 5 bars sliding in from alternating directions
            for (int i = 0; i < 5; i++)
              Builder(
                builder: (context) {
                  final isFromTop = i.isEven;
                  final barWidth =
                      (screenSize.width / 5) + 1; // Add 1 pixel overlap
                  final barHeight = screenSize.height;

                  late final double? top;
                  late final double? bottom;

                  if (isFromTop) {
                    // Bar slides from top
                    top = -barHeight + (barHeight * progress);
                    bottom = null;
                  } else {
                    // Bar slides from bottom
                    top = null;
                    bottom = -barHeight + (barHeight * progress);
                  }

                  return Positioned(
                    left: i * barWidth,
                    top: isFromTop ? top : null,
                    bottom: isFromTop ? null : bottom,
                    width: barWidth,
                    height: barHeight,
                    child: Container(
                      color: context.colorScheme.primary,
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}

class _OpenBarsAnimation extends BarsAnimationTransition {
  const _OpenBarsAnimation({
    super.key,
    this.onAnimationComplete,
  });

  final VoidCallback? onAnimationComplete;

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(
      duration: _kBarsAnimationDuration,
    );

    useEffect(
      () {
        animationController.forward().then((_) {
          onAnimationComplete?.call();
        });
        return null;
      },
      [],
    );

    return AnimatedBuilder(
      animation: animationController,
      builder: (context, _) {
        final progress = animationController.value;
        final screenSize = MediaQuery.of(context).size;

        return Stack(
          children: [
            // 5 bars sliding out to reveal content
            for (int i = 0; i < 5; i++)
              Builder(
                builder: (context) {
                  final isFromTop = i.isEven;
                  final barWidth =
                      (screenSize.width / 5) + 1; // Add 1 pixel overlap
                  final barHeight = screenSize.height;

                  late final double? top;
                  late final double? bottom;

                  if (isFromTop) {
                    // Bar slides out to top
                    top = barHeight * progress;
                    bottom = null;
                  } else {
                    // Bar slides out to bottom
                    top = null;
                    bottom = barHeight * progress;
                  }

                  return Positioned(
                    left: i * barWidth,
                    top: isFromTop ? top : null,
                    bottom: isFromTop ? null : bottom,
                    width: barWidth,
                    height: barHeight,
                    child: Container(
                      color: context.colorScheme.primary,
                    ),
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
