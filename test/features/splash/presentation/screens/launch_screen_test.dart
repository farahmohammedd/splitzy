import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/assets/app_images.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/core/widgets/brand_background.dart';
import 'package:splitzy/features/splash/presentation/screens/launch_screen.dart';

const _duration = LaunchScreen.defaultMinimumDuration;

final _logo = find.byWidgetPredicate(
  (widget) => switch (widget) {
    Image(
      image: ResizeImage(
        imageProvider: AssetImage(assetName: AppImages.splitzyIcon),
      ),
    ) =>
      true,
    _ => false,
  },
);

Future<void> _pumpLaunch(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  VoidCallback? onLoaded,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: LaunchScreen(onLoaded: onLoaded),
    ),
  );
}

double _opacityAbove(WidgetTester tester, Finder target) {
  final fade = find.ancestor(of: target, matching: find.byType(FadeTransition));
  return tester.widget<FadeTransition>(fade.first).opacity.value;
}

double? _progressValue(WidgetTester tester) {
  return tester
      .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
      .value;
}

void main() {
  group('LaunchScreen', () {
    testWidgets('renders the branding on the brand background', (tester) async {
      await _pumpLaunch(tester);
      await tester.pump(_duration);

      expect(find.byType(BrandBackground), findsOneWidget);
      expect(_logo, findsOneWidget);
      expect(find.text('Splitzy'), findsOneWidget);
      expect(find.text('Split Together, Stay Closer'), findsOneWidget);
    });

    testWidgets('shows a loading bar and label', (tester) async {
      await _pumpLaunch(tester);

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);
      expect(find.bySemanticsLabel('Loading'), findsOneWidget);
    });

    testWidgets('fills the loading bar over the minimum duration', (
      tester,
    ) async {
      await _pumpLaunch(tester);
      expect(_progressValue(tester), 0);

      await tester.pump(_duration ~/ 2);
      expect(_progressValue(tester), inExclusiveRange(0, 1));

      await tester.pump(_duration ~/ 2);
      expect(_progressValue(tester), 1);
    });

    testWidgets('calls onLoaded once, only after the minimum duration', (
      tester,
    ) async {
      var loadedCount = 0;
      await _pumpLaunch(tester, onLoaded: () => loadedCount++);

      await tester.pump(_duration - const Duration(milliseconds: 1));
      expect(loadedCount, 0);

      // An animation completes on the first frame *past* its duration.
      await tester.pump(const Duration(milliseconds: 2));
      expect(loadedCount, 1);

      await tester.pump(_duration);
      expect(loadedCount, 1);
    });

    testWidgets('fades in the logo, then the wordmark', (tester) async {
      await _pumpLaunch(tester);

      expect(_opacityAbove(tester, _logo), 0);
      expect(_opacityAbove(tester, find.text('Splitzy')), 0);

      await tester.pump(_duration * 0.3);
      expect(_opacityAbove(tester, _logo), 1);
      expect(_opacityAbove(tester, find.text('Splitzy')), lessThan(1));

      await tester.pump(_duration * 0.15);
      expect(_opacityAbove(tester, find.text('Splitzy')), 1);
    });

    testWidgets('shows content immediately when animations are disabled', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      await _pumpLaunch(tester);

      expect(_opacityAbove(tester, _logo), 1);
      expect(_opacityAbove(tester, find.text('Splitzy')), 1);

      // Progress still advances at normal speed: it conveys state, not
      // decoration, and the minimum loading time must hold.
      await tester.pump(_duration ~/ 2);
      expect(_progressValue(tester), inExclusiveRange(0, 1));
    });

    testWidgets('keeps the minimum duration when animations are disabled', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );
      var loadedCount = 0;

      await _pumpLaunch(tester, onLoaded: () => loadedCount++);
      await tester.pump(_duration - const Duration(milliseconds: 1));
      expect(loadedCount, 0);

      await tester.pump(const Duration(milliseconds: 2));
      expect(loadedCount, 1);
    });

    group('lays out without overflow', () {
      const sizes = {
        'small phone': Size(320, 568),
        'phone': Size(390, 844),
        'tablet landscape': Size(1024, 768),
      };

      for (final MapEntry(key: name, value: size) in sizes.entries) {
        testWidgets(
          'on a $name (${size.width.toInt()}x${size.height.toInt()})',
          (tester) async {
            await _pumpLaunch(tester, size: size);
            await tester.pump(_duration);

            expect(tester.takeException(), isNull);
            expect(_logo, findsOneWidget);
            expect(find.text('Loading...'), findsOneWidget);
          },
        );
      }

      testWidgets('on a small phone with 2x text scaling', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await _pumpLaunch(tester, size: const Size(320, 568));
        await tester.pump(_duration);

        expect(tester.takeException(), isNull);
      });
    });
  });
}
