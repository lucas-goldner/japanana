import 'dart:math';
import 'package:flutter/material.dart';

class ScribbleBorderButton extends StatelessWidget {
  const ScribbleBorderButton({
    required this.onPressed,
    required this.child,
    super.key,
    this.strokeWidth = 2.0,
    this.borderColor = Colors.black,
    this.shadowColor = Colors.black26,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    this.minHeight = 48,
  });
  final VoidCallback onPressed;
  final Widget child;
  final double strokeWidth;
  final Color borderColor;
  final Color shadowColor;

  final EdgeInsets padding;
  final double minHeight;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          onTap: onPressed,
          child: CustomPaint(
            painter: _ScribbleBorderPainter(
              strokeWidth: strokeWidth,
              borderColor: borderColor,
              shadowColor: shadowColor,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: minHeight),
              child: Padding(
                padding: padding,
                child: Center(child: child),
              ),
            ),
          ),
        ),
      );
}

class _ScribbleBorderPainter extends CustomPainter {
  _ScribbleBorderPainter({
    required this.strokeWidth,
    required this.borderColor,
    required this.shadowColor,
  });
  final double strokeWidth;
  final Color borderColor;
  final Color shadowColor;
  final Random random = Random();

  @override
  void paint(Canvas canvas, Size size) {
    // First, draw the “shadow” scribble (slightly offset in Y).
    final shadowPath = _createScribblyRoundedRect(
      size,
      cornerRadius: 24,
      offsetY: 5, // Offset down by 5px to create a subtle “shadow” look
      verticalNoise: 3, // Bump vertical jitter so the shadow sits farther below
    );
    final shadowPaint = Paint()
      ..color = shadowColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(shadowPath, shadowPaint);

    // Then draw the main scribbly border on top (no offset).
    final borderPath = _createScribblyRoundedRect(
      size,
      cornerRadius: 24,
      verticalNoise: 3, // Same noise so top/bottom lines are nice and wavy
    );
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(borderPath, borderPaint);
  }

  /// Creates a “wiggly” rounded‐rect path around a box of [size].
  ///
  /// - [cornerRadius]: how “rounded” the corners should be.
  /// - [offsetY]: vertical offset (useful for drawing the shadow).
  /// - [verticalNoise]: how much vertical jiggle on each point.
  Path _createScribblyRoundedRect(
    Size size, {
    required double cornerRadius,
    double offsetY = 0,
    double verticalNoise = 2.0,
  }) {
    final path = Path();
    const segments = 40; // More → smoother, less → chunkier scribble.

    // We will generate points along each edge, adding a small random Y‐bump.
    final pts = <Offset>[];

    // TOP EDGE: from (r, r) to (w−r, r)
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = _lerp(cornerRadius, size.width - cornerRadius, t);
      // Add vertical noise + any offset (for the shadow).
      final y = cornerRadius +
          (random.nextDouble() * verticalNoise - verticalNoise / 2) +
          offsetY;
      pts.add(Offset(x, y));
    }

    // RIGHT EDGE: from (w−r, r) to (w−r, h−r)
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = size.width -
          cornerRadius +
          (random.nextDouble() * verticalNoise - verticalNoise / 2);
      final y = _lerp(cornerRadius, size.height - cornerRadius, t) + offsetY;
      pts.add(Offset(x, y));
    }

    // BOTTOM EDGE: from (w−r, h−r) to (r, h−r)
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = _lerp(size.width - cornerRadius, cornerRadius, t);
      final y = size.height -
          cornerRadius +
          (random.nextDouble() * verticalNoise - verticalNoise / 2) +
          offsetY;
      pts.add(Offset(x, y));
    }

    // LEFT EDGE: from (r, h−r) to (r, r)
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = cornerRadius +
          (random.nextDouble() * verticalNoise - verticalNoise / 2);
      final y = _lerp(size.height - cornerRadius, cornerRadius, t) + offsetY;
      pts.add(Offset(x, y));
    }

    // Stitch them together
    path.moveTo(pts.first.dx, pts.first.dy);
    for (var i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    path.close();
    return path;
  }

  double _lerp(double a, double b, double t) => a + (b - a) * t;

  @override
  bool shouldRepaint(covariant _ScribbleBorderPainter old) => true;
}
