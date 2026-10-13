import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/presentation/widgets/group_balance_text.dart';
import 'package:splitzy/features/groups/presentation/widgets/group_initial_tile.dart';
import 'package:splitzy/features/groups/presentation/widgets/member_avatar_stack.dart';

/// The user's groups as a horizontal row of small cards, for Home's "Your
/// Groups" section, as in the design reference.
///
/// [groups] is `null` while loading; [errorMessage] is a failed load.
class GroupHomeCards extends StatelessWidget {
  const GroupHomeCards({
    super.key,
    required this.groups,
    required this.onOpenGroup,
    this.errorMessage,
    this.balances = const {},
  });

  final List<Group>? groups;
  final String? errorMessage;

  /// Opens a group's page.
  final ValueChanged<Group> onOpenGroup;

  /// The user's balance in each group, by group id; groups missing from
  /// it show no balance (e.g. still loading).
  final Map<String, GroupBalance> balances;

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
              _GroupHomeCard(
                group: group,
                index: i,
                balance: balances[group.id],
                onTap: () => onOpenGroup(group),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupHomeCard extends StatelessWidget {
  const _GroupHomeCard({
    required this.group,
    required this.index,
    required this.balance,
    required this.onTap,
  });

  /// Card width, measured from the design reference (about two and a half
  /// cards fit on a phone, hinting that the row scrolls).
  static const double _width = 160;

  /// How many member avatars are shown before "+N".
  static const int _maxAvatars = 3;

  final Group group;
  final int index;
  final GroupBalance? balance;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      width: _width,
      child: Material(
        color: scheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side: BorderSide(color: scheme.outline),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
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
                MemberAvatarStack(
                  members: group.members,
                  maxVisible: _maxAvatars,
                ),
                if (balance != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  GroupBalanceText(balance: balance),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
