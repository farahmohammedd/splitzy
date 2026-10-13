import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/groups/data/datasources/firestore_group_data_source.dart';
import 'package:splitzy/features/groups/data/exceptions/group_exceptions.dart';
import 'package:splitzy/features/groups/data/models/group_dto.dart';
import 'package:splitzy/features/groups/data/repositories/firestore_group_repository.dart';
import 'package:splitzy/features/groups/domain/failures/group_failure.dart';

class _MockDataSource extends Mock implements FirestoreGroupDataSource {}

final _now = DateTime.utc(2026, 10, 12, 12);
final _originalStack = StackTrace.fromString('original-data-source-stack');

GroupDto _dto(String name, {DateTime? createdAt}) => GroupDto(
  ownerId: 'u1',
  name: name,
  members: const [
    MemberDto(id: 'u1', name: 'Farah'),
    MemberDto(id: 'm2', name: 'Sara'),
  ],
  createdAt: createdAt,
);

void main() {
  late _MockDataSource dataSource;
  late FirestoreGroupRepository repository;

  setUpAll(() => registerFallbackValue(_dto('fallback')));

  setUp(() {
    dataSource = _MockDataSource();
    repository = FirestoreGroupRepository(dataSource, clock: () => _now);
  });

  group('watchGroups', () {
    test('maps documents to groups, newest first', () async {
      when(() => dataSource.watchGroups('u1')).thenAnswer(
        (_) => Stream.value([
          (id: 'old', data: _dto('Old', createdAt: DateTime.utc(2026, 1))),
          (id: 'new', data: _dto('New', createdAt: DateTime.utc(2026, 9))),
        ]),
      );

      final groups = await repository.watchGroups('u1').first;

      expect([for (final g in groups) g.id], ['new', 'old']);
      expect(groups.first.name, 'New');
      expect(groups.first.members.first.name, 'Farah');
    });

    test('a just-created group (pending time) counts as created now and '
        'comes first', () async {
      when(() => dataSource.watchGroups('u1')).thenAnswer(
        (_) => Stream.value([
          (id: 'old', data: _dto('Old', createdAt: DateTime.utc(2026, 9))),
          (id: 'pending', data: _dto('Pending')),
        ]),
      );

      final groups = await repository.watchGroups('u1').first;

      expect(groups.first.id, 'pending');
      expect(groups.first.createdAt, _now);
    });

    test('orders groups created at the same time by id', () async {
      final sameTime = DateTime.utc(2026, 5);
      when(() => dataSource.watchGroups('u1')).thenAnswer(
        (_) => Stream.value([
          (id: 'b', data: _dto('B', createdAt: sameTime)),
          (id: 'a', data: _dto('A', createdAt: sameTime)),
        ]),
      );

      final groups = await repository.watchGroups('u1').first;

      expect([for (final g in groups) g.id], ['a', 'b']);
    });

    test('translates project exceptions into failures', () async {
      for (final (exception, matcher) in [
        (const NetworkException(), isA<NetworkFailure>()),
        (
          const UnknownGroupException('permission-denied'),
          isA<UnknownGroupFailure>().having(
            (f) => f.code,
            'code',
            'permission-denied',
          ),
        ),
      ]) {
        when(
          () => dataSource.watchGroups('u1'),
        ).thenAnswer((_) => Stream.error(exception, _originalStack));

        await expectLater(
          repository.watchGroups('u1'),
          emitsError(matcher),
          reason: '$exception',
        );
      }
    });

    test('passes other errors through unchanged', () async {
      final error = StateError('bug');
      when(
        () => dataSource.watchGroups('u1'),
      ).thenAnswer((_) => Stream.error(error));

      await expectLater(repository.watchGroups('u1'), emitsError(same(error)));
    });
  });

  group('createGroup', () {
    test('writes the owner first, with their user id, then the members in '
        'order with new ids', () async {
      var nextId = 0;
      when(() => dataSource.newId()).thenAnswer((_) => 'id${++nextId}');
      when(() => dataSource.createGroup(any())).thenAnswer((_) async {});

      await repository.createGroup(
        ownerId: 'u1',
        ownerName: 'Farah',
        name: 'Trip to Dahab',
        memberNames: ['Sara', 'Mona'],
      );

      final written =
          verify(() => dataSource.createGroup(captureAny())).captured.single
              as GroupDto;
      expect(written.ownerId, 'u1');
      expect(written.name, 'Trip to Dahab');
      expect(written.members, const [
        MemberDto(id: 'u1', name: 'Farah'),
        MemberDto(id: 'id1', name: 'Sara'),
        MemberDto(id: 'id2', name: 'Mona'),
      ]);
    });

    test('translates a project exception, keeping its stack trace', () async {
      when(() => dataSource.newId()).thenReturn('id');
      when(() => dataSource.createGroup(any())).thenAnswer(
        (_) => Future.error(const NetworkException(), _originalStack),
      );

      try {
        await repository.createGroup(
          ownerId: 'u1',
          ownerName: 'Farah',
          name: 'Trip',
          memberNames: ['Sara'],
        );
        fail('createGroup should have thrown');
      } on NetworkFailure catch (_, stackTrace) {
        expect(stackTrace.toString(), _originalStack.toString());
      }
    });
  });
}
