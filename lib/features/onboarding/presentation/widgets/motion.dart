import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

const _kRevealDuration = Duration(milliseconds: 550);
const _kWordStagger = Duration(milliseconds: 70);
const _kCharacterStagger = Duration(milliseconds: 35);
const _kWordDuration = Duration(milliseconds: 600);
const _kWordBlur = 12.0;

/// Progress from 0 to 1 that starts after [delay] and runs for [duration].
double useDelayedProgress({
  required Duration duration,
  Duration delay = Duration.zero,
  Curve curve = Curves.easeOutCubic,
}) {
  final total = delay + duration;
  final controller = useAnimationController(duration: total);
  useEffect(() {
    controller.forward();
    return null;
  }, const []);
  final value = useAnimation(controller);
  final start = total == Duration.zero
      ? 0.0
      : delay.inMicroseconds / total.inMicroseconds;
  return Interval(start, 1, curve: curve).transform(value);
}

/// Value of a controller that repeats forever, for idle motion.
double useLoop(Duration period) {
  final controller = useAnimationController(duration: period);
  useEffect(() {
    controller.repeat();
    return null;
  }, const []);
  return useAnimation(controller);
}

/// Fades, slides, scales and sharpens [child] into place after [delay].
class Reveal extends HookWidget {
  const Reveal({
    required this.child,
    this.delay = Duration.zero,
    this.duration = _kRevealDuration,
    this.offset = const Offset(0, 18),
    this.scale = 0,
    this.blur = 8,
    this.rotation = 0,
    this.curve = Curves.easeOutCubic,
    super.key,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;

  /// Where the child starts, relative to its final position.
  final Offset offset;

  /// How much smaller the child starts, 0.25 starts at 75%.
  final double scale;
  final double blur;

  /// Starting rotation in degrees.
  final double rotation;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final progress = useDelayedProgress(
      duration: duration,
      delay: delay,
      curve: curve,
    );
    return RevealTransform(
      progress: progress,
      offset: offset,
      scale: scale,
      blur: blur,
      rotation: rotation,
      child: child,
    );
  }
}

/// Paints [child] at [progress] of a [Reveal].
class RevealTransform extends StatelessWidget {
  const RevealTransform({
    required this.progress,
    required this.child,
    this.offset = const Offset(0, 18),
    this.scale = 0,
    this.blur = 8,
    this.rotation = 0,
    super.key,
  });

  final double progress;
  final Widget child;
  final Offset offset;
  final double scale;
  final double blur;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    final remaining = 1 - progress;
    final sigma = blur * remaining.clamp(0.0, 1.0);
    Widget result = Transform(
      alignment: Alignment.center,
      transform:
          Matrix4.translationValues(
              offset.dx * remaining,
              offset.dy * remaining,
              0,
            )
            ..multiply(
              Matrix4.diagonal3Values(
                1 - remaining * scale,
                1 - remaining * scale,
                1,
              ),
            )
            ..multiply(Matrix4.rotationZ(rotation * remaining * pi / 180)),
      child: child,
    );
    // Always in the tree so finishing the blur doesn't remount the child.
    result = ImageFiltered(
      enabled: sigma > 0.05,
      imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
      child: result,
    );
    return Opacity(opacity: progress.clamp(0.0, 1.0), child: result);
  }
}

/// Headline that sharpens in word by word. Text without spaces, like
/// Japanese, reveals character by character. Wrap words in `*` to highlight
/// them.
class BlurWords extends StatelessWidget {
  const BlurWords(
    this.text, {
    required this.style,
    this.delay = Duration.zero,
    this.highlightBuilder,
    this.textAlign = TextAlign.start,
    super.key,
  });

  final String text;
  final TextStyle style;
  final Duration delay;

  /// Wraps a highlighted word. Without it highlights render like other words.
  final Widget Function(String word)? highlightBuilder;
  final TextAlign textAlign;

  List<({String text, bool highlight})> get _tokens {
    final perCharacter = !text.replaceAll('*', '').trim().contains(' ');
    final tokens = <({String text, bool highlight})>[];
    final segments = text.split('*');
    for (var i = 0; i < segments.length; i++) {
      final highlight = i.isOdd;
      final segment = segments[i];
      if (segment.isEmpty) continue;
      if (highlight) {
        tokens.add((text: segment, highlight: true));
      } else if (perCharacter) {
        tokens.addAll(
          segment.characters.map((char) => (text: char, highlight: false)),
        );
      } else {
        for (final match in RegExp(r'\S+\s*|\s+').allMatches(segment)) {
          tokens.add((text: match.group(0)!, highlight: false));
        }
      }
    }
    return tokens;
  }

  @override
  Widget build(BuildContext context) {
    final tokens = _tokens;
    final stagger = text.contains(' ') ? _kWordStagger : _kCharacterStagger;
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: switch (textAlign) {
          TextAlign.center => WrapAlignment.center,
          TextAlign.end || TextAlign.right => WrapAlignment.end,
          _ => WrapAlignment.start,
        },
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          for (final (index, token) in tokens.indexed)
            Reveal(
              delay: delay + stagger * index,
              duration: _kWordDuration,
              offset: const Offset(0, 10),
              blur: _kWordBlur,
              child: token.highlight && highlightBuilder != null
                  ? highlightBuilder!(token.text)
                  : Text(token.text, style: style),
            ),
        ],
      ),
    );
  }
}

/// Number that counts from [from] to [to] after [delay].
class RollingNumber extends HookWidget {
  const RollingNumber({
    required this.to,
    required this.style,
    this.from = 0,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 1200),
    super.key,
  });

  final int from;
  final int to;
  final TextStyle style;
  final Duration delay;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final progress = useDelayedProgress(
      duration: duration,
      delay: delay,
      curve: Curves.easeInOutCubic,
    );
    return Text(
      '${(from + (to - from) * progress).round()}',
      style: style.copyWith(fontFeatures: const [FontFeature.tabularFigures()]),
    );
  }
}

/// Bobs [child] up and down, for elements waiting on screen.
class Float extends HookWidget {
  const Float({
    required this.child,
    this.phase = 0,
    this.distance = 4,
    super.key,
  });

  final Widget child;
  final double phase;
  final double distance;

  @override
  Widget build(BuildContext context) {
    final loop = useLoop(const Duration(milliseconds: 3900));
    return Transform.translate(
      offset: Offset(0, sin(loop * 2 * pi + phase) * distance),
      child: child,
    );
  }
}

/// Gently pulses [child] to draw the eye to the main action.
class Pulse extends HookWidget {
  const Pulse({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final loop = useLoop(const Duration(milliseconds: 1250));
    return Transform.scale(scale: 1 + sin(loop * 2 * pi) * 0.025, child: child);
  }
}
