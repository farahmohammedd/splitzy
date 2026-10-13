import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';

Group _group({List<Member>? members}) => Group(
  id: 'g1',
  ownerId: 'u1',
  name: 'Trip to Dahab',
  members:
      members ??
      const [Member(id: 'u1', name: 'Farah'), Member(id: 'm2', name: 'Sara')],
  createdAt: DateTime.utc(2026, 10, 12),
);

void main() {
  group('Member', () {
    test('members with the same values are equal', () {
      expect(
        const Member(id: 'm1', name: 'Sara'),
        const Member(id: 'm1', name: 'Sara'),
      );
    });

    test('members with different ids are not equal, even with one name', () {
      expect(
        const Member(id: 'm1', name: 'Sara'),
        isNot(const Member(id: 'm2', name: 'Sara')),
      );
    });
  });

  group('Group', () {
    test('groups with the same values are equal', () {
      expect(_group(), _group());
      expect(_group().hashCode, _group().hashCode);
    });

    test('member order matters', () {
      final reordered = _group(members: _group().members.reversed.toList());

      expect(reordered, isNot(_group()));
    });

    test('its member list cannot be changed in place', () {
      expect(
        () => _group().members.add(const Member(id: 'm3', name: 'Mona')),
        throwsUnsupportedError,
      );
    });
  });
}
