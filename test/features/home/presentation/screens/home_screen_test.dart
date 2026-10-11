import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/home/presentation/screens/home_screen.dart';

void main() {
  group('HomeScreen', () {
    Future<void> pumpHome(WidgetTester tester, {VoidCallback? onLogOut}) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: HomeScreen(onLogOut: onLogOut ?? () {}),
        ),
      );
    }

    testWidgets('shows an app bar titled Splitzy', (tester) async {
      await pumpHome(tester);

      expect(
        find.descendant(
          of: find.byType(AppBar),
          matching: find.text('Splitzy'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('reports the Log out action', (tester) async {
      var logOuts = 0;
      await pumpHome(tester, onLogOut: () => logOuts++);

      await tester.tap(find.byTooltip('Log out'));

      expect(logOuts, 1);
    });
  });
}
