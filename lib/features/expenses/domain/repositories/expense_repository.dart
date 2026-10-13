import 'package:splitzy/features/expenses/domain/entities/expense.dart';

/// What the app needs from expense storage.
///
/// Every method throws a `Failure` when the operation fails: an
/// `ExpenseFailure` or a shared failure such as `NetworkFailure`.
abstract interface class ExpenseRepository {
  /// The expenses of the group [groupId], newest first: the current list,
  /// then the whole list again on every change.
  Stream<List<Expense>> watchExpenses(String groupId);

  /// Adds an expense in EGP to the group [groupId]. Inputs are already
  /// validated and trimmed, and [shares] holds every member's share.
  Future<void> addExpense({
    required String groupId,
    required String description,
    required int amount,
    required String paidBy,
    required SplitType splitType,
    required Map<String, int> shares,
  });
}
