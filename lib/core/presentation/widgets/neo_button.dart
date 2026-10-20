import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';

const _kPressDuration = Duration(milliseconds: 90);

/// Neubrutalist button: outlined, flat filled and lifted by a hard shadow.
/// While pressed it slides onto its shadow.
class NeoButton extends StatefulWidget {
  const NeoButton({
    required this.onPressed,
    required this.child,
    this.color,
    this.foregroundColor,
    this.shadowColor,
    this.minHeight = 64,
    this.padding = const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    super.key,
  });

  final VoidCallback onPressed;
  final Widget child;

  /// Defaults to the neo card color.
  final Color? color;

  /// Text and icon color. Defaults to the color readable on [color].
  final Color? foregroundColor;
  final Color? shadowColor;
  final double minHeight;
  final EdgeInsets padding;

  @override
  State<NeoButton> createState() => _NeoButtonState();
}

class _NeoButtonState extends State<NeoButton> {
  bool _pressed = false;

  void _setPressed(bool pressed) => setState(() => _pressed = pressed);

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;

    return GestureDetector(
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      onTap: widget.onPressed,
      child: AnimatedContainer(
        duration: _kPressDuration,
        constraints: BoxConstraints(minHeight: widget.minHeight),
        padding: widget.padding,
        transform: Matrix4.translationValues(
          _pressed ? neo.shadowOffset.dx : 0,
          _pressed ? neo.shadowOffset.dy : 0,
          0,
        ),
        decoration: neo.decoration(
          color: widget.color,
          shadowColor: widget.shadowColor,
          pressed: _pressed,
        ),
        child: Center(
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: widget.foregroundColor ?? neo.onCard,
              fontWeight: FontWeight.bold,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
