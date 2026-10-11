import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/app.dart';
import 'package:splitzy/core/router/app_router.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';
import 'package:splitzy/core/theme/app_colors.dart';
import 'package:splitzy/injection_container.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_error_reporter.dart';

void main() {
  group('SplitzyApp', () {
    Future<void> pumpApp(WidgetTester tester) {
      final repository = FakeAuthRepository();
      addTearDown(repository.dispose);
      return tester.pumpWidget(
        ProviderScope(
          overrides: InjectionContainer(
            authRepository: repository,
            errorReporter: FakeErrorReporter(),
          ).overrides,
          child: const SplitzyApp(),
        ),
      );
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

    testWidgets('routes with the app router', (tester) async {
      await pumpApp(tester);

      final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
      final container = ProviderScope.containerOf(
        tester.element(find.byType(SplitzyApp)),
      );
      expect(app.routerConfig, same(container.read(appRouterProvider)));
    });
  });

  // Navigation flow tests live in test/core/router/app_router_test.dart.
}
