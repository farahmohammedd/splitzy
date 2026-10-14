import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/domain/money/equal_split.dart';
import 'package:splitzy/features/expenses/presentation/screens/group_details_screen.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';

const _memberIds = ['you', 'sara', 'mona', 'omar'];

final _trip = Group(
  id: 'trip',
  ownerId: 'you',
  name: 'Trip to Dahab',
  members: const [
    Member(id: 'you', name: 'Farah'),
    Member(id: 'sara', name: 'Sara'),
    Member(id: 'mona', name: 'Mona'),
    Member(id: 'omar', name: 'Omar'),
  ],
  createdAt: DateTime(2026, 10, 1),
);

Expense _expense(String description, int amount, String paidBy, int day) {
  return Expense(
    id: description,
    groupId: 'trip',
    description: description,
    amount: amount,
    currency: Expense.egp,
    paidBy: paidBy,
    splitType: SplitType.equal,
    shares: splitEqually(amount, _memberIds),
    createdAt: DateTime(2026, 10, day),
  );
}

/// The design reference's example, newest first.
final _expenses = [
  _expense('Transport', 32000, 'omar', 11),
  _expense('Dinner', 48000, 'sara', 10),
  _expense('Hotel', 160000, 'you', 9),
];

/// Records which callbacks the screen invoked.
class _Calls {
  int back = 0;
  int addExpense = 0;
}

Future<_Calls> _pumpScreen(
  WidgetTester tester, {
  List<Expense>? expenses,
  bool loading = false,
  String? errorMessage,
}) async {
  final calls = _Calls();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: GroupDetailsScreen(
        group: _trip,
        ownerId: 'you',
        expenses: loading ? null : (expenses ?? _expenses),
        expensesErrorMessage: errorMessage,
        onBack: () => calls.back++,
        onAddExpense: () => calls.addExpense++,
      ),
    ),
  );
  return calls;
}

void main() {
  group('GroupDetailsScreen', () {
    testWidgets('shows the group name and member count', (tester) async {
      await _pumpScreen(tester);

      expect(find.text('Trip to Dahab'), findsOneWidget);
      expect(find.text('4 members'), findsOneWidget);
    });

    testWidgets("shows the group's total, your share and what you get back", (
      tester,
    ) async {
      await _pumpScreen(tester);

      expect(find.text('Total group expenses'), findsOneWidget);
      expect(find.text('EGP 2,400'), findsOneWidget);
      expect(find.text('Your share'), findsOneWidget);
      expect(find.text('EGP 600'), findsOneWidget);
      expect(find.text('You get back'), findsOneWidget);
      expect(find.text('EGP 1,000'), findsOneWidget);
    });

    testWidgets('shows what you owe when you paid less than your share', (
      tester,
    ) async {
      await _pumpScreen(
        tester,
        expenses: [_expense('Dinner', 40000, 'sara', 10)],
      );

      expect(find.text('You owe'), findsOneWidget);
      expect(find.text('EGP 100'), findsNWidgets(2));
    });

    testWidgets("says you're all settled when your balance is zero", (
      tester,
    ) async {
      await _pumpScreen(tester, expenses: const []);

      expect(find.text("You're all settled"), findsOneWidget);
      expect(find.text('EGP 0'), findsNWidgets(2));
    });

    testWidgets("shows every member's balance, you first", (tester) async {
      await _pumpScreen(tester);

      for (final (name, balance) in [
        ('You', '+ 1,000'),
        ('Sara', '- 120'),
        ('Mona', '- 600'),
        ('Omar', '- 280'),
      ]) {
        expect(find.text(name), findsOneWidget, reason: name);
        expect(find.text(balance), findsOneWidget, reason: name);
      }
      expect(
        tester.getTopLeft(find.text('You')).dx,
        lessThan(tester.getTopLeft(find.text('Sara')).dx),
      );
    });

    testWidgets('lists the expenses newest first, with payer, amount and '
        'date', (tester) async {
      await _pumpScreen(tester);

      expect(find.text('Paid by Omar'), findsOneWidget);
      expect(find.text('Paid by Sara'), findsOneWidget);
      expect(find.text('Paid by you'), findsOneWidget);
      expect(find.text('EGP 1,600'), findsOneWidget);
      expect(find.text('Oct 9'), findsOneWidget);
      final transport = tester.getTopLeft(find.text('Transport')).dy;
      final hotel = tester.getTopLeft(find.text('Hotel')).dy;
      expect(transport, lessThan(hotel));
      expect(find.text('View all'), findsNothing);
    });

    testWidgets("keeps each expense's amount at the end of its row", (
      tester,
    ) async {
      // Wide enough that the amount is narrower than the room it may take
      // (the test font is wider than real fonts).
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _pumpScreen(tester);

      final amount = tester.getTopRight(find.text('EGP 1,600'));
      final date = tester.getTopRight(find.text('Oct 9'));
      final row = tester.getTopRight(
        find.ancestor(of: find.text('Hotel'), matching: find.byType(Row)).first,
      );

      // Both end where the row's content ends, not halfway across it.
      expect(amount.dx, moreOrLessEquals(row.dx, epsilon: 1));
      expect(date.dx, moreOrLessEquals(row.dx, epsilon: 1));
    });

    testWidgets('says when there are no expenses yet', (tester) async {
      await _pumpScreen(tester, expenses: const []);

      expect(find.text('No expenses yet'), findsOneWidget);
      expect(find.text('0'), findsNWidgets(4));
    });

    testWidgets('shows loading, with no amounts, while expenses are unknown', (
      tester,
    ) async {
      await _pumpScreen(tester, loading: true);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('EGP'), findsNothing);
      expect(find.text('Add Expense'), findsOneWidget);
    });

    testWidgets('shows a failed load, with no amounts', (tester) async {
      await _pumpScreen(tester, errorMessage: 'No internet connection.');

      expect(find.text('No internet connection.'), findsOneWidget);
      expect(find.textContaining('EGP'), findsNothing);
    });

    testWidgets('reports Back and Add Expense', (tester) async {
      final calls = await _pumpScreen(tester);

      await tester.tap(find.byTooltip('Back'));
      await tester.tap(find.text('Add Expense'));

      expect(calls.back, 1);
      expect(calls.addExpense, 1);
    });

    for (final (name, size, textScale) in [
      ('a small phone', const Size(320, 568), 1.0),
      ('a phone', const Size(390, 844), 1.0),
      ('a tablet landscape', const Size(1024, 768), 1.0),
      ('a small phone with 2x text scaling', const Size(320, 568), 2.0),
    ]) {
      testWidgets('lays out without overflow and keeps the last expense and '
          'Add Expense reachable on $name', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final calls = await _pumpScreen(tester);
        await tester.ensureVisible(find.text('Hotel'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Add Expense'));

        expect(tester.takeException(), isNull);
        expect(find.text('Hotel').hitTestable(), findsOneWidget);
        expect(calls.addExpense, 1);
      });
    }
  });
}
