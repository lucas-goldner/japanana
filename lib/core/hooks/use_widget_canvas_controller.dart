import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:japanana/core/presentation/widgets/widget_canvas.dart';

WidgetCanvasController useWidgetCanvasController({
  required List<WidgetCanvasChild> children,
  Matrix4? initialTransform,
}) {
  final controller = useMemoized(() => WidgetCanvasController(children));

  useEffect(
    () {
      if (initialTransform != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.transform.value = initialTransform;
        });
      }
      return controller.dispose;
    },
    [],
  );

  return controller;
}

WidgetCanvasController useCenteredWidgetCanvasController({
  required List<WidgetCanvasChild> children,
  required BuildContext context,
  Offset centerOffset = Offset.zero,
  double scale = 1.0,
}) {
  final controller = useMemoized(() => WidgetCanvasController(children));

  useEffect(
    () {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final screenSize = MediaQuery.of(context).size;
        final centerX = screenSize.width / 2;
        final centerY = screenSize.height / 2;

        controller.transform.value = Matrix4.identity()
          ..translate(centerX + centerOffset.dx, centerY + centerOffset.dy)
          ..scale(scale, scale, 1);
      });
      return controller.dispose;
    },
    [],
  );

  return controller;
}
