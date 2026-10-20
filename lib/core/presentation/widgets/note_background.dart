import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';

class NoteBackground extends StatelessWidget {
  const NoteBackground({super.key});

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: GridPaperPainter(
          backgroundColor: context.colorScheme.secondary,
          lineColor: context.neo.grid,
        ),
        child: const SizedBox.expand(),
      );
}

/// Flat graph paper: a solid fill with an evenly spaced square grid.
class GridPaperPainter extends CustomPainter {
  GridPaperPainter({
    required this.backgroundColor,
    required this.lineColor,
    this.cellSize = 24.0,
  });

  final Color backgroundColor;
  final Color lineColor;

  /// Width and height of one grid cell.
  final double cellSize;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = backgroundColor);

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    for (var y = cellSize; y < size.height; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), linePaint);
    }
    for (var x = cellSize; x < size.width; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant GridPaperPainter oldDelegate) =>
      oldDelegate.backgroundColor != backgroundColor ||
      oldDelegate.lineColor != lineColor ||
      oldDelegate.cellSize != cellSize;
}
