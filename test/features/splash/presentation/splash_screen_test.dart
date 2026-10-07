import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/assets/app_images.dart';
import 'package:splitzy/core/theme/app_colors.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/splash/presentation/splash_screen.dart';
import 'package:splitzy/features/splash/presentation/widgets/splash_background.dart';

const _duration = SplashScreen.entranceDuration;

Finder _assetImage(String assetName) {
  return find.byWidgetPredicate(
    (widget) =>
        widget is Image &&
        switch (widget.image) {
          ResizeImage(imageProvider: AssetImage(assetName: final name)) =>
            name == assetName,
          _ => false,
        },
  );
}

final _logo = _assetImage(AppImages.splitzyIcon);
final _friends = _assetImage(AppImages.splashFriends);
final _title = find.text('Split Expenses\nBuild Stronger Bonds');
final _getStarted = find.text('Get Started');

Future<void> _pumpSplash(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  VoidCallback? onGetStarted,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: SplashScreen(onGetStarted: onGetStarted ?? () {}),
    ),
  );
}

double _opacityAbove(WidgetTester tester, Finder target) {
  final fade = find.ancestor(of: target, matching: find.byType(FadeTransition));
  return tester.widget<FadeTransition>(fade.first).opacity.value;
}

void _disableAnimations(WidgetTester tester) {
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      const FakeAccessibilityFeatures(disableAnimations: true);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
}

void main() {
  group('SplashScreen', () {
    testWidgets('renders the header, illustration, copy and button', (
      tester,
    ) async {
      await _pumpSplash(tester);
      await tester.pump(_duration);

      expect(find.byType(SplashBackground), findsOneWidget);
      expect(_logo, findsOneWidget);
      expect(find.text('Splitzy'), findsOneWidget);
      expect(find.text('Split Together, Stay Closer'), findsOneWidget);
      expect(_friends, findsOneWidget);
      expect(_title, findsOneWidget);
      expect(
        find.text('A simple way to share expenses\nwith friends and family.'),
        findsOneWidget,
      );
      expect(_getStarted, findsOneWidget);
    });

    testWidgets('uses the deep emerald for the Get Started button', (
      tester,
    ) async {
      await _pumpSplash(tester);
      await tester.pump(_duration);

      // The rendered fill, which comes from the theme.
      final fill = tester.widget<Material>(
        find
            .descendant(
              of: find.byType(FilledButton),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(fill.color, AppColors.primaryDark);
    });

    testWidgets('calls onGetStarted when Get Started is tapped', (
      tester,
    ) async {
      var taps = 0;
      await _pumpSplash(tester, onGetStarted: () => taps++);
      await tester.pump(_duration);

      await tester.tap(_getStarted);
      expect(taps, 1);
    });

    testWidgets('staggers the entrance: header, illustration, copy, button', (
      tester,
    ) async {
      await _pumpSplash(tester);

      for (final target in [_logo, _friends, _title, _getStarted]) {
        expect(_opacityAbove(tester, target), 0);
      }

      // 30% in: the header is well under way, the copy has not started.
      await tester.pump(_duration * 0.3);
      expect(_opacityAbove(tester, _logo), greaterThan(0));
      expect(_opacityAbove(tester, _title), 0);
      expect(_opacityAbove(tester, _getStarted), 0);

      // 70% in: header and illustration are done, the button is starting.
      await tester.pump(_duration * 0.4);
      expect(_opacityAbove(tester, _logo), 1);
      expect(_opacityAbove(tester, _friends), 1);
      expect(_opacityAbove(tester, _getStarted), lessThan(1));

      await tester.pump(_duration * 0.3);
      for (final target in [_logo, _friends, _title, _getStarted]) {
        expect(_opacityAbove(tester, target), 1);
      }
    });

    testWidgets('shows everything immediately when animations are disabled', (
      tester,
    ) async {
      _disableAnimations(tester);
      var taps = 0;
      await _pumpSplash(tester, onGetStarted: () => taps++);

      for (final target in [_logo, _friends, _title, _getStarted]) {
        expect(_opacityAbove(tester, target), 1);
      }

      await tester.tap(_getStarted);
      expect(taps, 1);
    });

    group('lays out without overflow and keeps Get Started reachable', () {
      const sizes = {
        'small phone': Size(320, 568),
        'phone': Size(390, 844),
        'tablet landscape': Size(1024, 768),
      };

      Future<void> expectReachable(WidgetTester tester) async {
        var taps = 0;
        await _pumpSplash(
          tester,
          size: tester.view.physicalSize,
          onGetStarted: () => taps++,
        );
        await tester.pump(_duration);

        expect(tester.takeException(), isNull);
        await tester.ensureVisible(_getStarted);
        await tester.tap(_getStarted);
        expect(taps, 1);
      }

      for (final MapEntry(key: name, value: size) in sizes.entries) {
        testWidgets(
          'on a $name (${size.width.toInt()}x${size.height.toInt()})',
          (tester) async {
            tester.view.physicalSize = size;
            await expectReachable(tester);
          },
        );
      }

      testWidgets('on a small phone with 2x text scaling', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        tester.view.physicalSize = const Size(320, 568);

        await expectReachable(tester);
      });
    });
  });

  group('SplashBackgroundPainter', () {
    testWidgets('paints with the theme sage color', (tester) async {
      await _pumpSplash(tester);

      final painter = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((paint) => paint.painter)
          .whereType<SplashBackgroundPainter>()
          .single;
      expect(
        painter.shape,
        AppColors.secondary.withValues(alpha: SplashBackground.shapeOpacity),
      );
    });
  });
}
