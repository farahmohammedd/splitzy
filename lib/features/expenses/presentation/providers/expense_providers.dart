import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/domain/repositories/expense_repository.dart';
import 'package:splitzy/features/expenses/domain/usecases/add_expense_use_case.dart';

part 'expense_providers.g.dart';

// The instances below are created by `InjectionContainer`
// (lib/injection_container.dart) and supplied through its `ProviderScope`
// overrides. Without those overrides, reading them fails fast. They are kept
// alive because each override is a single app-lifetime instance.

@Riverpod(keepAlive: true)
ExpenseRepository expenseRepository(Ref ref) => throw UnimplementedError(
  'expenseRepositoryProvider is supplied by InjectionContainer.overrides',
);

@Riverpod(keepAlive: true)
AddExpenseUseCase addExpenseUseCase(Ref ref) => throw UnimplementedError(
  'addExpenseUseCaseProvider is supplied by InjectionContainer.overrides',
);

/// The expenses of the group [groupId], newest first, updated on every
/// change.
///
/// Watching expenses has no business rules, so it reads the repository
/// directly.
@riverpod
Stream<List<Expense>> groupExpenses(Ref ref, String groupId) {
  return ref.watch(expenseRepositoryProvider).watchExpenses(groupId);
}
