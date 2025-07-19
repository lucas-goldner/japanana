import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart' hide Colors;

class WidgetCanvas extends StatefulWidget {
  const WidgetCanvas({required this.controller, super.key});

  final WidgetCanvasController controller;

  @override
  State<WidgetCanvas> createState() => WidgetCanvasState();
}

class WidgetCanvasState extends State<WidgetCanvas> {
  @override
  void initState() {
    super.initState();
    controller.addListener(onUpdate);
  }

  @override
  void dispose() {
    controller.removeListener(onUpdate);
    super.dispose();
  }

  void onUpdate() {
    if (mounted) setState(() {});
  }

  static const Size _gridSize = Size.square(50);
  WidgetCanvasController get controller => widget.controller;

  Rect axisAlignedBoundingBox(Quad quad) {
    var xMin = quad.point0.x;
    var xMax = quad.point0.x;
    var yMin = quad.point0.y;
    var yMax = quad.point0.y;
    for (final point in <Vector3>[
      quad.point1,
      quad.point2,
      quad.point3,
    ]) {
      if (point.x < xMin) {
        xMin = point.x;
      } else if (point.x > xMax) {
        xMax = point.x;
      }

      if (point.y < yMin) {
        yMin = point.y;
      } else if (point.y > yMax) {
        yMax = point.y;
      }
    }

    return Rect.fromLTRB(xMin, yMin, xMax, yMax);
  }

  @override
  Widget build(BuildContext context) {
    const inset = 2.0;
    return Listener(
      onPointerDown: (details) {
        controller.checkSelection(details.localPosition);
      },
      onPointerUp: (details) {
        controller.mouseDown = false;
      },
      onPointerCancel: (details) {
        controller.mouseDown = false;
      },
      onPointerMove: (details) {},
      child: InteractiveViewer.builder(
        transformationController: controller.transform,
        panEnabled: controller.canvasMoveEnabled,
        scaleEnabled: controller.canvasMoveEnabled,
        onInteractionStart: (details) {
          controller.mousePosition = details.focalPoint;
        },
        onInteractionUpdate: (details) {
          if (!controller.mouseDown) {
            controller.scale = details.scale;
          } else {
            controller.moveSelection(details.focalPoint);
          }
          controller.mousePosition = details.focalPoint;
        },
        onInteractionEnd: (details) {},
        minScale: 0.4,
        maxScale: 4,
        boundaryMargin: const EdgeInsets.all(double.infinity),
        builder: (context, viewport) => SizedBox(
          width: 10000,
          height: 10000,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: GridBackgroundBuilder(
                  cellWidth: _gridSize.width,
                  cellHeight: _gridSize.height,
                  viewport: axisAlignedBoundingBox(viewport),
                ),
              ),
              Positioned.fill(
                child: CustomMultiChildLayout(
                  delegate: WidgetCanvasDelegate(controller),
                  children: controller.children
                      .map(
                        (e) => LayoutId(
                          id: e,
                          child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned.fill(
                                child: Material(
                                  elevation: 4,
                                  child: SizedBox.fromSize(
                                    size: e.size,
                                    child: e.child,
                                  ),
                                ),
                              ),
                              if (controller.isSelected(e.key!))
                                Positioned.fill(
                                  top: -inset,
                                  left: -inset,
                                  right: -inset,
                                  bottom: -inset,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GridBackgroundBuilder extends StatelessWidget {
  const GridBackgroundBuilder({
    required this.cellWidth,
    required this.cellHeight,
    required this.viewport,
    super.key,
  });

  final double cellWidth;
  final double cellHeight;
  final Rect viewport;

  @override
  Widget build(BuildContext context) {
    final firstRow = (viewport.top / cellHeight).floor();
    final lastRow = (viewport.bottom / cellHeight).ceil();
    final firstCol = (viewport.left / cellWidth).floor();
    final lastCol = (viewport.right / cellWidth).ceil();

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        for (int row = firstRow; row < lastRow; row++)
          for (int col = firstCol; col < lastCol; col++)
            Positioned(
              left: col * cellWidth,
              top: row * cellHeight,
              child: Container(
                height: cellHeight,
                width: cellWidth,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey.withValues(alpha: 0.1),
                  ),
                ),
              ),
            ),
      ],
    );
  }
}

class WidgetCanvasDelegate extends MultiChildLayoutDelegate {
  WidgetCanvasDelegate(this.controller);
  final WidgetCanvasController controller;
  List<WidgetCanvasChild> get children => controller.children;

  Size backgroundSize = const Size(100000, 100000);
  late Offset backgroundOffset = Offset(
    -backgroundSize.width / 2,
    -backgroundSize.height / 2,
  );

  @override
  void performLayout(Size size) {
    // Then draw the screens.
    for (final widget in children) {
      layoutChild(widget, BoxConstraints.tight(widget.size));
      positionChild(widget, widget.offset);
    }
  }

  @override
  bool shouldRelayout(WidgetCanvasDelegate oldDelegate) => true;
}

class WidgetCanvasChild extends StatelessWidget {
  const WidgetCanvasChild({
    required Key key,
    required this.size,
    required this.offset,
    required this.child,
  }) : super(key: key);

  final Size size;
  final Offset offset;
  final Widget child;

  Rect get rect => offset & size;

  WidgetCanvasChild copyWith({
    Size? size,
    Offset? offset,
    Widget? child,
  }) =>
      WidgetCanvasChild(
        key: key!,
        size: size ?? this.size,
        offset: offset ?? this.offset,
        child: child ?? this.child,
      );

  @override
  Widget build(BuildContext context) => child;
}

class WidgetCanvasController extends ChangeNotifier {
  WidgetCanvasController(this.children);

  final List<WidgetCanvasChild> children;
  final Set<Key> _selected = {};
  late final transform = TransformationController();
  Matrix4 get matrix => transform.value;
  double scale = 1;
  Offset mousePosition = Offset.zero;

  bool _mouseDown = false;
  bool get mouseDown => _mouseDown;
  set mouseDown(bool value) {
    _mouseDown = value;
    notifyListeners();
  }

  bool isSelected(Key key) => _selected.contains(key);

  bool get hasSelection => _selected.isNotEmpty;

  bool get canvasMoveEnabled => !mouseDown;

  Offset toLocal(Offset global) => transform.toScene(global);

  void checkSelection(Offset localPosition) {
    final offset = toLocal(localPosition);
    final selection = <Key>[];
    for (final child in children) {
      final rect = child.rect;
      if (rect.contains(offset)) {
        selection.add(child.key!);
      }
    }
    if (selection.isNotEmpty) {
      setSelection({selection.last});
      mouseDown = true;
    } else {
      deselectAll();
      mouseDown = false;
    }
  }

  void moveSelection(Offset position) {
    final delta = toLocal(position) - toLocal(mousePosition);
    for (final key in _selected) {
      final index = children.indexWhere((e) => e.key == key);
      if (index == -1) continue;
      final current = children[index];
      children[index] = current.copyWith(
        offset: current.offset + delta,
      );
    }
    mousePosition = position;
    notifyListeners();
  }

  void select(Key key) {
    _selected.add(key);
    notifyListeners();
  }

  void setSelection(Set<Key> keys) {
    _selected.clear();
    _selected.addAll(keys);
    notifyListeners();
  }

  void deselect(Key key) {
    _selected.remove(key);
    notifyListeners();
  }

  void deselectAll() {
    _selected.clear();
    notifyListeners();
  }

  void add(WidgetCanvasChild child) {
    children.add(child);
    notifyListeners();
  }

  void remove(Key key) {
    children.removeWhere((e) => e.key == key);
    notifyListeners();
  }
}
