import 'package:splitzy/core/error/exceptions.dart';

/// Expense storage errors reported by the expense data source, independent of
/// the SDK that produced them. Shared errors such as `NetworkException` come
/// from `core/error/exceptions.dart`.
sealed class ExpenseException extends AppException {
  const ExpenseException();
}

/// Any expense storage error without a more specific type (e.g. a request
/// the security rules rejected); [code] keeps the original error code for
/// debugging.
final class UnknownExpenseException extends ExpenseException {
  const UnknownExpenseException(this.code);

  final String code;

  @override
  String toString() => 'UnknownExpenseException($code)';
}
