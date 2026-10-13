import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/features/groups/data/models/group_dto.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';

final _created = DateTime.utc(2026, 10, 12, 9, 30);

Map<String, dynamic> _json({Object? createdAt}) => {
  'ownerId': 'u1',
  'name': 'Trip to Dahab',
  'members': [
    {'id': 'u1', 'name': 'Farah'},
    {'id': 'm2', 'name': 'Sara'},
  ],
  'createdAt': createdAt,
};

void main() {
  group('GroupDto', () {
    test('reads a Firestore document, keeping the member order', () {
      final dto = GroupDto.fromJson(
        _json(createdAt: Timestamp.fromDate(_created)),
      );

      expect(dto.ownerId, 'u1');
      expect(dto.name, 'Trip to Dahab');
      expect(dto.members, const [
        MemberDto(id: 'u1', name: 'Farah'),
        MemberDto(id: 'm2', name: 'Sara'),
      ]);
      // Firestore returns local time; it is the same moment.
      expect(dto.createdAt?.isAtSameMomentAs(_created), isTrue);
    });

    test('reads a pending server timestamp as null', () {
      expect(GroupDto.fromJson(_json()).createdAt, isNull);
    });

    test('becomes a domain Group with the given id and time', () {
      final dto = GroupDto.fromJson(_json());

      expect(
        dto.toEntity(id: 'g1', createdAt: _created),
        Group(
          id: 'g1',
          ownerId: 'u1',
          name: 'Trip to Dahab',
          members: const [
            Member(id: 'u1', name: 'Farah'),
            Member(id: 'm2', name: 'Sara'),
          ],
          createdAt: _created,
        ),
      );
    });

    test('writes its fields under the names Firestore stores', () {
      final json = GroupDto(
        ownerId: 'u1',
        name: 'Trip to Dahab',
        members: const [MemberDto(id: 'u1', name: 'Farah')],
        createdAt: _created,
      ).toJson();

      expect(json.keys, unorderedEquals(_json().keys));
      expect(json['createdAt'], Timestamp.fromDate(_created));
    });
  });

  group('MemberDto', () {
    test('round-trips through JSON', () {
      const member = MemberDto(id: 'm2', name: 'Sara');

      expect(member.toJson(), {'id': 'm2', 'name': 'Sara'});
      expect(MemberDto.fromJson(member.toJson()), member);
    });

    test('becomes a domain Member', () {
      expect(
        const MemberDto(id: 'm2', name: 'Sara').toEntity(),
        const Member(id: 'm2', name: 'Sara'),
      );
    });
  });
}
