import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';
import 'package:splitzy/features/groups/domain/repositories/group_repository.dart';
import 'package:splitzy/features/groups/presentation/providers/group_providers.dart';
import 'package:splitzy/features/groups/presentation/screens/groups_page.dart';

/// A [GroupRepository] whose group streams the test drives: every
/// [watchGroups] call creates a new controller in [streams].
class _ControlledGroupRepository implements GroupRepository {
  final streams = <StreamController<List<Group>>>[];

  @override
  Stream<List<Group>> watchGroups(String ownerId) {
    final controller = StreamController<List<Group>>();
    streams.add(controller);
    return controller.stream;
  }

  @override
  Future<void> createGroup({
    required String ownerId,
    required String ownerName,
    required String name,
    required List<String> memberNames,
  }) => throw UnimplementedError();
}

final _trip = Group(
  id: 'g1',
  ownerId: 'owner',
  name: 'Trip to Dahab',
  members: const [
    Member(id: 'owner', name: 'Farah'),
    Member(id: 'sara', name: 'Sara'),
  ],
  createdAt: DateTime(2026, 10, 12),
);

Future<_ControlledGroupRepository> _pumpPage(WidgetTester tester) async {
  final repository = _ControlledGroupRepository();
  await tester.pumpWidget(
    ProviderScope(
      overrides: [groupRepositoryProvider.overrideWithValue(repository)],
      // Failures are shown, not retried automatically, so tests control
      // every load.
      retry: (_, _) => null,
      child: MaterialApp(
        theme: AppTheme.light,
        home: GroupsPage(
          ownerId: 'owner',
          onNewGroup: () {},
          onOpenGroup: (_) {},
        ),
      ),
    ),
  );
  return repository;
}

void main() {
  group('GroupsPage', () {
    testWidgets('shows loading, then the groups', (tester) async {
      final repository = await _pumpPage(tester);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      repository.streams.single.add([_trip]);
      await tester.pump();

      expect(find.text('Trip to Dahab'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows a failed load; Try again loads the groups again', (
      tester,
    ) async {
      final repository = await _pumpPage(tester);
      repository.streams.single.addError(const NetworkFailure());
      await tester.pump();
      expect(find.text(const NetworkFailure().message), findsOneWidget);

      await tester.tap(find.text('Try again'));
      await tester.pump();
      expect(repository.streams, hasLength(2));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      repository.streams.last.add([_trip]);
      await tester.pump();

      expect(find.text('Trip to Dahab'), findsOneWidget);
      expect(find.text(const NetworkFailure().message), findsNothing);
    });

    testWidgets('shows the generic message for an unexpected error', (
      tester,
    ) async {
      final repository = await _pumpPage(tester);

      repository.streams.single.addError(StateError('boom'));
      await tester.pump();

      expect(find.text(const UnexpectedFailure().message), findsOneWidget);
    });
  });
}
