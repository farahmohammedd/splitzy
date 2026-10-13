import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/expenses/domain/validation/expense_validation.dart';

/// Why an expense operation failed, in domain terms, with the text to show
/// the user.
///
/// Thrown by the expense repository and use cases; controllers turn it into
/// an `AsyncError` through `runGuarded`. Shared failures such as
/// `NetworkFailure` come from `core/error/failures.dart`.
sealed class ExpenseFailure extends Failure {
  const ExpenseFailure();
}

/// The input broke a validation rule; nothing was sent to the backend.
final class InvalidExpenseInput extends ExpenseFailure {
  const InvalidExpenseInput(this.error);

  final ExpenseValidationError error;

  @override
  String get message => error.message;

  @override
  String toString() => 'InvalidExpenseInput($error)';
}

/// Any other failure; [code] keeps the original error code for debugging and
/// is never shown to the user.
final class UnknownExpenseFailure extends ExpenseFailure {
  const UnknownExpenseFailure(this.code);

  final String code;

  @override
  String get message => const UnexpectedFailure().message;

  @override
  String toString() => 'UnknownExpenseFailure($code)';
}
