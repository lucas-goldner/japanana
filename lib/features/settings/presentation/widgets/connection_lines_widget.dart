import 'package:flutter/material.dart';
import 'package:japanana/core/presentation/widgets/widget_canvas.dart';
import 'package:japanana/features/settings/presentation/widgets/settings_connection_painter.dart';

class ConnectionLinesWidget extends StatefulWidget {
  const ConnectionLinesWidget({
    required this.controller,
    this.lineColor,
    this.lineWidth = 1.0,
    this.opacity = 0.3,
    this.connectionRange = 100.0,
    this.linePadding = 10.0,
    super.key,
  });

  final WidgetCanvasController controller;
  final Color? lineColor;
  final double lineWidth;
  final double opacity;
  final double connectionRange;
  final double linePadding;

  @override
  State<ConnectionLinesWidget> createState() => _ConnectionLinesWidgetState();
}

class _ConnectionLinesWidgetState extends State<ConnectionLinesWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void didUpdateWidget(ConnectionLinesWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerUpdate);
      widget.controller.addListener(_onControllerUpdate);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: SettingsConnectionPainter(
          canvasController: widget.controller,
          lineColor: widget.lineColor,
          lineWidth: widget.lineWidth,
          opacity: widget.opacity,
          connectionRange: widget.connectionRange,
          linePadding: widget.linePadding,
        ),
      );
}
