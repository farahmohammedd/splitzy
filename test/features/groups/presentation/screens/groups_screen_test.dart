import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';
import 'package:splitzy/features/groups/presentation/screens/groups_screen.dart';

Group _group(String name) => Group(
  id: name,
  ownerId: 'owner',
  name: name,
  members: const [
    Member(id: 'owner', name: 'Farah'),
    Member(id: 'sara', name: 'Sara'),
  ],
  createdAt: DateTime(2026, 10, 12),
);

/// Records which callbacks the screen invoked.
class _Calls {
  int newGroup = 0;
  int retry = 0;
}

Future<_Calls> _pumpScreen(
  WidgetTester tester, {
  List<Group>? groups,
  String? errorMessage,
}) async {
  final calls = _Calls();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: GroupsScreen(
        groups: groups,
        errorMessage: errorMessage,
        onNewGroup: () => calls.newGroup++,
        onRetry: () => calls.retry++,
      ),
    ),
  );
  return calls;
}

void main() {
  group('GroupsScreen', () {
    testWidgets('lists the groups in order with their count', (tester) async {
      await _pumpScreen(
        tester,
        groups: [_group('Trip to Dahab'), _group('Apartment')],
      );

      expect(find.text('Groups'), findsOneWidget);
      expect(find.text('2 groups'), findsOneWidget);
      final trip = tester.getTopLeft(find.text('Trip to Dahab'));
      final apartment = tester.getTopLeft(find.text('Apartment'));
      expect(trip.dy, lessThan(apartment.dy));
    });

    testWidgets('uses the singular for one group', (tester) async {
      await _pumpScreen(tester, groups: [_group('Trip')]);

      expect(find.text('1 group'), findsOneWidget);
    });

    testWidgets('says when there are no groups yet', (tester) async {
      await _pumpScreen(tester, groups: const []);

      expect(find.text('No groups yet'), findsOneWidget);
      expect(
        find.text('Create a group to start splitting expenses.'),
        findsOneWidget,
      );
      expect(find.text('0 groups'), findsOneWidget);
    });

    testWidgets('shows loading, with no count, while groups are unknown', (
      tester,
    ) async {
      await _pumpScreen(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('group'), findsNothing);
    });

    testWidgets('shows a failed load and reports Try again', (tester) async {
      final calls = await _pumpScreen(
        tester,
        groups: [_group('Trip')],
        errorMessage: 'No internet connection.',
      );

      expect(find.text('No internet connection.'), findsOneWidget);
      expect(find.text('Trip'), findsNothing);
      expect(find.text('1 group'), findsNothing);

      await tester.tap(find.text('Try again'));

      expect(calls.retry, 1);
    });

    testWidgets('reports New Group', (tester) async {
      final calls = await _pumpScreen(tester, groups: const []);

      await tester.tap(find.text('New Group'));

      expect(calls.newGroup, 1);
    });

    for (final (name, size, textScale) in [
      ('a small phone', const Size(320, 568), 1.0),
      ('a phone', const Size(390, 844), 1.0),
      ('a tablet landscape', const Size(1024, 768), 1.0),
      ('a small phone with 2x text scaling', const Size(320, 568), 2.0),
    ]) {
      testWidgets('lays out without overflow and keeps every group and New '
          'Group reachable on $name', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final calls = await _pumpScreen(
          tester,
          groups: [for (var i = 1; i <= 8; i++) _group('Group $i')],
        );
        await tester.tap(find.text('New Group'));
        await tester.scrollUntilVisible(
          find.text('Group 8'),
          200,
          scrollable: find.byType(Scrollable),
        );
        await tester.ensureVisible(find.text('Group 8'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(calls.newGroup, 1);
        expect(find.text('Group 8').hitTestable(), findsOneWidget);
      });
    }

    for (final (name, groups, errorMessage) in [
      ('empty', const <Group>[], null),
      ('loading', null, null),
      ('failed', null, 'No internet connection. Check your network.'),
    ]) {
      testWidgets('the $name state fits a small phone with 2x text scaling', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await _pumpScreen(tester, groups: groups, errorMessage: errorMessage);

        expect(tester.takeException(), isNull);
      });
    }
  });
}
