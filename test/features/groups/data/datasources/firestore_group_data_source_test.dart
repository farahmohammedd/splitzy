import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/groups/data/datasources/firestore_group_data_source.dart';
import 'package:splitzy/features/groups/data/exceptions/group_exceptions.dart';
import 'package:splitzy/features/groups/data/models/group_dto.dart';

typedef _Json = Map<String, dynamic>;

// cloud_firestore marks these SDK types @sealed so apps do not implement
// them; implementing them is the only way to mock Firestore with mocktail
// (the approved test library; a fake-Firestore package would be a new
// dependency). Test-only.
// ignore_for_file: subtype_of_sealed_class

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollection extends Mock implements CollectionReference<_Json> {}

class _MockQuery extends Mock implements Query<_Json> {}

class _MockQuerySnapshot extends Mock implements QuerySnapshot<_Json> {}

class _MockDocument extends Mock implements QueryDocumentSnapshot<_Json> {}

class _MockDocumentReference extends Mock implements DocumentReference<_Json> {}

final _originalStack = StackTrace.fromString('original-firestore-stack');

FirebaseException _firestoreError(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

const _group = GroupDto(
  ownerId: 'u1',
  name: 'Trip to Dahab',
  members: [
    MemberDto(id: 'u1', name: 'Farah'),
    MemberDto(id: 'm2', name: 'Sara'),
  ],
);

void main() {
  late _MockFirestore firestore;
  late _MockCollection groups;
  late _MockQuery ownedGroups;
  late FirestoreGroupDataSource dataSource;

  setUp(() {
    firestore = _MockFirestore();
    groups = _MockCollection();
    ownedGroups = _MockQuery();
    when(() => firestore.collection('groups')).thenReturn(groups);
    when(
      () => groups.where('ownerId', isEqualTo: 'u1'),
    ).thenReturn(ownedGroups);
    dataSource = FirestoreGroupDataSource(firestore);
  });

  _MockDocument document(String id, _Json data) {
    final doc = _MockDocument();
    when(() => doc.id).thenReturn(id);
    when(doc.data).thenReturn(data);
    return doc;
  }

  group('watchGroups', () {
    test("reads only the owner's groups, with their ids", () async {
      final snapshot = _MockQuerySnapshot();
      final doc = document('g1', {
        'ownerId': 'u1',
        'name': 'Trip to Dahab',
        'members': [
          {'id': 'u1', 'name': 'Farah'},
          {'id': 'm2', 'name': 'Sara'},
        ],
        'createdAt': null,
      });
      when(() => snapshot.docs).thenReturn([doc]);
      when(ownedGroups.snapshots).thenAnswer((_) => Stream.value(snapshot));

      final groupsRead = await dataSource.watchGroups('u1').first;

      expect(groupsRead, [(id: 'g1', data: _group)]);
      verify(() => groups.where('ownerId', isEqualTo: 'u1')).called(1);
    });

    test('translates a Firestore error, keeping its stack trace', () async {
      when(ownedGroups.snapshots).thenAnswer(
        (_) => Stream.error(_firestoreError('unavailable'), _originalStack),
      );

      await expectLater(
        dataSource.watchGroups('u1'),
        emitsError(isA<NetworkException>()),
      );
      try {
        await dataSource.watchGroups('u1').first;
      } on NetworkException catch (_, stackTrace) {
        expect(stackTrace.toString(), _originalStack.toString());
      }
    });

    test('passes other errors through unchanged', () async {
      final error = StateError('bug');
      when(ownedGroups.snapshots).thenAnswer((_) => Stream.error(error));

      await expectLater(dataSource.watchGroups('u1'), emitsError(same(error)));
    });
  });

  group('createGroup', () {
    test('adds exactly the stored fields, with plain member maps and the '
        'server time', () async {
      when(
        () => groups.add(any()),
      ).thenAnswer((_) async => _MockDocumentReference());

      await dataSource.createGroup(_group);

      final written =
          verify(() => groups.add(captureAny())).captured.single as _Json;
      expect(
        written.keys,
        unorderedEquals(['ownerId', 'name', 'members', 'createdAt']),
      );
      expect(written['ownerId'], 'u1');
      expect(written['name'], 'Trip to Dahab');
      expect(written['members'], [
        {'id': 'u1', 'name': 'Farah'},
        {'id': 'm2', 'name': 'Sara'},
      ]);
      expect(written['createdAt'], isA<FieldValue>());
    });

    test('translates a Firestore error, keeping its stack trace', () async {
      when(() => groups.add(any())).thenAnswer(
        (_) =>
            Future.error(_firestoreError('permission-denied'), _originalStack),
      );

      try {
        await dataSource.createGroup(_group);
        fail('createGroup should have thrown');
      } on UnknownGroupException catch (error, stackTrace) {
        expect(error.code, 'permission-denied');
        expect(stackTrace.toString(), _originalStack.toString());
      }
    });
  });

  group('newId', () {
    test('uses a locally generated Firestore id', () {
      final reference = _MockDocumentReference();
      when(() => reference.id).thenReturn('generated-id');
      when(() => groups.doc()).thenReturn(reference);

      expect(dataSource.newId(), 'generated-id');
    });
  });
}
