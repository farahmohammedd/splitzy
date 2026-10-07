import 'package:flutter/material.dart';

import '../theme/app_brand_colors.dart';

/// The branded backdrop used behind the launch screen: a soft sage shape in
/// the top-right corner, layered sage waves along the bottom and thin
/// dark-emerald accent lines.
///
/// Shapes are positioned as fractions of the available size so the treatment
/// scales with the screen. Decorations are drawn edge to edge (behind system
/// bars); keep [child] inside a [SafeArea]. All decorations are excluded from
/// semantics and hit testing.
class BrandBackground extends StatelessWidget {
  const BrandBackground({super.key, required this.child});

  /// Opacity of the faint sage shapes (top-right corner, bottom-left wave).
  static const double faintShapeOpacity = 0.45;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Stack(
      fit: StackFit.expand,
      children: [
        IgnorePointer(
          child: ExcludeSemantics(
            child: CustomPaint(
              painter: BrandBackgroundPainter(
                faintShape: scheme.secondaryContainer.withValues(
                  alpha: faintShapeOpacity,
                ),
                softShape: scheme.secondaryContainer,
                deepShape: scheme.primaryContainer,
                accentLine: context.brandColors.primaryDark,
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Paints the shapes and lines of [BrandBackground].
@visibleForTesting
class BrandBackgroundPainter extends CustomPainter {
  const BrandBackgroundPainter({
    required this.faintShape,
    required this.softShape,
    required this.deepShape,
    required this.accentLine,
  });

  final Color faintShape;
  final Color softShape;
  final Color deepShape;
  final Color accentLine;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final linePaint = Paint()
      ..color = accentLine
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    // Top-right faint sage shape.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.43, 0)
        ..cubicTo(w * 0.47, h * 0.05, w * 0.6, h * 0.1, w * 0.75, h * 0.17)
        ..cubicTo(w * 0.86, h * 0.22, w * 0.93, h * 0.26, w, h * 0.3)
        ..lineTo(w, 0)
        ..close(),
      Paint()..color = faintShape,
    );

    // Top-right accent line.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.65, 0)
        ..cubicTo(w * 0.68, h * 0.07, w * 0.74, h * 0.095, w * 0.82, h * 0.105)
        ..cubicTo(w * 0.9, h * 0.115, w * 0.97, h * 0.13, w, h * 0.17),
      linePaint,
    );

    // Bottom-left faint wave, behind the main wave.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.74)
        ..cubicTo(w * 0.15, h * 0.73, w * 0.35, h * 0.78, w * 0.55, h * 0.86)
        ..lineTo(w * 0.55, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = faintShape,
    );

    // Main sage wave rising towards the right.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.905)
        ..cubicTo(w * 0.25, h * 0.875, w * 0.4, h * 0.86, w * 0.5, h * 0.83)
        ..cubicTo(w * 0.65, h * 0.785, w * 0.8, h * 0.735, w, h * 0.72)
        ..lineTo(w, h)
        ..lineTo(0, h)
        ..close(),
      Paint()..color = softShape,
    );

    // Deeper sage mound in the bottom-right corner.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.74, h)
        ..cubicTo(w * 0.76, h * 0.9, w * 0.86, h * 0.86, w, h * 0.855)
        ..lineTo(w, h)
        ..close(),
      Paint()..color = deepShape,
    );

    // Bottom accent line sweeping down to the right.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.84)
        ..cubicTo(w * 0.2, h * 0.86, w * 0.4, h * 0.915, w * 0.5, h * 0.95)
        ..cubicTo(w * 0.6, h * 0.985, w * 0.7, h, w * 0.8, h * 1.02),
      linePaint,
    );
  }

  @override
  bool shouldRepaint(BrandBackgroundPainter oldDelegate) {
    return faintShape != oldDelegate.faintShape ||
        softShape != oldDelegate.softShape ||
        deepShape != oldDelegate.deepShape ||
        accentLine != oldDelegate.accentLine;
  }
}
