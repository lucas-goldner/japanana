import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class PageCurlTransition extends StatefulWidget {
  const PageCurlTransition({
    required this.animation,
    required this.child,
    required this.capturedImage,
    super.key,
  });

  final Animation<double> animation;
  final Widget child;
  final ui.Image capturedImage;

  @override
  State<PageCurlTransition> createState() => _PageCurlTransitionState();
}

class _PageCurlTransitionState extends State<PageCurlTransition> {
  ui.FragmentProgram? _program;

  @override
  void initState() {
    super.initState();
    _loadShader();
  }

  Future<void> _loadShader() async {
    _program = await ui.FragmentProgram.fromAsset(
      'assets/shaders/page_curl.frag',
    );
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) => Stack(
        fit: StackFit.expand,
        children: [
          // Destination page
          widget.child,

          // Page curl overlay
          if (_program != null)
            AnimatedBuilder(
              animation: widget.animation,
              builder: (context, child) {
                // Hide when animation is complete
                if (widget.animation.value >= 1.0) {
                  return const SizedBox.shrink();
                }

                // Calculate fade out for smooth ending
                double opacity = 1;
                if (widget.animation.value > 0.8) {
                  // Fade out during last 30% of animation
                  opacity = 1.0 - ((widget.animation.value - 0.8) / 0.2);
                }

                return IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: opacity,
                    duration: Duration.zero,
                    child: CustomPaint(
                      painter: _PageCurlPainter(
                        shader: _program!.fragmentShader(),
                        image: widget.capturedImage,
                        progress: widget.animation.value,
                      ),
                      size: Size.infinite,
                    ),
                  ),
                );
              },
            ),
        ],
      );
}

class _PageCurlPainter extends CustomPainter {
  _PageCurlPainter({
    required this.shader,
    required this.image,
    required this.progress,
  });

  final ui.FragmentShader shader;
  final ui.Image image;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // Set shader uniforms
    shader
      ..setFloat(0, size.width) // resolution.x
      ..setFloat(1, size.height) // resolution.y
      ..setFloat(
        2,
        size.width - (size.width * progress * 1.1),
      ) // pointer (right to left)
      ..setFloat(3, size.width) // origin
      ..setFloat(4, 0) // container.x
      ..setFloat(5, 0) // container.y
      ..setFloat(6, size.width) // container.z (width)
      ..setFloat(7, size.height) // container.w (height)
      ..setFloat(8, 20) // cornerRadius
      ..setImageSampler(0, image); // image

    // Draw the shader
    final paint = Paint()..shader = shader;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );
  }

  @override
  bool shouldRepaint(_PageCurlPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// Navigation helper
Future<T?> navigateWithPageCurl<T extends Object?>(
  BuildContext context,
  Widget destination,
) async {
  // Find the nearest RepaintBoundary
  RenderRepaintBoundary? boundary;
  context.visitAncestorElements((element) {
    final renderObject = element.renderObject;
    if (renderObject is RenderRepaintBoundary) {
      boundary = renderObject;
      return false;
    }
    return true;
  });

  if (boundary == null) {
    // Fallback to normal navigation
    if (!context.mounted) return null;
    return Navigator.of(context).push(
      MaterialPageRoute<T>(builder: (_) => destination),
    );
  }

  // Capture current screen
  final image = await boundary!.toImage(pixelRatio: 3);

  // Navigate with page curl
  if (!context.mounted) return null;
  return Navigator.of(context).push(
    PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => destination,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          PageCurlTransition(
        animation: animation,
        capturedImage: image,
        child: child,
      ),
    ),
  );
}
