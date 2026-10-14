import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class FadeInFromBottom extends HookWidget {
  const FadeInFromBottom({
    required this.child,
    super.key,
    this.duration = const Duration(milliseconds: 800),
    this.offsetY = 50.0,
    this.delay = Duration.zero,
  });
  final Widget child;
  final Duration duration;
  final double offsetY;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(duration: duration);

    final fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );

    final slideAnimation = Tween<Offset>(
      begin: Offset(0, offsetY / 100), // Converts pixels to a fraction
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animationController,
        curve: Curves.easeOut,
      ),
    );

    useEffect(
      () {
        Future.delayed(delay, animationController.forward);
        return null;
      },
      [],
    );

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: child,
      ),
    );
  }
}
