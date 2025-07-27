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

class ChatMessage extends StatefulWidget {
  const ChatMessage({
    required this.text,
    required this.isUser,
    required this.index,
    this.isSeparator = false,
    this.fontFamily,
    this.fontWeight = FontWeight.bold,
    super.key,
  });

  final String text;
  final bool isUser;
  final int index;
  final bool isSeparator;
  final String? fontFamily;
  final FontWeight fontWeight;

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late AnimationController _borderController;
  late AnimationController _textController;
  late Animation<double> _borderAnimation;
  late Animation<double> _textAnimation;
  bool _hasAnimated = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    // Border drawing animation (1 second)
    _borderController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Text fade-in animation (0.3 seconds, starts after border)
    _textController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _borderAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _borderController,
        curve: Curves.easeInOut,
      ),
    );

    _textAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeIn,
      ),
    );

    // Only animate once
    if (!_hasAnimated) {
      _hasAnimated = true;
      // Start border animation immediately
      _borderController
        ..forward()
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _textController.forward();
          }
        });
    } else {
      // If already animated, jump to end state
      _borderController.value = 1.0;
      _textController.value = 1.0;
    }
  }

  @override
  void dispose() {
    _borderController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final colorScheme = context.colorScheme;

    if (widget.isSeparator) {
      return Container(
        margin: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        child: Column(
          children: [
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.text,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: widget.fontWeight,
                  color: colorScheme.onSurface,
                  fontFamily: widget.fontFamily,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const Divider(),
          ],
        ),
      );
    }

    final seed = widget.text.hashCode + widget.index;

    return Align(
      alignment: widget.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 8,
          horizontal: 16,
        ),
        padding: EdgeInsets.only(
          left: widget.isUser ? 32 : 0,
          right: widget.isUser ? 0 : 32,
        ),
        child: AnimatedBuilder(
          animation: _borderAnimation,
          builder: (context, child) => CustomPaint(
            painter: _AnimatedScribbleBorderPainter(
              borderColor: widget.isUser
                  ? colorScheme.primary.withValues(alpha: 0.8)
                  : colorScheme.onSurface,
              fillColor: widget.isUser
                  ? colorScheme.primary.withValues(alpha: 0.9)
                  : colorScheme.secondary,
              seed: seed,
              isUser: widget.isUser,
              progress: _borderAnimation.value,
            ),
            child: Container(
              padding: EdgeInsets.only(
                left: widget.isUser ? 16 : 20,
                right: widget.isUser ? 20 : 16,
                top: 12,
                bottom: 12,
              ),
              child: AnimatedBuilder(
                animation: _textAnimation,
                builder: (context, child) => Opacity(
                  opacity: _textAnimation.value,
                  child: Text(
                    widget.text,
                    style: TextStyle(
                      color: widget.isUser
                          ? colorScheme.secondary
                          : colorScheme.onSurface,
                      fontSize: 16,
                      fontFamily: widget.fontFamily,
                      fontWeight: widget.fontWeight,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedScribbleBorderPainter extends CustomPainter {
  _AnimatedScribbleBorderPainter({
    required this.borderColor,
    required this.fillColor,
    required this.seed,
    required this.isUser,
    required this.progress,
  });

  final Color borderColor;
  final Color fillColor;
  final int seed;
  final bool isUser;
  final double progress;

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

    final path = _createScribblePath(size);

    // Draw fill if progress is complete
    if (progress >= 1.0) {
      canvas.drawPath(path, fillPaint);
    }

    // Draw animated border
    final pathMetrics = path.computeMetrics();
    final animatedPath = Path();

    for (final pathMetric in pathMetrics) {
      final extractLength = pathMetric.length * progress;
      final extractedPath = pathMetric.extractPath(0, extractLength);
      animatedPath.addPath(extractedPath, Offset.zero);
    }

    canvas.drawPath(animatedPath, borderPaint);
  }

  Path _createScribblePath(Size size) {
    final path = Path();
    final random = math.Random(seed);

    // Tail parameters
    const tailWidth = 16.0;
    const tailHeight = 24.0;
    final tailY = size.height * 0.7;

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

          // Draw tail going out
          final tailTipX = size.width + tailWidth;
          final tailTipY = tailY + random.nextDouble() * 3 - 1.5;

          path
            ..cubicTo(
              size.width + tailWidth * 0.3 + random.nextDouble() * 2 - 1,
              tailStartY + tailHeight * 0.2 + random.nextDouble() * 2 - 1,
              tailTipX - tailWidth * 0.2 + random.nextDouble() * 2 - 1,
              tailTipY - tailHeight * 0.1 + random.nextDouble() * 2 - 1,
              tailTipX + random.nextDouble() * 2 - 1,
              tailTipY,
            )
            // Draw tail coming back
            ..cubicTo(
              tailTipX - tailWidth * 0.2 + random.nextDouble() * 2 - 1,
              tailTipY + tailHeight * 0.1 + random.nextDouble() * 2 - 1,
              size.width + tailWidth * 0.3 + random.nextDouble() * 2 - 1,
              tailEndY - tailHeight * 0.2 + random.nextDouble() * 2 - 1,
              x,
              tailEndY,
            );
        }

        path.lineTo(x, y);
      }
    } else {
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
      final tailEndY = tailY + tailHeight / 4;
      path.lineTo(random.nextDouble() * 2 - 1, tailEndY);

      const tailTipX = -tailWidth;
      final tailTipY = tailY + random.nextDouble() * -1;

      path.cubicTo(
        -tailWidth * 0.3 + random.nextDouble() * 2 - 1,
        tailEndY - tailHeight * 0.2 + random.nextDouble() * 2 - 1,
        tailTipX + tailWidth * 0.2 + random.nextDouble() * 2 - 1,
        tailTipY + tailHeight * 0.1 + random.nextDouble() * 2 - 1,
        tailTipX + random.nextDouble() * 2 - 1,
        tailTipY,
      );

      final tailStartY = tailY - tailHeight / 2;
      path
        ..cubicTo(
          tailTipX + tailWidth * 0.2 + random.nextDouble() * 2 - 1,
          tailTipY - tailHeight * 0.1 + random.nextDouble() * 2 - 1,
          -tailWidth * 0.3 + random.nextDouble() * 2 - 1,
          tailStartY + tailHeight * 0.2 + random.nextDouble() * 2 - 1,
          random.nextDouble() * 2 - 1,
          tailStartY,
        )
        ..lineTo(random.nextDouble() * 2 - 1, radius);
    } else {
      path.lineTo(random.nextDouble() * 2 - 1, radius);
    }

    // Close path
    path
      ..quadraticBezierTo(
        random.nextDouble() * 2 - 1,
        random.nextDouble() * 2 - 1,
        radius,
        random.nextDouble() * 2 - 1,
      )
      ..close();

    return path;
  }

  @override
  bool shouldRepaint(_AnimatedScribbleBorderPainter oldDelegate) =>
      progress != oldDelegate.progress ||
      borderColor != oldDelegate.borderColor ||
      fillColor != oldDelegate.fillColor ||
      seed != oldDelegate.seed ||
      isUser != oldDelegate.isUser;
}
