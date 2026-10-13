import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/expenses/presentation/providers/add_expense_controller.dart';
import 'package:splitzy/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';

/// Connects [AddExpenseScreen] to [AddExpenseController]: forwards save
/// attempts and passes their progress and failure message back to the
/// screen. When an attempt succeeds it calls [onSaved], which closes the
/// screen. The groups, the user and navigation come from the app root.
class AddExpensePage extends ConsumerWidget {
  const AddExpensePage({
    super.key,
    required this.groups,
    required this.ownerId,
    required this.onBack,
    required this.onSaved,
    required this.onNewGroup,
    this.initialGroupId,
    this.groupsErrorMessage,
  });

  /// `null` while loading.
  final List<Group>? groups;
  final String? groupsErrorMessage;
  final String ownerId;
  final String? initialGroupId;
  final VoidCallback onBack;
  final VoidCallback onSaved;
  final VoidCallback onNewGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(addExpenseControllerProvider, (previous, next) {
      // Loading followed by data is a successful attempt.
      if ((previous?.isLoading ?? false) && next is AsyncData) onSaved();
    });
    final attempt = ref.watch(addExpenseControllerProvider);

    return AddExpenseScreen(
      groups: groups,
      groupsErrorMessage: groupsErrorMessage,
      ownerId: ownerId,
      initialGroupId: initialGroupId,
      onBack: onBack,
      onNewGroup: onNewGroup,
      onSave: (input) => ref
          .read(addExpenseControllerProvider.notifier)
          .add(
            groupId: input.group.id,
            memberIds: [for (final member in input.group.members) member.id],
            description: input.description,
            amount: input.amount,
            paidBy: input.paidBy,
            splitType: input.splitType,
            customShares: input.customShares,
          ),
      isSubmitting: attempt.isLoading,
      errorMessage: switch (attempt) {
        AsyncError(:final error) => messageFor(error),
        _ => null,
      },
    );
  }
}
