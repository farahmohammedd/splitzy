import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/presentation/widgets/group_initial_tile.dart';
import 'package:splitzy/features/groups/presentation/widgets/member_avatar_stack.dart';

/// The user's groups as a horizontal row of small cards, for Home's "Your
/// Groups" section, as in the design reference.
///
/// [groups] is `null` while loading; [errorMessage] is a failed load.
class GroupHomeCards extends StatelessWidget {
  const GroupHomeCards({super.key, required this.groups, this.errorMessage});

  final List<Group>? groups;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    final groups = this.groups;
    final errorMessage = this.errorMessage;
    final theme = Theme.of(context);

    if (errorMessage != null) {
      return Text(
        errorMessage,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }
    if (groups == null) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.md),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Cards share the tallest card's height, which follows the text scale.
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, group) in groups.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpacing.md),
              _GroupHomeCard(group: group, index: i),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupHomeCard extends StatelessWidget {
  const _GroupHomeCard({required this.group, required this.index});

  /// Card width, measured from the design reference (about two and a half
  /// cards fit on a phone, hinting that the row scrolls).
  static const double _width = 160;

  /// How many member avatars are shown before "+N".
  static const int _maxAvatars = 3;

  final Group group;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Container(
      width: _width,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GroupInitialTile(name: group.name, index: index, size: 40),
          const SizedBox(height: AppSpacing.sm),
          Text(
            group.name,
            style: theme.textTheme.titleSmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppSpacing.sm),
          MemberAvatarStack(members: group.members, maxVisible: _maxAvatars),
        ],
      ),
    );
  }
}
