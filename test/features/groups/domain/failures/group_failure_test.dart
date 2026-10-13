import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/groups/domain/failures/group_failure.dart';
import 'package:splitzy/features/groups/domain/validation/group_validation.dart';

void main() {
  group('GroupFailure', () {
    test('is a shared Failure', () {
      expect(const UnknownGroupFailure('x'), isA<Failure>());
    });

    test('invalid input shows the validation message', () {
      const failure = InvalidGroupInput(GroupValidationError.tooFewMembers);

      expect(failure.message, 'Add at least one other member.');
    });

    test('an unknown failure shows the generic message, never its code', () {
      const failure = UnknownGroupFailure('permission-denied');

      expect(failure.message, const UnexpectedFailure().message);
      expect(failure.message, isNot(contains('permission-denied')));
      expect(failure.toString(), contains('permission-denied'));
    });
  });
}
