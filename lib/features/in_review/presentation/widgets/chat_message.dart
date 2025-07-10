import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';

class ChatMessageData {
  ChatMessageData({
    required this.text,
    required this.isUser,
    this.isSeparator = false,
  });

  final String text;
  final bool isUser;
  final bool isSeparator;
}

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.index,
    this.isSeparator = false,
    super.key,
  });

  final String text;
  final bool isUser;
  final int index;
  final bool isSeparator;

  @override
  Widget build(BuildContext context) {
    final colorScheme = context.colorScheme;

    if (isSeparator) {
      return Container(
        margin: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        child: Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                text,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
      );
    }

    final seed = text.hashCode + index;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        padding: EdgeInsets.only(
          left: isUser ? 32 : 0,
          right: isUser ? 0 : 32,
        ),
        child: CustomPaint(
          painter: _ScribbleBorderPainter(
            borderColor: isUser
                ? colorScheme.primary.withValues(alpha: 0.8)
                : colorScheme.onSurface,
            fillColor: isUser
                ? colorScheme.primary.withValues(alpha: 0.9)
                : colorScheme.secondary,
            seed: seed,
            isUser: isUser,
          ),
          child: Container(
            padding: EdgeInsets.only(
              left: isUser ? 16 : 20,
              right: isUser ? 20 : 16,
              top: 12,
              bottom: 12,
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isUser ? colorScheme.secondary : colorScheme.onSurface,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ScribbleBorderPainter extends CustomPainter {
  _ScribbleBorderPainter({
    required this.borderColor,
    required this.fillColor,
    required this.seed,
    required this.isUser,
  });

  final Color borderColor;
  final Color fillColor;
  final int seed;
  final bool isUser;

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = borderColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final path = Path();
    final random = math.Random(seed);

    // Tail parameters
    const tailWidth = 16.0;
    const tailHeight = 24.0;
    final tailY = size.height * 0.7; // Position tail at 70% height

    // Generate scribble bubble with tail
    const segments = 15;
    const radius = 8.0;

    // Start from top-left corner
    path.moveTo(
      radius + random.nextDouble() * 2 - 1,
      random.nextDouble() * 2 - 1,
    );

    // Top edge
    for (var i = 1; i < segments; i++) {
      final x = radius + (size.width - 2 * radius) * i / segments;
      final y = random.nextDouble() * 3 - 1.5;
      path.lineTo(x, y);
    }

    // Top-right corner
    path.quadraticBezierTo(
      size.width + random.nextDouble() * 2 - 1,
      random.nextDouble() * 2 - 1,
      size.width + random.nextDouble() * 2 - 1,
      radius,
    );

    // Right edge with tail for user messages
    if (isUser) {
      // Draw right edge segments with tail in the middle
      const rightSegments = 8;
      const tailSegment = rightSegments ~/ 2;

      for (var i = 1; i <= rightSegments; i++) {
        final y = radius + (size.height - 2 * radius) * i / rightSegments;
        final x = size.width + random.nextDouble() * 2 - 1;

        if (i == tailSegment) {
          // Add tail at this segment
          final tailStartY = tailY - tailHeight / 4;
          final tailEndY = tailY + tailHeight / 4;

          // Draw to tail start
          path.lineTo(x, tailStartY);

          // Draw tail going out with softer curve
          final tailTipX = size.width + tailWidth;
          final tailTipY = tailY + random.nextDouble() * 3 - 1.5;

          // First control point for outgoing curve (closer to bubble)
          final outControl1X = size.width + tailWidth * 0.3;
          final outControl1Y = tailStartY + tailHeight * 0.2;

          // Second control point for outgoing curve (near tip)
          final outControl2X = tailTipX - tailWidth * 0.2;
          final outControl2Y = tailTipY - tailHeight * 0.1;

          path.cubicTo(
            outControl1X + random.nextDouble() * 2 - 1,
            outControl1Y + random.nextDouble() * 2 - 1,
            outControl2X + random.nextDouble() * 2 - 1,
            outControl2Y + random.nextDouble() * 2 - 1,
            tailTipX + random.nextDouble() * 2 - 1,
            tailTipY,
          );

          // Draw tail coming back with softer curve
          final inControl1X = tailTipX - tailWidth * 0.2;
          final inControl1Y = tailTipY + tailHeight * 0.1;

          final inControl2X = size.width + tailWidth * 0.3;
          final inControl2Y = tailEndY - tailHeight * 0.2;

          path.cubicTo(
            inControl1X + random.nextDouble() * 2 - 1,
            inControl1Y + random.nextDouble() * 2 - 1,
            inControl2X + random.nextDouble() * 2 - 1,
            inControl2Y + random.nextDouble() * 2 - 1,
            x,
            tailEndY,
          );
        }

        // Continue with normal right edge
        path.lineTo(x, y);
      }
    } else {
      // No tail on right for assistant messages
      path.lineTo(
        size.width + random.nextDouble() * 2 - 1,
        size.height - radius,
      );
    }

    // Bottom-right corner
    path.quadraticBezierTo(
      size.width + random.nextDouble() * 2 - 1,
      size.height + random.nextDouble() * 2 - 1,
      size.width - radius,
      size.height + random.nextDouble() * 2 - 1,
    );

    // Bottom edge
    for (var i = segments - 1; i > 0; i--) {
      final x = radius + (size.width - 2 * radius) * i / segments;
      final y = size.height + random.nextDouble() * 3 - 1.5;
      path.lineTo(x, y);
    }

    // Bottom-left corner
    path.quadraticBezierTo(
      random.nextDouble() * 2 - 1,
      size.height + random.nextDouble() * 2 - 1,
      random.nextDouble() * 2 - 1,
      size.height - radius,
    );

    // Left edge with tail for assistant messages
    if (!isUser) {
      // Draw from bottom to tail end
      final tailEndY = tailY + tailHeight / 4;
      path.lineTo(random.nextDouble() * 2 - 1, tailEndY);

      // Draw tail going out with softer curve
      const tailTipX = -tailWidth;
      final tailTipY = tailY + random.nextDouble() * -1;

      // Control points for outgoing curve
      const outControl1X = -tailWidth * 0.3;
      final outControl1Y = tailEndY - tailHeight * 0.2;

      const outControl2X = tailTipX + tailWidth * 0.2;
      final outControl2Y = tailTipY + tailHeight * 0.1;

      path.cubicTo(
        outControl1X + random.nextDouble() * 2 - 1,
        outControl1Y + random.nextDouble() * 2 - 1,
        outControl2X + random.nextDouble() * 2 - 1,
        outControl2Y + random.nextDouble() * 2 - 1,
        tailTipX + random.nextDouble() * 2 - 1,
        tailTipY,
      );

      // Draw tail coming back with softer curve
      final tailStartY = tailY - tailHeight / 2;
      const inControl1X = tailTipX + tailWidth * 0.2;
      final inControl1Y = tailTipY - tailHeight * 0.1;

      const inControl2X = -tailWidth * 0.3;
      final inControl2Y = tailStartY + tailHeight * 0.2;

      path
        ..cubicTo(
          inControl1X + random.nextDouble() * 2 - 1,
          inControl1Y + random.nextDouble() * 2 - 1,
          inControl2X + random.nextDouble() * 2 - 1,
          inControl2Y + random.nextDouble() * 2 - 1,
          random.nextDouble() * 2 - 1,
          tailStartY,
        )
        // Continue left edge to top
        ..lineTo(random.nextDouble() * 2 - 1, radius);
    } else {
      // No tail on left for user messages
      path.lineTo(random.nextDouble() * 2 - 1, radius);
    }

    // Close to start
    path
      ..quadraticBezierTo(
        random.nextDouble() * 2 - 1,
        random.nextDouble() * 2 - 1,
        radius,
        random.nextDouble() * 2 - 1,
      )
      ..close();

    // Fill the path first then draw the border
    canvas
      ..drawPath(path, fillPaint)
      ..drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(_ScribbleBorderPainter oldDelegate) =>
      borderColor != oldDelegate.borderColor ||
      fillColor != oldDelegate.fillColor ||
      seed != oldDelegate.seed ||
      isUser != oldDelegate.isUser;
}
