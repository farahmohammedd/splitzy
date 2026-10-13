import 'package:flutter/material.dart';
import 'package:splitzy/core/format/date_format.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/presentation/widgets/group_initial_tile.dart';
import 'package:splitzy/features/groups/presentation/widgets/member_avatar_stack.dart';

/// A group in the Groups list: its initial, name, members and creation date,
/// with an arrow, as in the design reference.
class GroupListCard extends StatelessWidget {
  const GroupListCard({
    super.key,
    required this.group,
    required this.index,
    this.onTap,
  });

  /// How many member avatars are shown before "+N".
  static const int _maxAvatars = 4;

  final Group group;

  /// The group's position in the list; picks the tile's color.
  final int index;

  /// Opens the group's page.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final mutedText = textTheme.bodyMedium?.copyWith(
      color: scheme.onSurfaceVariant,
    );
    final borderRadius = BorderRadius.circular(AppRadius.lg);

    return Material(
      color: scheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius,
        side: BorderSide(color: scheme.outline),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              GroupInitialTile(name: group.name, index: index),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(group.name, style: textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.xs),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.xs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        MemberAvatarStack(
                          members: group.members,
                          maxVisible: _maxAvatars,
                        ),
                        Text(
                          membersLabel(group.members.length),
                          style: mutedText,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        ExcludeSemantics(
                          child: Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            createdLabel(group.createdAt),
                            style: mutedText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              ExcludeSemantics(
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "1 member" or "N members".
String membersLabel(int count) => count == 1 ? '1 member' : '$count members';

/// "Created Oct 12", in the device's time zone (the year is not shown).
String createdLabel(DateTime createdAt) =>
    'Created ${formatMonthDay(createdAt)}';
