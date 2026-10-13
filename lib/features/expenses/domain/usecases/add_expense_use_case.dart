import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/domain/failures/expense_failure.dart';
import 'package:splitzy/features/expenses/domain/money/equal_split.dart';
import 'package:splitzy/features/expenses/domain/repositories/expense_repository.dart';
import 'package:splitzy/features/expenses/domain/validation/expense_validation.dart';

/// Adds an expense after checking the expense rules and working out every
/// member's share.
class AddExpenseUseCase {
  const AddExpenseUseCase(this._repository);

  final ExpenseRepository _repository;

  /// [memberIds] are the group's members in group order. With
  /// [SplitType.equal] the shares are calculated (and [customShares] is
  /// ignored); with [SplitType.custom] they are [customShares].
  ///
  /// Throws [InvalidExpenseInput] without contacting the repository when the
  /// input breaks a rule; otherwise throws whatever failure the repository
  /// reports. The description is trimmed.
  Future<void> call({
    required String groupId,
    required List<String> memberIds,
    required String description,
    required int amount,
    required String paidBy,
    required SplitType splitType,
    Map<String, int> customShares = const {},
  }) async {
    final trimmedDescription = description.trim();

    final inputError =
        ExpenseValidation.description(trimmedDescription) ??
        ExpenseValidation.amount(amount) ??
        ExpenseValidation.payer(paidBy, memberIds);
    if (inputError != null) throw InvalidExpenseInput(inputError);

    final Map<String, int> shares;
    switch (splitType) {
      case SplitType.equal:
        shares = splitEqually(amount, memberIds);
      case SplitType.custom:
        final sharesError = ExpenseValidation.customShares(
          customShares,
          amount,
          memberIds,
        );
        if (sharesError != null) throw InvalidExpenseInput(sharesError);
        // In group order, whatever order they were entered in.
        shares = {for (final id in memberIds) id: customShares[id] ?? 0};
    }

    return _repository.addExpense(
      groupId: groupId,
      description: trimmedDescription,
      amount: amount,
      paidBy: paidBy,
      splitType: splitType,
      shares: shares,
    );
  }
}
