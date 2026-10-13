import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/expenses/domain/failures/expense_failure.dart';
import 'package:splitzy/features/expenses/domain/validation/expense_validation.dart';

void main() {
  group('ExpenseFailure', () {
    test('InvalidExpenseInput shows the validation message', () {
      const failure = InvalidExpenseInput(
        ExpenseValidationError.sharesDoNotAddUp,
      );

      expect(failure.message, 'Shares must add up to the amount.');
    });

    test('UnknownExpenseFailure shows the generic message and keeps its code '
        'out of it', () {
      const failure = UnknownExpenseFailure('permission-denied');

      expect(failure.message, const UnexpectedFailure().message);
      expect(failure.message, isNot(contains('permission-denied')));
      expect(failure.toString(), contains('permission-denied'));
    });
  });
}
