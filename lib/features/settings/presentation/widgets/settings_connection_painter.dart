import 'package:flutter/material.dart';
import 'package:japanana/core/presentation/widgets/widget_canvas.dart';

class SettingsConnectionPainter extends CustomPainter {
  const SettingsConnectionPainter({
    required this.canvasController,
    this.lineColor,
    this.lineWidth = 1.0,
    this.opacity = 0.3,
    this.connectionRange = 100.0,
    this.linePadding = 10.0,
    this.animationProgress = 1.0,
    this.animatedConnections = const {},
  });

  final WidgetCanvasController canvasController;
  final Color? lineColor;
  final double lineWidth;
  final double opacity;
  final double connectionRange;
  final double linePadding;
  final double animationProgress;
  final Set<String> animatedConnections;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (lineColor ?? Colors.grey).withValues(alpha: opacity)
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke;

    final children = canvasController.children;

    // Draw lines only between items within connection range
    for (var i = 0; i < children.length; i++) {
      for (var j = i + 1; j < children.length; j++) {
        final startItem = children[i];
        final endItem = children[j];

        // Calculate center points of each item using current positions
        final startCenter = Offset(
          startItem.offset.dx + startItem.size.width / 2,
          startItem.offset.dy + startItem.size.height / 2,
        );
        final endCenter = Offset(
          endItem.offset.dx + endItem.size.width / 2,
          endItem.offset.dy + endItem.size.height / 2,
        );

        // Calculate distance between the two items
        final distance = (startCenter - endCenter).distance;

        // Only draw line if items are within connection range
        if (distance <= connectionRange) {
          // Calculate direction vector for padding offset
          final directionVector = endCenter - startCenter;
          final directionLength = directionVector.distance;
          
          // Normalize the direction vector
          final normalizedDirection = Offset(
            directionVector.dx / directionLength,
            directionVector.dy / directionLength,
          );
          
          // Apply padding to move line start/end points away from centers
          final paddedStart = startCenter + (normalizedDirection * linePadding);
          final paddedEnd = endCenter - (normalizedDirection * linePadding);
          
          // Create unique connection ID
          final connectionId = '${startItem.key}-${endItem.key}';
          
          // Check if this connection should be animated
          final shouldAnimate = animatedConnections.contains(connectionId);
          
          if (shouldAnimate) {
            // Draw animated line from start to progress point
            final animatedEnd = Offset.lerp(paddedStart, paddedEnd, animationProgress)!;
            canvas.drawLine(paddedStart, animatedEnd, paint);
          } else {
            // Draw full line (for existing connections)
            canvas.drawLine(paddedStart, paddedEnd, paint);
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(SettingsConnectionPainter oldDelegate) =>
      canvasController != oldDelegate.canvasController ||
      lineColor != oldDelegate.lineColor ||
      lineWidth != oldDelegate.lineWidth ||
      opacity != oldDelegate.opacity ||
      connectionRange != oldDelegate.connectionRange ||
      linePadding != oldDelegate.linePadding ||
      animationProgress != oldDelegate.animationProgress ||
      animatedConnections != oldDelegate.animatedConnections;
}
