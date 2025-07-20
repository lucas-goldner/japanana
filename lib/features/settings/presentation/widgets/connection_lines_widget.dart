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

class _ConnectionLinesWidgetState extends State<ConnectionLinesWidget>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  Set<String> _currentConnections = {};
  Set<String> _animatedConnections = {};

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animation.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
    
    // Get initial connections
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateConnections();
    });
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
    _animationController.dispose();
    super.dispose();
  }

  void _onControllerUpdate() {
    if (mounted) {
      _updateConnections();
      setState(() {});
    }
  }
  
  void _updateConnections() {
    final newConnections = _getCurrentConnections();
    final addedConnections = newConnections.difference(_currentConnections);
    
    if (addedConnections.isNotEmpty) {
      // New connections found - animate them
      _animatedConnections = addedConnections;
      _animationController.reset();
      _animationController.forward();
    }
    
    _currentConnections = newConnections;
  }
  
  Set<String> _getCurrentConnections() {
    final connections = <String>{};
    final children = widget.controller.children;
    
    for (var i = 0; i < children.length; i++) {
      for (var j = i + 1; j < children.length; j++) {
        final startItem = children[i];
        final endItem = children[j];
        
        final startCenter = Offset(
          startItem.offset.dx + startItem.size.width / 2,
          startItem.offset.dy + startItem.size.height / 2,
        );
        final endCenter = Offset(
          endItem.offset.dx + endItem.size.width / 2,
          endItem.offset.dy + endItem.size.height / 2,
        );
        
        final distance = (startCenter - endCenter).distance;
        
        if (distance <= widget.connectionRange) {
          connections.add('${startItem.key}-${endItem.key}');
        }
      }
    }
    
    return connections;
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
          animationProgress: _animation.value,
          animatedConnections: _animatedConnections,
        ),
      );
}
