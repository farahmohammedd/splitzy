import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/groups/presentation/providers/create_group_controller.dart';
import 'package:splitzy/features/groups/presentation/screens/create_group_screen.dart';

/// Connects [CreateGroupScreen] to [CreateGroupController]: forwards create
/// attempts and passes their progress and failure message back to the
/// screen. When an attempt succeeds it calls [onCreated], which closes the
/// screen. The owner and navigation callbacks come from the app root.
class CreateGroupPage extends ConsumerWidget {
  const CreateGroupPage({
    super.key,
    required this.ownerId,
    required this.ownerName,
    required this.onBack,
    required this.onCreated,
  });

  final String ownerId;
  final String ownerName;
  final VoidCallback onBack;
  final VoidCallback onCreated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(createGroupControllerProvider, (previous, next) {
      // Loading followed by data is a successful attempt.
      if ((previous?.isLoading ?? false) && next is AsyncData) onCreated();
    });
    final attempt = ref.watch(createGroupControllerProvider);

    return CreateGroupScreen(
      ownerName: ownerName,
      onBack: onBack,
      onCreate: (name, memberNames) => ref
          .read(createGroupControllerProvider.notifier)
          .create(
            ownerId: ownerId,
            ownerName: ownerName,
            name: name,
            memberNames: memberNames,
          ),
      isSubmitting: attempt.isLoading,
      errorMessage: switch (attempt) {
        AsyncError(:final error) => messageFor(error),
        _ => null,
      },
    );
  }
}
