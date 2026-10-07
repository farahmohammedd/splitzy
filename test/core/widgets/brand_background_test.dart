import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_colors.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/core/widgets/brand_background.dart';

void main() {
  group('BrandBackground', () {
    Future<void> pumpBackground(WidgetTester tester, Widget child) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(body: BrandBackground(child: child)),
        ),
      );
    }

    BrandBackgroundPainter findPainter(WidgetTester tester) {
      return tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((paint) => paint.painter)
          .whereType<BrandBackgroundPainter>()
          .single;
    }

    testWidgets('renders its child above the decorations', (tester) async {
      await pumpBackground(tester, const Text('content'));

      expect(find.text('content'), findsOneWidget);
      expect(findPainter(tester), isNotNull);
    });

    testWidgets('paints shapes with theme colors', (tester) async {
      await pumpBackground(tester, const SizedBox());

      final painter = findPainter(tester);
      expect(
        painter.faintShape,
        AppColors.secondary.withValues(
          alpha: BrandBackground.faintShapeOpacity,
        ),
      );
      expect(painter.softShape, AppColors.secondary);
      expect(painter.deepShape, AppColors.primaryLight);
      expect(painter.accentLine, AppColors.primaryDark);
    });

    testWidgets('lets taps through to the child', (tester) async {
      var taps = 0;
      await pumpBackground(
        tester,
        Center(
          child: TextButton(onPressed: () => taps++, child: const Text('tap')),
        ),
      );

      await tester.tap(find.text('tap'));
      expect(taps, 1);
    });
  });

  group('BrandBackgroundPainter.shouldRepaint', () {
    const painter = BrandBackgroundPainter(
      faintShape: AppColors.secondary,
      softShape: AppColors.secondary,
      deepShape: AppColors.primaryLight,
      accentLine: AppColors.primaryDark,
    );

    test('is false for identical colors', () {
      expect(
        painter.shouldRepaint(
          const BrandBackgroundPainter(
            faintShape: AppColors.secondary,
            softShape: AppColors.secondary,
            deepShape: AppColors.primaryLight,
            accentLine: AppColors.primaryDark,
          ),
        ),
        isFalse,
      );
    });

    test('is true when a color changes', () {
      expect(
        painter.shouldRepaint(
          const BrandBackgroundPainter(
            faintShape: AppColors.secondary,
            softShape: AppColors.secondary,
            deepShape: AppColors.primaryLight,
            accentLine: AppColors.primary,
          ),
        ),
        isTrue,
      );
    });
  });
}
