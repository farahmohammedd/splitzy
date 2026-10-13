import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/expenses/presentation/providers/expense_providers.dart';
import 'package:splitzy/features/expenses/presentation/screens/group_details_screen.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';

/// Connects [GroupDetailsScreen] to [groupExpensesProvider]: passes the
/// group's expenses, or the loading or failed state, down to the screen. The
/// group, the user and navigation come from the app root.
class GroupDetailsPage extends ConsumerWidget {
  const GroupDetailsPage({
    super.key,
    required this.group,
    required this.ownerId,
    required this.onBack,
    required this.onAddExpense,
  });

  final Group group;
  final String ownerId;
  final VoidCallback onBack;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expenses = ref.watch(groupExpensesProvider(group.id));
    // While loading again after a failure, the screen shows loading.
    final failed = expenses.hasError && !expenses.isLoading;

    return GroupDetailsScreen(
      group: group,
      ownerId: ownerId,
      expenses: failed ? null : expenses.value,
      expensesErrorMessage: failed ? messageFor(expenses.error) : null,
      onBack: onBack,
      onAddExpense: onAddExpense,
    );
  }
}
