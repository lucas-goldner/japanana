import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';

// Constants
const double kDefaultCanvasWidth = 10000;
const double kDefaultCanvasHeight = 10000;
const double kDefaultMinScale = 0.4;
const double kDefaultMaxScale = 4;
const double kDefaultSelectionInset = 2;
const double kDefaultChildElevation = 4;
const double kDefaultResetThreshold = 500;

// Default selection widget
class _DefaultSelectionWidget extends StatelessWidget {
  const _DefaultSelectionWidget();

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor,
            width: 2,
          ),
        ),
      );
}

class WidgetCanvas extends StatefulWidget {
  const WidgetCanvas({
    required this.controller,
    this.canvasSize = const Size(kDefaultCanvasWidth, kDefaultCanvasHeight),
    this.minScale = kDefaultMinScale,
    this.maxScale = kDefaultMaxScale,
    this.selectionInset = kDefaultSelectionInset,
    this.childElevation = kDefaultChildElevation,
    this.backgroundColor,
    this.selectionWidget = const _DefaultSelectionWidget(),
    this.onInteractionStart,
    this.onInteractionEnd,
    this.showResetButton = true,
    this.resetThreshold = kDefaultResetThreshold,
    this.backgroundWidget,
    super.key,
  });

  final WidgetCanvasController controller;
  final Size canvasSize;
  final double minScale;
  final double maxScale;
  final double selectionInset;
  final double childElevation;
  final Color? backgroundColor;
  final Widget selectionWidget;
  final void Function(ScaleStartDetails details)? onInteractionStart;
  final void Function(ScaleEndDetails details)? onInteractionEnd;
  final bool showResetButton;
  final double resetThreshold;
  final Widget? backgroundWidget;

  @override
  State<WidgetCanvas> createState() => WidgetCanvasState();
}

class WidgetCanvasState extends State<WidgetCanvas> {
  Matrix4? _initialTransform;
  bool _showResetButton = false;

  @override
  void initState() {
    super.initState();
    controller.addListener(onUpdate);
    // Store initial transform for reset functionality
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialTransform = Matrix4.copy(controller.transform.value);
    });
  }

  @override
  void dispose() {
    controller.removeListener(onUpdate);
    super.dispose();
  }

  void onUpdate() {
    if (mounted) {
      // Check if we should show the reset button
      if (widget.showResetButton && _initialTransform != null) {
        final currentTransform = controller.transform.value;
        final initialTransform = _initialTransform!;

        // Calculate distance from initial position
        final currentTranslation = currentTransform.getTranslation();
        final initialTranslation = initialTransform.getTranslation();
        final distance = (currentTranslation - initialTranslation).length;

        final shouldShow = distance > widget.resetThreshold;
        if (shouldShow != _showResetButton) {
          _showResetButton = shouldShow;
        }
      }
      setState(() {});
    }
  }

  WidgetCanvasController get controller => widget.controller;

  void _resetToCenter() {
    if (_initialTransform != null) {
      setState(() {
        _showResetButton = false;
      });
      controller.transform.value = Matrix4.copy(_initialTransform!);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
        color: widget.backgroundColor,
        child: Stack(
          children: [
            Listener(
              onPointerDown: (details) {
                controller.checkSelection(details.localPosition);
              },
              onPointerUp: (details) {
                controller.handlePointerUp(details.localPosition);
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
                  widget.onInteractionStart?.call(details);
                },
                onInteractionUpdate: (details) {
                  if (!controller.mouseDown) {
                    controller.scale = details.scale;
                  } else {
                    controller.moveSelection(details.focalPoint);
                  }
                  controller.mousePosition = details.focalPoint;
                },
                onInteractionEnd: (details) {
                  widget.onInteractionEnd?.call(details);
                },
                minScale: widget.minScale,
                maxScale: widget.maxScale,
                boundaryMargin: const EdgeInsets.all(double.infinity),
                builder: (context, viewport) => SizedBox(
                  width: widget.canvasSize.width,
                  height: widget.canvasSize.height,
                  child: Stack(
                    children: [
                      // Background widget layer
                      if (widget.backgroundWidget != null)
                        Positioned.fill(
                          child: widget.backgroundWidget!,
                        ),
                      // Main content layer
                      CustomMultiChildLayout(
                        delegate:
                            WidgetCanvasDelegate(controller, widget.canvasSize),
                        children: controller.children
                            .map(
                              (e) => LayoutId(
                                id: e,
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    Positioned.fill(
                                      child: SizedBox.fromSize(
                                        size: e.size,
                                        child: e.child,
                                      ),
                                    ),
                                    if (controller.isSelected(e.key!))
                                      Positioned.fill(
                                        top: -widget.selectionInset,
                                        left: -widget.selectionInset,
                                        right: -widget.selectionInset,
                                        bottom: -widget.selectionInset,
                                        child: widget.selectionWidget,
                                      ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Reset button overlay
            if (_showResetButton)
              Positioned(
                top: 16,
                right: 16,
                child: FloatingActionButton.small(
                  onPressed: _resetToCenter,
                  backgroundColor: context.colorScheme.primary,
                  foregroundColor: context.colorScheme.onPrimary,
                  child: const Icon(Icons.center_focus_strong),
                ),
              ),
          ],
        ),
      );
}

class WidgetCanvasDelegate extends MultiChildLayoutDelegate {
  WidgetCanvasDelegate(this.controller, this.canvasSize);
  final WidgetCanvasController controller;
  final Size canvasSize;
  List<WidgetCanvasChild> get children => controller.children;

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
    this.onTap,
  }) : super(key: key);

  final Size size;
  final Offset offset;
  final Widget child;
  final VoidCallback? onTap;

  Rect get rect => offset & size;

  WidgetCanvasChild copyWith({
    Size? size,
    Offset? offset,
    Widget? child,
    VoidCallback? onTap,
  }) =>
      WidgetCanvasChild(
        key: key!,
        size: size ?? this.size,
        offset: offset ?? this.offset,
        onTap: onTap ?? this.onTap,
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
  Offset? _pointerDownPosition;
  WidgetCanvasChild? _potentialTapTarget;
  static const _tapThreshold = 5.0; // pixels

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
    WidgetCanvasChild? tappedChild;

    for (final child in children) {
      final rect = child.rect;
      if (rect.contains(offset)) {
        selection.add(child.key!);
        tappedChild = child;
      }
    }

    _pointerDownPosition = localPosition;
    _potentialTapTarget = tappedChild;

    if (selection.isNotEmpty) {
      setSelection({selection.last});
      mouseDown = true;
    } else {
      deselectAll();
      mouseDown = false;
    }
  }

  void handlePointerUp(Offset localPosition) {
    if (_pointerDownPosition != null && _potentialTapTarget != null) {
      final distance = (localPosition - _pointerDownPosition!).distance;

      // If pointer moved less than threshold, it's a tap
      if (distance < _tapThreshold && _potentialTapTarget!.onTap != null) {
        _potentialTapTarget!.onTap!();
      }
    }

    _pointerDownPosition = null;
    _potentialTapTarget = null;
    mouseDown = false;
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
    _selected
      ..clear()
      ..addAll(keys);
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
