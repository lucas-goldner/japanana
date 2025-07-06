import 'dart:math';
import 'package:flutter/material.dart';

class ScribbleBorderButton extends StatefulWidget {
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
  State<ScribbleBorderButton> createState() => _ScribbleBorderButtonState();
}

class _ScribbleBorderButtonState extends State<ScribbleBorderButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (context, constraints) => GestureDetector(
          onTap: widget.onPressed,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => CustomPaint(
              painter: _ScribbleBorderPainter(
                strokeWidth: widget.strokeWidth,
                borderColor: widget.borderColor,
                shadowColor: widget.shadowColor,
                animationValue: _controller.value,
              ),
              child: child,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: widget.minHeight),
              child: Padding(
                padding: widget.padding,
                child: Center(child: widget.child),
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
    required this.animationValue,
  });
  final double strokeWidth;
  final Color borderColor;
  final Color shadowColor;
  final double animationValue;

  @override
  void paint(Canvas canvas, Size size) {
    // First, draw the "shadow" scribble (slightly offset in Y).
    final shadowPath = _createScribblyRoundedRect(
      size,
      cornerRadius: 24,
      offsetY: 5, // Offset down by 5px to create a subtle "shadow" look
      verticalNoise: 5, // Bump vertical jitter so the shadow sits farther below
      animationValue: animationValue,
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
      verticalNoise: 4, // Same noise so top/bottom lines are nice and wavy
      animationValue: animationValue,
    );
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(borderPath, borderPaint);
  }

  /// Creates a "wiggly" rounded‐rect path around a box of [size].
  ///
  /// - [cornerRadius]: how "rounded" the corners should be.
  /// - [offsetY]: vertical offset (useful for drawing the shadow).
  /// - [verticalNoise]: how much vertical jiggle on each point.
  Path _createScribblyRoundedRect(
    Size size, {
    required double cornerRadius,
    required double animationValue,
    double offsetY = 0,
    double verticalNoise = 2.0,
  }) {
    final path = Path();
    const segments = 20; // More → smoother, less → chunkier scribble.

    // We will generate points along each edge, adding a small random Y‐bump.
    final pts = <Offset>[];

    // TOP EDGE: from (r, r) to (w−r, r)
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = _lerp(cornerRadius, size.width - cornerRadius, t);
      // Add animated noise with multiple frequencies for jagged movement
      final noise1 = sin((animationValue * 2 * pi) + (i * 0.8)) * verticalNoise;
      final noise2 =
          sin((animationValue * 4 * pi) + (i * 1.3)) * verticalNoise * 0.5;
      final noise3 =
          cos((animationValue * 8 * pi) + (i * 2.1)) * verticalNoise * 0.25;
      final noise = noise1 + noise2 + noise3;
      final y = cornerRadius + noise + offsetY;
      pts.add(Offset(x, y));
    }

    // RIGHT EDGE: from (w−r, r) to (w−r, h−r)
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final noise1 =
          cos((animationValue * 2 * pi) + (i * 0.8) + pi / 2) * verticalNoise;
      final noise2 = cos((animationValue * 4 * pi) + (i * 1.3) + pi / 3) *
          verticalNoise *
          0.5;
      final noise3 = sin((animationValue * 8 * pi) + (i * 2.1) + pi / 4) *
          verticalNoise *
          0.25;
      final noise = noise1 + noise2 + noise3;
      final x = size.width - cornerRadius + noise;
      final y = _lerp(cornerRadius, size.height - cornerRadius, t) + offsetY;
      pts.add(Offset(x, y));
    }

    // BOTTOM EDGE: from (w−r, h−r) to (r, h−r)
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final x = _lerp(size.width - cornerRadius, cornerRadius, t);
      final noise1 =
          sin((animationValue * 2 * pi) + (i * 0.8) + pi) * verticalNoise;
      final noise2 = sin((animationValue * 4 * pi) + (i * 1.3) + pi * 0.75) *
          verticalNoise *
          0.5;
      final noise3 = cos((animationValue * 8 * pi) + (i * 2.1) + pi * 1.5) *
          verticalNoise *
          0.25;
      final noise = noise1 + noise2 + noise3;
      final y = size.height - cornerRadius + noise + offsetY;
      pts.add(Offset(x, y));
    }

    // LEFT EDGE: from (r, h−r) to (r, r)
    for (var i = 0; i <= segments; i++) {
      final t = i / segments;
      final noise1 = cos((animationValue * 2 * pi) + (i * 0.8) + 3 * pi / 2) *
          verticalNoise;
      final noise2 = cos((animationValue * 4 * pi) + (i * 1.3) + pi * 1.25) *
          verticalNoise *
          0.5;
      final noise3 = sin((animationValue * 8 * pi) + (i * 2.1) + pi * 0.5) *
          verticalNoise *
          0.25;
      final noise = noise1 + noise2 + noise3;
      final x = cornerRadius + noise;
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
  bool shouldRepaint(covariant _ScribbleBorderPainter old) =>
      old.animationValue != animationValue;
}
