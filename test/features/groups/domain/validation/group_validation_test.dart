import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/features/groups/domain/validation/group_validation.dart';

String _chars(int length) => 'a' * length;

/// [count] distinct, valid member names.
List<String> _members(int count) => [
  for (var i = 1; i <= count; i++) 'Member $i',
];

void main() {
  group('GroupValidation.groupName', () {
    test('accepts a name', () {
      expect(GroupValidation.groupName('Trip to Dahab'), isNull);
    });

    test('requires a name, ignoring surrounding whitespace', () {
      expect(GroupValidation.groupName(''), GroupValidationError.nameRequired);
      expect(
        GroupValidation.groupName('   '),
        GroupValidationError.nameRequired,
      );
    });

    test('accepts 50 characters and rejects 51', () {
      expect(GroupValidation.groupName(_chars(50)), isNull);
      expect(
        GroupValidation.groupName(_chars(51)),
        GroupValidationError.nameTooLong,
      );
    });

    test('measures the length after trimming', () {
      expect(GroupValidation.groupName('  ${_chars(50)}  '), isNull);
    });
  });

  group('GroupValidation.memberName', () {
    test('accepts a name', () {
      expect(GroupValidation.memberName('Sara'), isNull);
    });

    test('requires a name, ignoring surrounding whitespace', () {
      expect(
        GroupValidation.memberName(' '),
        GroupValidationError.memberNameRequired,
      );
    });

    test('accepts 50 characters and rejects 51', () {
      expect(GroupValidation.memberName(_chars(50)), isNull);
      expect(
        GroupValidation.memberName(_chars(51)),
        GroupValidationError.memberNameTooLong,
      );
    });
  });

  group('GroupValidation.members', () {
    test('accepts the owner and one other member', () {
      expect(GroupValidation.members(['Farah', 'Sara']), isNull);
    });

    test('rejects the owner alone', () {
      expect(
        GroupValidation.members(['Farah']),
        GroupValidationError.tooFewMembers,
      );
    });

    test('accepts 50 members and rejects 51', () {
      expect(GroupValidation.members(_members(50)), isNull);
      expect(
        GroupValidation.members(_members(51)),
        GroupValidationError.tooManyMembers,
      );
    });

    test('rejects a blank member name', () {
      expect(
        GroupValidation.members(['Farah', '  ']),
        GroupValidationError.memberNameRequired,
      );
    });

    test('rejects a member name that is too long', () {
      expect(
        GroupValidation.members(['Farah', _chars(51)]),
        GroupValidationError.memberNameTooLong,
      );
    });

    test('rejects the same name twice, ignoring case and whitespace', () {
      expect(
        GroupValidation.members(['Farah', 'Sara', ' sara ']),
        GroupValidationError.duplicateMemberName,
      );
    });

    test("counts the owner's name when looking for duplicates", () {
      expect(
        GroupValidation.members(['Farah', 'FARAH']),
        GroupValidationError.duplicateMemberName,
      );
    });
  });

  group('GroupValidationError', () {
    test('each error carries its user-facing message', () {
      final expected = <GroupValidationError, String>{
        GroupValidationError.nameRequired: 'Enter a group name.',
        GroupValidationError.nameTooLong:
            'Group name must be 50 characters or fewer.',
        GroupValidationError.memberNameRequired:
            'Enter a name for every member.',
        GroupValidationError.memberNameTooLong:
            'Member names must be 50 characters or fewer.',
        GroupValidationError.duplicateMemberName:
            'Each member needs a different name.',
        GroupValidationError.tooFewMembers: 'Add at least one other member.',
        GroupValidationError.tooManyMembers:
            'A group can have at most 50 members.',
      };

      expect(expected.keys, unorderedEquals(GroupValidationError.values));
      for (final MapEntry(key: error, value: message) in expected.entries) {
        expect(error.message, message, reason: '$error');
      }
    });
  });
}
