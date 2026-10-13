import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/core/error/error_reporter_provider.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/core/error/run_guarded.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/presentation/providers/expense_providers.dart';

part 'add_expense_controller.g.dart';

/// Runs an add-expense attempt and exposes its progress: data (idle or
/// done), loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: the page closes the screen when an attempt succeeds.
@riverpod
class AddExpenseController extends _$AddExpenseController {
  @override
  FutureOr<void> build() {}

  /// See `AddExpenseUseCase.call` for the parameters.
  Future<void> add({
    required String groupId,
    required List<String> memberIds,
    required String description,
    required int amount,
    required String paidBy,
    required SplitType splitType,
    Map<String, int> customShares = const {},
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await runGuarded(
      () => ref.read(addExpenseUseCaseProvider)(
        groupId: groupId,
        memberIds: memberIds,
        description: description,
        amount: amount,
        paidBy: paidBy,
        splitType: splitType,
        customShares: customShares,
      ),
      reporter: ref.read(errorReporterProvider),
      reason: 'Adding an expense',
    );
    if (ref.mounted) state = result;
  }
}
