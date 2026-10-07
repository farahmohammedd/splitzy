import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/app.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';
import 'package:splitzy/core/theme/app_colors.dart';
import 'package:splitzy/features/auth/presentation/login_screen.dart';
import 'package:splitzy/features/splash/presentation/launch_screen.dart';
import 'package:splitzy/features/splash/presentation/splash_screen.dart';

void main() {
  group('SplitzyApp', () {
    Future<void> pumpApp(WidgetTester tester) {
      return tester.pumpWidget(const ProviderScope(child: SplitzyApp()));
    }

    testWidgets('builds inside a ProviderScope', (tester) async {
      await pumpApp(tester);

      expect(find.byType(SplitzyApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('configures the app title and hides the debug banner', (
      tester,
    ) async {
      await pumpApp(tester);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(app.title, 'Splitzy');
      expect(app.debugShowCheckedModeBanner, isFalse);
    });

    testWidgets('applies the Splitzy theme to descendants', (tester) async {
      await pumpApp(tester);

      final context = tester.element(find.byType(Scaffold));
      final theme = Theme.of(context);
      expect(theme.colorScheme.primary, AppColors.primary);
      expect(theme.scaffoldBackgroundColor, AppColors.background);
      expect(context.brandColors.moneyAccent, AppColors.moneyAccent);
    });
  });

  group('Temporary navigation flow', () {
    Future<void> pumpApp(WidgetTester tester) {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      return tester.pumpWidget(const ProviderScope(child: SplitzyApp()));
    }

    testWidgets('starts on the launch screen', (tester) async {
      await pumpApp(tester);

      expect(find.byType(LaunchScreen), findsOneWidget);
      expect(find.byType(SplashScreen), findsNothing);
    });

    testWidgets('replaces Launch with Splash after the minimum duration', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.pump(LaunchScreen.defaultMinimumDuration);
      await tester.pumpAndSettle();

      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(LaunchScreen), findsNothing);
    });

    testWidgets('Get Started opens Login, and back returns to Splash', (
      tester,
    ) async {
      await pumpApp(tester);
      await tester.pump(LaunchScreen.defaultMinimumDuration);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();
      expect(find.byType(LoginScreen), findsOneWidget);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(LaunchScreen), findsNothing);
    });
  });
}
