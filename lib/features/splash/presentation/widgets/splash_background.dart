import 'package:flutter/material.dart';

/// The backdrop behind the splash screen: soft sage shapes in the top-right
/// and bottom-left corners.
///
/// Decorations are drawn edge to edge (behind system bars); keep [child]
/// inside a [SafeArea]. They are excluded from semantics and hit testing.
class SplashBackground extends StatelessWidget {
  const SplashBackground({super.key, required this.child});

  /// Opacity of the sage corner shapes.
  static const double shapeOpacity = 0.75;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final sage = Theme.of(
      context,
    ).colorScheme.secondaryContainer.withValues(alpha: shapeOpacity);

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: ExcludeSemantics(
            child: CustomPaint(painter: SplashBackgroundPainter(shape: sage)),
          ),
        ),
        child,
      ],
    );
  }
}

/// Paints the corner shapes of [SplashBackground].
@visibleForTesting
class SplashBackgroundPainter extends CustomPainter {
  const SplashBackgroundPainter({required this.shape});

  final Color shape;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final paint = Paint()..color = shape;

    // Top-right corner shape.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.68, 0)
        ..cubicTo(w * 0.7, h * 0.08, w * 0.8, h * 0.15, w * 0.92, h * 0.155)
        ..cubicTo(w * 0.96, h * 0.157, w * 0.98, h * 0.152, w, h * 0.145)
        ..lineTo(w, 0)
        ..close(),
      paint,
    );

    // Bottom-left corner shape.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.82)
        ..cubicTo(w * 0.14, h * 0.82, w * 0.3, h * 0.89, w * 0.38, h)
        ..lineTo(0, h)
        ..close(),
      paint,
    );
  }

  @override
  bool shouldRepaint(SplashBackgroundPainter oldDelegate) {
    return shape != oldDelegate.shape;
  }
}
