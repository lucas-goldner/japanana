import 'package:flutter/material.dart';

const _kTransitionDuration = Duration(milliseconds: 250);

class RadialPageTransition extends PageRouteBuilder<void> {
  RadialPageTransition({
    required this.child,
    required this.anchorOffset,
    super.settings,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionDuration: _kTransitionDuration,
          reverseTransitionDuration: _kTransitionDuration,
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              RadialTransitionWidget(
            animation: animation,
            anchorOffset: anchorOffset,
            child: child,
          ),
        );

  final Widget child;
  final Offset anchorOffset;
}

class RadialTransitionWidget extends StatelessWidget {
  const RadialTransitionWidget({
    required this.animation,
    required this.anchorOffset,
    required this.child,
    super.key,
  });

  final Animation<double> animation;
  final Offset anchorOffset;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        builder: (context, child) => ClipPath(
          clipper: RadialClipper(
            progress: animation.value,
            anchorOffset: anchorOffset,
          ),
          child: child,
        ),
        child: child,
      );
}

class RadialClipper extends CustomClipper<Path> {
  RadialClipper({
    required this.progress,
    required this.anchorOffset,
  });

  final double progress;
  final Offset anchorOffset;

  @override
  Path getClip(Size size) {
    final path = Path();

    // Calculate the maximum radius needed to cover the entire screen
    final maxRadius = _calculateMaxRadius(size, anchorOffset);

    // Current radius based on progress
    final currentRadius = progress * maxRadius;

    // Create circular path from anchor point
    path.addOval(
      Rect.fromCircle(
        center: anchorOffset,
        radius: currentRadius,
      ),
    );

    return path;
  }

  double _calculateMaxRadius(Size size, Offset center) {
    // Calculate distance to each corner
    final topLeft = (center - Offset.zero).distance;
    final topRight = (center - Offset(size.width, 0)).distance;
    final bottomLeft = (center - Offset(0, size.height)).distance;
    final bottomRight = (center - Offset(size.width, size.height)).distance;

    // Return the maximum distance to ensure full coverage
    return [topLeft, topRight, bottomLeft, bottomRight]
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}
