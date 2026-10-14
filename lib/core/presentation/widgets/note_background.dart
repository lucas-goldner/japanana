import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';

class NoteBackground extends StatelessWidget {
  const NoteBackground({super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: NotebookBackgroundPainter(
          backgroundColor: context.colorScheme.secondary,
          lineColor: context.colorScheme.onSurface.withAlpha(40),
          marginLineColor: context.colorScheme.primary,
        ),
        child: const SizedBox.expand(),
      );
}

class NotebookBackgroundPainter extends CustomPainter {
  NotebookBackgroundPainter({
    this.backgroundColor = const Color(0xFFFFF8E1), // a pale “paper” cream
    this.lineColor = const Color(0xFF90CAF9), // a soft blue for rulings
    this.marginLineColor = const Color(0xFFEF5350), // a pale red for the margin
    this.lineSpacing = 32.0, // ~32px between each rule line
    this.marginOffset = 48.0, // ~48px from the left edge
  });

  /// The off‐white/cream background color of the “paper.”
  final Color backgroundColor;

  /// The color of the horizontal ruling (e.g. light blue).
  final Color lineColor;

  /// The color of the vertical margin line (e.g. light red).
  final Color marginLineColor;

  /// Vertical spacing between each horizontal line.
  final double lineSpacing;

  /// How far from the left edge to draw the vertical margin line.
  final double marginOffset;

  @override
  void paint(Canvas canvas, Size size) {
    // 1) Fill the entire canvas with the “paper” color.
    final fillPaint = Paint()..color = backgroundColor;
    canvas.drawRect(Offset.zero & size, fillPaint);

    // 2) Draw horizontal lines every [lineSpacing] pixels.
    final horizontalPaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    // Start drawing from y = lineSpacing (so the very top isn't lined),
    // and continue until the bottom of the canvas.
    for (var y = lineSpacing; y < size.height; y += lineSpacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        horizontalPaint,
      );
    }

    // 3) Draw the vertical margin line at [marginOffset].
    final verticalPaint = Paint()
      ..color = marginLineColor
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(marginOffset, 0),
      Offset(marginOffset, size.height),
      verticalPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
