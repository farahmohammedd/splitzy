import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/presentation/providers/group_providers.dart';
import 'package:splitzy/features/groups/presentation/screens/groups_screen.dart';
import 'package:splitzy/features/groups/presentation/widgets/group_balance_text.dart';

/// Connects [GroupsScreen] to [groupsProvider]: passes the owner's groups, or
/// the loading or failed state, down to the screen, and loads them again on
/// Try again. The owner and navigation come from the app root.
class GroupsPage extends ConsumerWidget {
  const GroupsPage({
    super.key,
    required this.ownerId,
    required this.onNewGroup,
    required this.onOpenGroup,
    this.balances = const {},
  });

  final String ownerId;
  final VoidCallback onNewGroup;
  final ValueChanged<Group> onOpenGroup;

  /// The user's balance in each group, by group id (from the app root).
  final Map<String, GroupBalance> balances;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider(ownerId));
    // While loading again after a failure, the screen shows loading.
    final failed = groups.hasError && !groups.isLoading;

    return GroupsScreen(
      groups: failed ? null : groups.value,
      errorMessage: failed ? messageFor(groups.error) : null,
      onNewGroup: onNewGroup,
      onOpenGroup: onOpenGroup,
      balances: balances,
      onRetry: () => ref.invalidate(groupsProvider(ownerId)),
    );
  }
}
