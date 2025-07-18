import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/features/settings/presentation/radial_page_transition.dart';
import 'package:japanana/features/settings/presentation/settings.dart';

class OpenSettingsButton extends HookWidget {
  const OpenSettingsButton({super.key});

  @override
  Widget build(BuildContext context) {
    final rotationController = useAnimationController(
      duration: const Duration(seconds: 2),
    )..repeat();

    final rotationValue = useAnimation(rotationController);

    void openSettings() {
      // Get the button's global position
      final renderBox = context.findRenderObject()! as RenderBox;
      final buttonOffset = renderBox.localToGlobal(Offset.zero);
      final buttonSize = renderBox.size;

      // Calculate the center of the button
      final anchorOffset = Offset(
        buttonOffset.dx + buttonSize.width / 2,
        buttonOffset.dy + buttonSize.height / 2,
      );

      Navigator.of(context).push(
        RadialPageTransition(
          child: const Settings(),
          anchorOffset: anchorOffset,
        ),
      );
    }

    return GestureDetector(
      onTap: openSettings,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedRotation(
            duration: rotationController.duration ?? Duration.zero,
            turns: rotationValue,
            child: IconButton(
              onPressed: openSettings,
              icon: Icon(
                Icons.settings_outlined,
                size: 80,
                color: context.colorScheme.primary,
              ),
            ),
          ),
          Positioned(
            child: _RotatingText(
              text: 'Settings',
              radius: 60,
              textStyle: context.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.primary,
                  ) ??
                  const TextStyle(),
              rotationDuration: const Duration(seconds: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _RotatingText extends StatefulWidget {
  const _RotatingText({
    required this.text,
    required this.radius,
    required this.textStyle,
    required this.rotationDuration,
  });

  final String text;
  final double radius;
  final TextStyle textStyle;
  final Duration rotationDuration;

  @override
  _RotatingTextState createState() => _RotatingTextState();
}

class _RotatingTextState extends State<_RotatingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.rotationDuration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _controller,
        builder: (context, child) => CustomPaint(
          size: Size(widget.radius * 2, widget.radius * 2),
          painter: _CircularTextPainter(
            text: widget.text,
            radius: widget.radius,
            textStyle: widget.textStyle,
            progress: _controller.value,
          ),
        ),
      );
}

class _CircularTextPainter extends CustomPainter {
  _CircularTextPainter({
    required this.text,
    required this.radius,
    required this.textStyle,
    required this.progress,
  });
  final String text;
  final double radius;
  final TextStyle textStyle;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    const totalAngle = 2 * math.pi;
    var startAngle = -math.pi / 2 + (progress * totalAngle);

    // Calculate the total width of the text and dot
    final textWidth = _calculateTextWidth(text);
    final dotWidth = textStyle.fontSize!;
    final totalWidth = textWidth + dotWidth;

    // Calculate how many times the text can fit
    const repetitions = 2;

    const segmentAngle = totalAngle / repetitions;
    final textAngle = (textWidth / totalWidth) * segmentAngle;
    final dotAngle = segmentAngle - textAngle;

    for (var rep = 0; rep < repetitions; rep++) {
      // Draw the dot before the text
      _drawDot(canvas, centerX, centerY, startAngle, radius);

      // Adjust the start angle for the text to come after the dot
      // double textStartAngle = startAngle + dotAngle;
      final textStartAngle = startAngle + dotAngle / 2; //+ 1.5 * dotAngle;

      // Pre-calculate character widths and total width
      final charWidths = <double>[];
      double totalCharWidth = 0;
      for (var i = 0; i < text.length; i++) {
        final textSpan = TextSpan(text: text[i], style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();
        charWidths.add(textPainter.width);
        totalCharWidth += textPainter.width;
      }

      // Draw the text
      var currentAngle = textStartAngle;
      for (var i = 0; i < text.length; i++) {
        final textSpan = TextSpan(text: text[i], style: textStyle);
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
        )..layout();

        // Calculate the proportion of the total angle
        // this character should occupy
        final charProportion = charWidths[i] / totalCharWidth;
        final charAngle = textAngle * charProportion;

        // Center the character within its allocated angle
        final charCenterAngle = currentAngle + (charAngle / 2);

        final x = centerX + radius * math.cos(charCenterAngle);
        final y = centerY + radius * math.sin(charCenterAngle);

        canvas
          ..save()
          ..translate(x, y)
          ..rotate(charCenterAngle + math.pi / 2);

        textPainter.paint(
          canvas,
          Offset(-charWidths[i] / 2, -textPainter.height / 2),
        );

        canvas.restore();

        // Update the angle for the next character
        currentAngle += charAngle;
      }

      // Update the start angle for the next repetition
      startAngle += segmentAngle;
    }
  }

  double _calculateTextWidth(String text) {
    final textSpan = TextSpan(text: text, style: textStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    )..layout();
    return textPainter.width;
  }

  void _drawDot(
    Canvas canvas,
    double centerX,
    double centerY,
    double angle,
    double radius,
  ) {
    final dotRadius = textStyle.fontSize! / 4;
    final dotPaint = Paint()
      ..color = textStyle.color!
      ..style = PaintingStyle.fill;

    final dotX = centerX + radius * math.cos(angle);
    final dotY = centerY + radius * math.sin(angle);

    canvas.drawCircle(Offset(dotX, dotY), dotRadius, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
