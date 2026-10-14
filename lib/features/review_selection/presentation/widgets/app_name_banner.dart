import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';

class AppNameBanner extends StatelessWidget {
  const AppNameBanner({super.key});

  @override
  Widget build(BuildContext context) => Transform.scale(
        scale: 1.2,
        child: Transform.rotate(
          angle: -0.1,
          child: SizedBox(
            height: 24,
            child: ColoredBox(
              color: context.colorScheme.primary,
              child: Marquee(
                text: 'Japanana \u25B6\u25B6\u25B6',
                style: context.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'NotoSansJP',
                  color: context.colorScheme.secondary,
                ),
                blankSpace: 6,
              ),
            ),
          ),
        ),
      );
}

// Marquee Widget
// Copied from https://github.com/MarcelGarus/marquee/blob/master/lib/marquee.dart

class IntegralCurve extends Curve {
  factory IntegralCurve(Curve original) {
    var integral = 0.0;
    final values = <double, double>{};

    for (var t = 0.0; t <= 1.0; t += IntegralCurve.delta) {
      integral += original.transform(t) * t * IntegralCurve.delta;
      values[t] = integral;
    }
    values[1.0] = integral;

    // Normalize.
    for (final t in values.keys) {
      values[t] = values[t]! / integral;
    }

    return IntegralCurve._(original, integral, values);
  }

  const IntegralCurve._(this.original, this.integral, this._values);

  static double delta = 0.01;
  final Curve original;
  final double integral;
  final Map<double, double> _values;

  @override
  double transform(double t) {
    if (t < 0) return 0;
    for (final key in _values.keys) {
      if (key > t) return _values[key]!;
    }
    return 1;
  }
}

class Marquee extends StatefulWidget {
  const Marquee({
    required this.text,
    super.key,
    this.style,
    this.textScaleFactor,
    this.textDirection = TextDirection.rtl,
    this.scrollAxis = Axis.horizontal,
    this.crossAxisAlignment = CrossAxisAlignment.center,
    this.blankSpace = 0.0,
    this.velocity = 50.0,
    this.startAfter = Duration.zero,
    this.pauseAfterRound = Duration.zero,
    this.showFadingOnlyWhenScrolling = true,
    this.fadingEdgeStartFraction = 0.0,
    this.fadingEdgeEndFraction = 0.0,
    this.numberOfRounds,
    this.startPadding = 0.0,
    this.accelerationDuration = Duration.zero,
    this.accelerationCurve = const IntegralCurve._(Curves.decelerate, 1, {}),
    this.decelerationDuration = Duration.zero,
    this.decelerationCurve = const IntegralCurve._(Curves.decelerate, 1, {}),
    this.onDone,
  });

  final String text;
  final TextStyle? style;
  final double? textScaleFactor;
  final TextDirection textDirection;
  final Axis scrollAxis;
  final CrossAxisAlignment crossAxisAlignment;
  final double blankSpace;
  final double velocity;
  final Duration startAfter;
  final Duration pauseAfterRound;
  final int? numberOfRounds;
  final bool showFadingOnlyWhenScrolling;
  final double fadingEdgeStartFraction;
  final double fadingEdgeEndFraction;
  final double startPadding;
  final Duration accelerationDuration;
  final IntegralCurve accelerationCurve;
  final Duration decelerationDuration;
  final IntegralCurve decelerationCurve;
  final VoidCallback? onDone;

  @override
  State<StatefulWidget> createState() => _MarqueeState();
}

class _MarqueeState extends State<Marquee> with SingleTickerProviderStateMixin {
  final ScrollController _controller = ScrollController();
  late double _startPosition;
  late double _accelerationTarget;
  late double _linearTarget;
  late double _decelerationTarget;

  late Duration _totalDuration;

  Duration get _accelerationDuration => widget.accelerationDuration;
  Duration? _linearDuration;
  Duration get _decelerationDuration => widget.decelerationDuration;

  bool _running = false;
  bool _isOnPause = false;
  int _roundCounter = 0;
  bool get isDone =>
      widget.numberOfRounds != null && widget.numberOfRounds! <= _roundCounter;
  bool get showFading => !widget.showFadingOnlyWhenScrolling || !_isOnPause;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_running) {
        _running = true;
        if (_controller.hasClients) {
          _controller.jumpTo(_startPosition);
          await Future<void>.delayed(widget.startAfter);
          await Future.doWhile(_scroll);
        }
      }
    });
  }

  Future<bool> _scroll() async {
    await _makeRoundTrip();
    if (isDone && widget.onDone != null) {
      widget.onDone!();
    }
    return _running && !isDone && _controller.hasClients;
  }

  @override
  void didUpdateWidget(Widget oldWidget) {
    super.didUpdateWidget(oldWidget as Marquee);
  }

  @override
  void dispose() {
    _running = false;
    _controller.dispose();
    super.dispose();
  }

  void _initialize(BuildContext context) {
    final totalLength = _getTextWidth(context) + widget.blankSpace;
    final accelerationLength = widget.accelerationCurve.integral *
        widget.velocity *
        _accelerationDuration.inMilliseconds /
        1000.0;
    final decelerationLength = widget.decelerationCurve.integral *
        widget.velocity *
        _decelerationDuration.inMilliseconds /
        1000.0;
    final linearLength =
        (totalLength - accelerationLength.abs() - decelerationLength.abs()) *
            (widget.velocity > 0 ? 1 : -1);

    _startPosition = 2 * totalLength - widget.startPadding;
    _accelerationTarget = _startPosition + accelerationLength;
    _linearTarget = _accelerationTarget + linearLength;
    _decelerationTarget = _linearTarget + decelerationLength;

    _totalDuration = _accelerationDuration +
        _decelerationDuration +
        Duration(milliseconds: (linearLength / widget.velocity * 1000).toInt());
    _linearDuration =
        _totalDuration - _accelerationDuration - _decelerationDuration;

    assert(
      _totalDuration > Duration.zero,
      'With the given values, the total duration for one round would be '
      "negative. As time travel isn't invented yet, this shouldn't happen.",
    );
    assert(
      _linearDuration! >= Duration.zero,
      'Acceleration and deceleration phase overlap. To fix this, try a '
      'combination of these approaches:\n'
      "* Make the text longer, so there's more room to animate within.\n"
      '* Shorten the accelerationDuration or decelerationDuration.\n'
      '* Decrease the velocity, so the duration to animate within is longer.\n',
    );
  }

  Future<void> _makeRoundTrip() async {
    if (!_controller.hasClients) return;
    _controller.jumpTo(_startPosition);
    if (!_running) return;

    await _accelerate();
    if (!_running) return;

    await _moveLinearly();
    if (!_running) return;

    await _decelerate();

    _roundCounter++;

    if (!_running || !mounted) return;

    if (widget.pauseAfterRound > Duration.zero) {
      setState(() => _isOnPause = true);

      await Future<void>.delayed(widget.pauseAfterRound);

      if (!mounted || isDone) return;
      setState(() => _isOnPause = false);
    }
  }

  Future<void> _accelerate() async {
    await _animateTo(
      _accelerationTarget,
      _accelerationDuration,
      widget.accelerationCurve,
    );
  }

  Future<void> _moveLinearly() async {
    await _animateTo(_linearTarget, _linearDuration, Curves.linear);
  }

  Future<void> _decelerate() async {
    await _animateTo(
      _decelerationTarget,
      _decelerationDuration,
      widget.decelerationCurve.flipped,
    );
  }

  Future<void> _animateTo(
    double? target,
    Duration? duration,
    Curve curve,
  ) async {
    if (!_controller.hasClients) return;
    if (duration! > Duration.zero) {
      await _controller.animateTo(target!, duration: duration, curve: curve);
    } else {
      _controller.jumpTo(target!);
    }
  }

  double _getTextWidth(BuildContext context) {
    final span = TextSpan(text: widget.text, style: widget.style);

    const constraints = BoxConstraints();

    final richTextWidget = Text.rich(span).build(context) as RichText;
    final renderObject = richTextWidget.createRenderObject(context)
      ..layout(constraints);

    final boxes = renderObject.getBoxesForSelection(
      TextSelection(
        baseOffset: 0,
        extentOffset: TextSpan(text: widget.text).toPlainText().length,
      ),
    );

    return boxes.last.right;
  }

  @override
  Widget build(BuildContext context) {
    _initialize(context);
    final isHorizontal = widget.scrollAxis == Axis.horizontal;

    Alignment? alignment;

    switch (widget.crossAxisAlignment) {
      case CrossAxisAlignment.start:
        alignment = isHorizontal ? Alignment.topCenter : Alignment.centerLeft;
      case CrossAxisAlignment.end:
        alignment =
            isHorizontal ? Alignment.bottomCenter : Alignment.centerRight;
      case CrossAxisAlignment.center:
        alignment = Alignment.center;
      case CrossAxisAlignment.stretch:
      case CrossAxisAlignment.baseline:
        alignment = null;
    }

    final Widget marquee = ListView.builder(
      controller: _controller,
      scrollDirection: widget.scrollAxis,
      reverse: widget.textDirection == TextDirection.rtl,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, i) {
        final text = i.isEven
            ? Text(
                widget.text,
                style: widget.style,
                textScaler: widget.textScaleFactor != null
                    ? TextScaler.linear(widget.textScaleFactor!)
                    : null,
              )
            : _buildBlankSpace();
        return alignment == null
            ? text
            : Align(alignment: alignment, child: text);
      },
    );

    return marquee;
  }

  Widget _buildBlankSpace() => SizedBox(
        width: widget.scrollAxis == Axis.horizontal ? widget.blankSpace : null,
        height: widget.scrollAxis == Axis.vertical ? widget.blankSpace : null,
      );
}
