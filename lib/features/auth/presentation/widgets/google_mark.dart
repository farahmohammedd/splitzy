import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_colors.dart';

/// A drawn approximation of the multicolor Google "G" mark.
///
/// Google's sign-in branding guidelines call for the official logo asset;
/// replacing this drawing with it is a separate, not yet scheduled, change.
class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: const _GoogleMarkPainter(),
      ),
    );
  }
}

class _GoogleMarkPainter extends CustomPainter {
  const _GoogleMarkPainter();

  static double _rad(double degrees) => degrees * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.2;
    final center = size.center(Offset.zero);
    final radius = (size.width - stroke) / 2;
    final ring = Rect.fromCircle(center: center, radius: radius);

    Paint arc(Color color) => Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;

    // Angles are clockwise from 3 o'clock; the gap at the upper right is the
    // opening of the "G".
    canvas
      ..drawArc(
        ring,
        _rad(-145),
        _rad(105),
        false,
        arc(ThirdPartyBrandColors.googleRed),
      )
      ..drawArc(
        ring,
        _rad(145),
        _rad(70),
        false,
        arc(ThirdPartyBrandColors.googleYellow),
      )
      ..drawArc(
        ring,
        _rad(45),
        _rad(100),
        false,
        arc(ThirdPartyBrandColors.googleGreen),
      )
      ..drawArc(
        ring,
        _rad(0),
        _rad(45),
        false,
        arc(ThirdPartyBrandColors.googleBlue),
      )
      // Horizontal bar of the "G".
      ..drawRect(
        Rect.fromLTRB(
          center.dx,
          center.dy - stroke / 2,
          center.dx + radius + stroke / 2,
          center.dy + stroke / 2,
        ),
        Paint()..color = ThirdPartyBrandColors.googleBlue,
      );
  }

  @override
  bool shouldRepaint(_GoogleMarkPainter oldDelegate) => false;
}
