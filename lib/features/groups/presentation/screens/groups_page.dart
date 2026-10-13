import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/groups/presentation/providers/group_providers.dart';
import 'package:splitzy/features/groups/presentation/screens/groups_screen.dart';

/// Connects [GroupsScreen] to [groupsProvider]: passes the owner's groups, or
/// the loading or failed state, down to the screen, and loads them again on
/// Try again. The owner and navigation come from the app root.
class GroupsPage extends ConsumerWidget {
  const GroupsPage({
    super.key,
    required this.ownerId,
    required this.onNewGroup,
  });

  final String ownerId;
  final VoidCallback onNewGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsProvider(ownerId));
    // While loading again after a failure, the screen shows loading.
    final failed = groups.hasError && !groups.isLoading;

    return GroupsScreen(
      groups: failed ? null : groups.value,
      errorMessage: failed ? messageFor(groups.error) : null,
      onNewGroup: onNewGroup,
      onRetry: () => ref.invalidate(groupsProvider(ownerId)),
    );
  }
}
