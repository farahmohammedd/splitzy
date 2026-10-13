import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';
import 'package:splitzy/features/groups/presentation/widgets/group_list_card.dart';

/// A group named [name] whose members are named by [memberNames], the owner
/// first.
Group _group(String name, List<String> memberNames) => Group(
  id: 'g1',
  ownerId: 'owner',
  name: name,
  members: [
    for (final (i, member) in memberNames.indexed)
      Member(id: i == 0 ? 'owner' : 'm$i', name: member),
  ],
  createdAt: DateTime(2026, 10, 12, 18, 30),
);

Future<void> _pumpCard(WidgetTester tester, Group group) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      // In the app the card is always inside the scrolling Groups list.
      home: Scaffold(
        body: SingleChildScrollView(
          child: GroupListCard(group: group, index: 0),
        ),
      ),
    ),
  );
}

void main() {
  group('GroupListCard', () {
    testWidgets('shows the initial, name, members and creation date', (
      tester,
    ) async {
      await _pumpCard(tester, _group('trip to Dahab', ['Farah', 'Sara']));

      expect(find.text('T'), findsOneWidget);
      expect(find.text('trip to Dahab'), findsOneWidget);
      expect(find.text('F'), findsOneWidget);
      expect(find.text('S'), findsOneWidget);
      expect(find.text('2 members'), findsOneWidget);
      expect(find.text('Created Oct 12'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('shows four members, then how many more', (tester) async {
      await _pumpCard(
        tester,
        _group('Friday Dinners', [
          'Farah',
          'Mona',
          'Nour',
          'Omar',
          'Sara',
          'Lina',
        ]),
      );

      for (final initial in ['M', 'N', 'O']) {
        expect(find.text(initial), findsOneWidget, reason: initial);
      }
      expect(find.text('L'), findsNothing);
      expect(find.text('+2'), findsOneWidget);
      expect(find.text('6 members'), findsOneWidget);
    });

    testWidgets('shows every member when there are four', (tester) async {
      await _pumpCard(
        tester,
        _group('Trip', ['Farah', 'Sara', 'Mona', 'Omar']),
      );

      expect(find.text('O'), findsOneWidget);
      expect(find.textContaining('+'), findsNothing);
    });

    testWidgets('fits a small phone with 2x text scaling', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await _pumpCard(
        tester,
        _group('A rather long group name for a small phone', [
          'Farah',
          'Mona',
          'Nour',
          'Omar',
          'Sara',
        ]),
      );

      expect(tester.takeException(), isNull);
    });
  });

  group('membersLabel', () {
    test('uses the singular for one member', () {
      expect(membersLabel(1), '1 member');
      expect(membersLabel(2), '2 members');
      expect(membersLabel(50), '50 members');
    });
  });

  group('createdLabel', () {
    test('shows the month and day, without the year', () {
      expect(createdLabel(DateTime(2026, 1, 5)), 'Created Jan 5');
      expect(createdLabel(DateTime(2025, 12, 31)), 'Created Dec 31');
    });

    test('uses the device time zone', () {
      final utc = DateTime.utc(2026, 10, 12, 12);

      expect(createdLabel(utc), createdLabel(utc.toLocal()));
    });
  });
}
