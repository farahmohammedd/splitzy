import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/groups/presentation/widgets/group_balance_text.dart';

Future<void> _pump(WidgetTester tester, GroupBalance? balance) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: GroupBalanceText(balance: balance)),
    ),
  );
}

Color? _colorOf(WidgetTester tester, String text) =>
    tester.widget<Text>(find.text(text)).style?.color;

void main() {
  group('GroupBalanceText', () {
    testWidgets('shows what you get back in green', (tester) async {
      await _pump(tester, (amount: 42000, hasExpenses: true));

      expect(find.text('You get EGP 420'), findsOneWidget);
      expect(_colorOf(tester, 'You get EGP 420'), AppBrandColors.light.success);
    });

    testWidgets('shows what you owe in red', (tester) async {
      await _pump(tester, (amount: -15050, hasExpenses: true));

      expect(find.text('You owe EGP 150.50'), findsOneWidget);
      expect(
        _colorOf(tester, 'You owe EGP 150.50'),
        AppTheme.light.colorScheme.error,
      );
    });

    testWidgets('says settled at zero with expenses', (tester) async {
      await _pump(tester, (amount: 0, hasExpenses: true));

      expect(find.text('Settled'), findsOneWidget);
    });

    testWidgets('says when the group has no expenses yet', (tester) async {
      await _pump(tester, (amount: 0, hasExpenses: false));

      expect(find.text('No expenses yet'), findsOneWidget);
    });

    testWidgets('shows nothing while the balance is unknown', (tester) async {
      await _pump(tester, null);

      expect(find.byType(Text), findsNothing);
    });
  });
}
