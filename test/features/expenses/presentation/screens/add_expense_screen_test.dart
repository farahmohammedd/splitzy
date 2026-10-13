import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';

final _trip = Group(
  id: 'trip',
  ownerId: 'you',
  name: 'Trip to Dahab',
  members: const [
    Member(id: 'you', name: 'Farah'),
    Member(id: 'sara', name: 'Sara'),
    Member(id: 'mona', name: 'Mona'),
  ],
  createdAt: DateTime(2026, 10, 12),
);

final _flat = Group(
  id: 'flat',
  ownerId: 'you',
  name: 'Apartment',
  members: const [
    Member(id: 'you', name: 'Farah'),
    Member(id: 'omar', name: 'Omar'),
  ],
  createdAt: DateTime(2026, 10, 1),
);

final _description = find.widgetWithText(TextFormField, 'e.g. Dinner');
final _amount = find.widgetWithText(TextFormField, '0.00');
final _save = find.widgetWithText(FilledButton, 'Save Expense');
Finder _share(String memberId) => find.byKey(ValueKey('share-$memberId'));

/// Records which callbacks the screen invoked.
class _Calls {
  int back = 0;
  int newGroup = 0;
  final saves = <ExpenseInput>[];
}

Future<_Calls> _pumpScreen(
  WidgetTester tester, {
  List<Group>? groups,
  bool loading = false,
  String? initialGroupId,
  String? groupsErrorMessage,
  bool isSubmitting = false,
  String? errorMessage,
}) async {
  final calls = _Calls();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: AddExpenseScreen(
        groups: loading ? null : (groups ?? [_trip, _flat]),
        groupsErrorMessage: groupsErrorMessage,
        ownerId: 'you',
        initialGroupId: initialGroupId,
        onBack: () => calls.back++,
        onNewGroup: () => calls.newGroup++,
        onSave: calls.saves.add,
        isSubmitting: isSubmitting,
        errorMessage: errorMessage,
      ),
    ),
  );
  return calls;
}

Future<void> _tapSave(WidgetTester tester) async {
  await tester.ensureVisible(_save);
  await tester.tap(_save);
  await tester.pump();
}

Future<void> _chooseCustom(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Custom'));
  await tester.tap(find.text('Custom'));
  await tester.pump();
}

Future<void> _enterShare(WidgetTester tester, String memberId, String text) {
  return tester.enterText(_share(memberId), text);
}

void main() {
  group('AddExpenseScreen', () {
    testWidgets('starts on the newest group, paid by you, split equally', (
      tester,
    ) async {
      await _pumpScreen(tester);

      expect(find.text('Trip to Dahab'), findsOneWidget);
      final you = tester.widget<ChoiceChip>(
        find.widgetWithText(ChoiceChip, 'You'),
      );
      expect(you.selected, isTrue);
      expect(
        tester
            .widget<SegmentedButton<SplitType>>(
              find.byType(SegmentedButton<SplitType>),
            )
            .selected,
        {SplitType.equal},
      );
    });

    testWidgets('starts on the initial group when given', (tester) async {
      await _pumpScreen(tester, initialGroupId: 'flat');

      expect(find.text('Apartment'), findsOneWidget);
      expect(find.text('Omar'), findsWidgets);
    });

    testWidgets('shows the equal shares as the amount is typed, the '
        'leftover piastre going to the first member', (tester) async {
      await _pumpScreen(tester);
      expect(find.text('—'), findsNWidgets(3));

      await tester.enterText(_amount, '100');
      await tester.pump();

      expect(find.text('EGP 33.34'), findsOneWidget);
      expect(find.text('EGP 33.33'), findsNWidgets(2));
    });

    testWidgets('saves an equal split with the chosen payer', (tester) async {
      final calls = await _pumpScreen(tester);
      await tester.enterText(_description, '  Dinner ');
      await tester.enterText(_amount, '600');
      await tester.tap(find.widgetWithText(ChoiceChip, 'Sara'));
      await tester.pump();

      await _tapSave(tester);

      final saved = calls.saves.single;
      expect(saved.group, _trip);
      expect(saved.description, 'Dinner');
      expect(saved.amount, 60000);
      expect(saved.paidBy, 'sara');
      expect(saved.splitType, SplitType.equal);
    });

    testWidgets('saves custom shares, an empty field counting as zero', (
      tester,
    ) async {
      final calls = await _pumpScreen(tester);
      await tester.enterText(_description, 'Dinner');
      await tester.enterText(_amount, '600');
      await _chooseCustom(tester);
      await _enterShare(tester, 'you', '400.50');
      await _enterShare(tester, 'sara', '199.50');
      await tester.pump();

      expect(find.text('Total: EGP 600 of EGP 600'), findsOneWidget);
      await _tapSave(tester);

      final saved = calls.saves.single;
      expect(saved.splitType, SplitType.custom);
      expect(saved.customShares, {'you': 40050, 'sara': 19950, 'mona': 0});
    });

    testWidgets('rejects custom shares that do not add up', (tester) async {
      final calls = await _pumpScreen(tester);
      await tester.enterText(_description, 'Dinner');
      await tester.enterText(_amount, '600');
      await _chooseCustom(tester);
      await _enterShare(tester, 'you', '300');
      await _enterShare(tester, 'sara', '250');
      await tester.pump();

      expect(find.text('Total: EGP 550 of EGP 600'), findsOneWidget);
      await _tapSave(tester);

      expect(find.text('Shares must add up to the amount.'), findsOneWidget);
      expect(calls.saves, isEmpty);
    });

    testWidgets('rejects an unreadable custom share', (tester) async {
      final calls = await _pumpScreen(tester);
      await tester.enterText(_description, 'Dinner');
      await tester.enterText(_amount, '600');
      await _chooseCustom(tester);
      await _enterShare(tester, 'you', '600.505');

      await _tapSave(tester);

      expect(find.text('Enter an amount like 150 or 150.50.'), findsOneWidget);
      expect(calls.saves, isEmpty);
    });

    testWidgets('requires a description and a valid amount', (tester) async {
      final calls = await _pumpScreen(tester);

      await _tapSave(tester);
      expect(find.text('Enter what it was for.'), findsOneWidget);
      expect(find.text('Enter an amount.'), findsOneWidget);

      await tester.enterText(_amount, '1000000.01');
      await tester.pump();
      expect(
        find.text("Amount can't be more than EGP 1,000,000."),
        findsOneWidget,
      );
      expect(calls.saves, isEmpty);
    });

    testWidgets('choosing another group shows its members and resets the '
        'payer and custom shares', (tester) async {
      final calls = await _pumpScreen(tester);
      await tester.tap(find.widgetWithText(ChoiceChip, 'Sara'));
      await tester.pump();
      await _chooseCustom(tester);
      await _enterShare(tester, 'you', '10');
      await tester.pump();

      final groupField = find.byType(DropdownButtonFormField<String>);
      await tester.ensureVisible(groupField);
      await tester.pumpAndSettle();
      await tester.tap(groupField);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apartment').last);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(ChoiceChip, 'Omar'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Sara'), findsNothing);
      expect(
        tester
            .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'You'))
            .selected,
        isTrue,
      );
      expect(tester.widget<TextFormField>(_share('you')).controller?.text, '');

      await tester.enterText(_description, 'Rent');
      await tester.enterText(_amount, '100');
      await _enterShare(tester, 'you', '50');
      await _enterShare(tester, 'omar', '50');
      await _tapSave(tester);

      final saved = calls.saves.single;
      expect(saved.group, _flat);
      expect(saved.paidBy, 'you');
      expect(saved.customShares, {'you': 5000, 'omar': 5000});
    });

    testWidgets('while saving, shows progress and ignores submits', (
      tester,
    ) async {
      final calls = await _pumpScreen(tester, isSubmitting: true);
      await tester.enterText(_description, 'Dinner');
      await tester.enterText(_amount, '600');

      await tester.ensureVisible(_save);
      await tester.tap(_save, warnIfMissed: false);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(calls.saves, isEmpty);
    });

    testWidgets('shows a failed save above the button', (tester) async {
      await _pumpScreen(tester, errorMessage: 'No internet connection.');

      expect(find.text('No internet connection.'), findsOneWidget);
    });

    testWidgets('shows loading while the groups are unknown', (tester) async {
      await _pumpScreen(tester, loading: true);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(_save, findsNothing);
    });

    testWidgets('shows a failed load of the groups', (tester) async {
      await _pumpScreen(tester, groupsErrorMessage: 'Something went wrong.');

      expect(find.text('Something went wrong.'), findsOneWidget);
      expect(_save, findsNothing);
    });

    testWidgets('without groups, asks for one and reports New Group', (
      tester,
    ) async {
      final calls = await _pumpScreen(tester, groups: const []);

      expect(find.text('Create a group first'), findsOneWidget);
      expect(_save, findsNothing);

      await tester.tap(find.text('New Group'));

      expect(calls.newGroup, 1);
    });

    testWidgets('reports Back', (tester) async {
      final calls = await _pumpScreen(tester);

      await tester.tap(find.byTooltip('Back'));

      expect(calls.back, 1);
    });

    for (final (name, size, textScale) in [
      ('a small phone', const Size(320, 568), 1.0),
      ('a phone', const Size(390, 844), 1.0),
      ('a tablet landscape', const Size(1024, 768), 1.0),
      ('a small phone with 2x text scaling', const Size(320, 568), 2.0),
    ]) {
      testWidgets('lays out without overflow and keeps Save reachable on '
          '$name', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final calls = await _pumpScreen(tester);
        await tester.enterText(_description, 'Dinner');
        await tester.enterText(_amount, '600');
        await _chooseCustom(tester);
        for (final id in ['you', 'sara', 'mona']) {
          await tester.ensureVisible(_share(id));
          await _enterShare(tester, id, '200');
        }
        await _tapSave(tester);

        expect(tester.takeException(), isNull);
        expect(calls.saves, hasLength(1));
      });
    }
  });
}
