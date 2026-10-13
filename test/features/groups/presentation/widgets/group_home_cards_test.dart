import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';
import 'package:splitzy/features/groups/presentation/widgets/group_home_cards.dart';

Group _group(String id, String name, List<String> memberNames) => Group(
  id: id,
  ownerId: 'owner',
  name: name,
  members: [
    for (final (i, member) in memberNames.indexed)
      Member(id: i == 0 ? 'owner' : 'm$i', name: member),
  ],
  createdAt: DateTime(2026, 10, 12),
);

Future<void> _pump(
  WidgetTester tester, {
  List<Group>? groups,
  String? errorMessage,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: GroupHomeCards(groups: groups, errorMessage: errorMessage),
      ),
    ),
  );
}

void main() {
  group('GroupHomeCards', () {
    testWidgets('shows a card per group with its initial and name', (
      tester,
    ) async {
      await _pump(
        tester,
        groups: [
          _group('1', 'Trip to Dahab', ['Farah', 'Sara']),
          _group('2', 'Apartment', ['Farah', 'Mona']),
        ],
      );

      expect(find.text('Trip to Dahab'), findsOneWidget);
      expect(find.text('Apartment'), findsOneWidget);
      expect(find.text('T'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('shows three members, then how many more', (tester) async {
      await _pump(
        tester,
        groups: [
          _group('1', 'Trip', ['Farah', 'Sara', 'Nour', 'Omar']),
        ],
      );

      expect(find.text('N'), findsOneWidget);
      expect(find.text('O'), findsNothing);
      expect(find.text('+1'), findsOneWidget);
    });

    testWidgets('scrolls sideways to groups beyond the screen', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await _pump(
        tester,
        groups: [
          for (var i = 1; i <= 5; i++)
            _group('$i', 'Group $i', ['Farah', 'Sara']),
        ],
      );
      expect(find.text('Group 5').hitTestable(), findsNothing);

      await tester.drag(find.text('Group 1'), const Offset(-1000, 0));
      await tester.pumpAndSettle();

      expect(find.text('Group 5').hitTestable(), findsOneWidget);
    });

    testWidgets('shows loading while the groups are unknown', (tester) async {
      await _pump(tester);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows a failed load', (tester) async {
      await _pump(tester, errorMessage: 'Something went wrong.');

      expect(find.text('Something went wrong.'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('fits a small phone with 2x text scaling', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.reset);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

      await _pump(
        tester,
        groups: [
          _group('1', 'A long group name that wraps', ['Farah', 'Sara']),
          _group('2', 'Short', ['Farah', 'Sara', 'Nour', 'Omar', 'Lina']),
        ],
      );

      expect(tester.takeException(), isNull);
    });
  });
}
