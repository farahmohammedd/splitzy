import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/home/presentation/screens/home_screen.dart';
import 'package:splitzy/features/home/presentation/widgets/balance_card.dart';

/// Records which callbacks the screen invoked.
class _Calls {
  int addExpense = 0;
  int newGroup = 0;
}

Future<_Calls> _pumpHome(WidgetTester tester, {String name = 'Sam Lee'}) async {
  final calls = _Calls();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: HomeScreen(
        name: name,
        onAddExpense: () => calls.addExpense++,
        onNewGroup: () => calls.newGroup++,
      ),
    ),
  );
  return calls;
}

void main() {
  group('HomeScreen', () {
    testWidgets('greets the user by name, with their initial', (tester) async {
      await _pumpHome(tester);

      expect(find.text('Hello 👋'), findsOneWidget);
      expect(find.text('Sam Lee'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
    });

    testWidgets('capitalizes the initial', (tester) async {
      await _pumpHome(tester, name: 'sam');

      expect(find.text('S'), findsOneWidget);
    });

    testWidgets('shows a placeholder initial when the name is empty', (
      tester,
    ) async {
      await _pumpHome(tester, name: '');

      expect(find.text('?'), findsOneWidget);
    });

    testWidgets('shows the empty balance card, with no amounts', (
      tester,
    ) async {
      await _pumpHome(tester);

      expect(find.text('Total balance'), findsOneWidget);
      expect(find.text('No expenses yet'), findsOneWidget);
      expect(find.text('Add an expense to see who owes whom.'), findsOneWidget);
      expect(find.textContaining('EGP'), findsNothing);
      expect(find.text('You are owed'), findsNothing);
      expect(find.text('You owe'), findsNothing);
    });

    testWidgets('shows empty Groups and Activity sections without See all', (
      tester,
    ) async {
      await _pumpHome(tester);

      expect(find.text('Your Groups'), findsOneWidget);
      expect(find.text('No groups yet'), findsOneWidget);
      expect(find.text('Recent Activity'), findsOneWidget);
      expect(find.text('No activity yet'), findsOneWidget);
      expect(find.text('See all'), findsNothing);
      expect(find.text('View all'), findsNothing);
    });

    group('balance card', () {
      Future<void> pumpBalance(
        WidgetTester tester, {
        HomeBalance? balance,
        bool loading = false,
        bool failed = false,
      }) {
        return tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.light,
            home: HomeScreen(
              name: 'Sam',
              onAddExpense: () {},
              onNewGroup: () {},
              balance: balance,
              balanceLoading: loading,
              balanceFailed: failed,
            ),
          ),
        );
      }

      testWidgets('shows what you are owed, what you owe and the total', (
        tester,
      ) async {
        await pumpBalance(tester, balance: (owed: 50500, owe: 15000));

        expect(find.text('Total balance'), findsOneWidget);
        expect(find.text('+ EGP 355'), findsOneWidget);
        expect(
          find.text("You're all good — friends owe you more 🎉"),
          findsOneWidget,
        );
        expect(find.text('You are owed'), findsOneWidget);
        expect(find.text('EGP 505'), findsOneWidget);
        expect(find.text('You owe'), findsOneWidget);
        expect(find.text('EGP 150'), findsOneWidget);
        expect(find.text('No expenses yet'), findsNothing);
      });

      testWidgets('shows a negative total when you owe more', (tester) async {
        await pumpBalance(tester, balance: (owed: 2000, owe: 17000));

        expect(find.text('- EGP 150'), findsOneWidget);
        expect(
          find.text("You owe a bit more than you're owed."),
          findsOneWidget,
        );
      });

      testWidgets('says you are all settled at zero', (tester) async {
        await pumpBalance(tester, balance: (owed: 0, owe: 0));

        expect(find.text('EGP 0'), findsNWidgets(3));
        expect(find.text("You're all settled."), findsOneWidget);
      });

      testWidgets('shows progress, with no amounts, while loading', (
        tester,
      ) async {
        await pumpBalance(tester, loading: true);

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.textContaining('EGP'), findsNothing);
        expect(find.text('No expenses yet'), findsNothing);
      });

      testWidgets('says when the balance could not be loaded', (tester) async {
        await pumpBalance(tester, failed: true);

        expect(find.text("Couldn't load your balance."), findsOneWidget);
        expect(find.textContaining('EGP'), findsNothing);
      });

      testWidgets('fits a small phone with 2x text scaling', (tester) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await pumpBalance(tester, balance: (owed: 12345678, owe: 9876543));

        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('shows the groups content in place of the empty state, with '
        'See all', (tester) async {
      var seeAll = 0;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: HomeScreen(
            name: 'Sam',
            onAddExpense: () {},
            onNewGroup: () {},
            groups: const Text('The groups'),
            onSeeAllGroups: () => seeAll++,
          ),
        ),
      );

      expect(find.text('The groups'), findsOneWidget);
      expect(find.text('No groups yet'), findsNothing);
      // Recent Activity keeps its empty state.
      expect(find.text('No activity yet'), findsOneWidget);

      await tester.tap(find.text('See all'));

      expect(seeAll, 1);
    });

    testWidgets('reports the quick actions', (tester) async {
      final calls = await _pumpHome(tester);

      await tester.tap(find.text('Add Expense'));
      await tester.tap(find.text('New Group'));

      expect(calls.addExpense, 1);
      expect(calls.newGroup, 1);
    });

    for (final (name, size, textScale) in [
      ('a small phone', const Size(320, 568), 1.0),
      ('a phone', const Size(390, 844), 1.0),
      ('a tablet landscape', const Size(1024, 768), 1.0),
      ('a small phone with 2x text scaling', const Size(320, 568), 2.0),
    ]) {
      testWidgets('lays out without overflow and keeps every section '
          'reachable on $name', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final calls = await _pumpHome(tester);
        await tester.ensureVisible(find.text('New Group'));
        await tester.tap(find.text('New Group'));
        await tester.ensureVisible(find.text('No activity yet'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(calls.newGroup, 1);
        expect(find.text('No activity yet').hitTestable(), findsOneWidget);
      });
    }
  });
}
