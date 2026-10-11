import 'package:flutter/material.dart';

/// The backdrop behind the login screen: a sage lobe in the top-right corner
/// and pale sage lobes in both bottom corners.
///
/// Decorations are drawn edge to edge (behind system bars); keep [child]
/// inside a [SafeArea]. They are excluded from semantics and hit testing.
class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key, required this.child});

  /// Opacity of the pale bottom-corner lobes.
  static const double paleShapeOpacity = 0.75;

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
              painter: LoginBackgroundPainter(
                softShape: scheme.secondaryContainer,
                paleShape: scheme.secondaryContainer.withValues(
                  alpha: paleShapeOpacity,
                ),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

/// Paints the shapes of [LoginBackground].
@visibleForTesting
class LoginBackgroundPainter extends CustomPainter {
  const LoginBackgroundPainter({
    required this.softShape,
    required this.paleShape,
  });

  final Color softShape;
  final Color paleShape;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final palePaint = Paint()..color = paleShape;

    // Top-right lobe.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.68, 0)
        ..cubicTo(w * 0.66, h * 0.08, w * 0.8, h * 0.12, w * 0.9, h * 0.14)
        ..cubicTo(w * 0.95, h * 0.15, w * 0.98, h * 0.17, w, h * 0.19)
        ..lineTo(w, 0)
        ..close(),
      Paint()..color = softShape,
    );

    // Bottom-left lobe.
    canvas.drawPath(
      Path()
        ..moveTo(0, h * 0.89)
        ..cubicTo(w * 0.1, h * 0.9, w * 0.2, h * 0.95, w * 0.26, h)
        ..lineTo(0, h)
        ..close(),
      palePaint,
    );

    // Bottom-right lobe.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.66, h)
        ..cubicTo(w * 0.72, h * 0.93, w * 0.84, h * 0.89, w, h * 0.87)
        ..lineTo(w, h)
        ..close(),
      palePaint,
    );
  }

  @override
  bool shouldRepaint(LoginBackgroundPainter oldDelegate) {
    return softShape != oldDelegate.softShape ||
        paleShape != oldDelegate.paleShape;
  }
}
