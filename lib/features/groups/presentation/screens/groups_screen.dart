import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/presentation/widgets/group_balance_text.dart';
import 'package:splitzy/features/groups/presentation/widgets/group_list_card.dart';

/// The Groups tab: a title with the number of groups and a New Group button,
/// then the user's groups, newest first, as in the design reference.
///
/// Presentation only: [groups] is `null` while loading, [errorMessage] is a
/// failed load, and every action is reported through a callback.
class GroupsScreen extends StatelessWidget {
  const GroupsScreen({
    super.key,
    required this.groups,
    required this.onNewGroup,
    required this.onOpenGroup,
    required this.onRetry,
    this.errorMessage,
    this.balances = const {},
  });

  /// The decorative circle's diameter, as a fraction of the screen width,
  /// clamped for very narrow and very wide screens.
  static const double _circleWidthFraction = 0.55;
  static const double _circleMinDiameter = 180;
  static const double _circleMaxDiameter = 320;
  static const double _circleOpacity = 0.6;

  final List<Group>? groups;
  final String? errorMessage;

  /// The user's balance in each group, by group id; groups missing from
  /// it show no balance (e.g. still loading).
  final Map<String, GroupBalance> balances;
  final VoidCallback onNewGroup;

  /// Opens a group's page.
  final ValueChanged<Group> onOpenGroup;

  /// Loads the groups again after a failure.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final groups = this.groups;
    final errorMessage = this.errorMessage;

    // Only one state shows below the header.
    final Widget body;
    if (errorMessage != null) {
      body = SliverFillRemaining(
        hasScrollBody: false,
        child: _Message(
          icon: Icons.error_outline_rounded,
          title: errorMessage,
          action: OutlinedButton(
            onPressed: onRetry,
            child: const Text('Try again'),
          ),
        ),
      );
    } else if (groups == null) {
      body = const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (groups.isEmpty) {
      body = const SliverFillRemaining(
        hasScrollBody: false,
        child: _Message(
          icon: Icons.group_outlined,
          title: 'No groups yet',
          subtitle: 'Create a group to start splitting expenses.',
        ),
      );
    } else {
      body = SliverList.separated(
        itemCount: groups.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (_, i) => GroupListCard(
          group: groups[i],
          index: i,
          balance: balances[groups[i].id],
          onTap: () => onOpenGroup(groups[i]),
        ),
      );
    }

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final circle = math.min(
            math.max(
              constraints.maxWidth * _circleWidthFraction,
              _circleMinDiameter,
            ),
            _circleMaxDiameter,
          );

          return Stack(
            children: [
              // Soft sage circle peeking in at the top-right corner, as in
              // the design reference. Decorative only.
              Positioned(
                top: -circle * 0.35,
                right: -circle * 0.35,
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: Container(
                      width: circle,
                      height: circle,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: scheme.secondaryContainer.withValues(
                          alpha: _circleOpacity,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                bottom: false,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: AppSizes.maxContentWidth,
                    ),
                    child: CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.lg,
                            AppSpacing.lg,
                          ),
                          sliver: SliverToBoxAdapter(
                            child: _Header(
                              count: errorMessage == null
                                  ? groups?.length
                                  : null,
                              onNewGroup: onNewGroup,
                            ),
                          ),
                        ),
                        SliverPadding(
                          // Extra bottom room so the docked Add button never
                          // covers the last group.
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.lg,
                            0,
                            AppSpacing.lg,
                            AppSpacing.xxl,
                          ),
                          sliver: body,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// "Groups", the number of groups once known, and New Group. They wrap onto
/// two lines when there is not enough room side by side.
class _Header extends StatelessWidget {
  const _Header({required this.count, required this.onNewGroup});

  final int? count;
  final VoidCallback onNewGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = this.count;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Groups',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            if (count != null)
              Text(
                count == 1 ? '1 group' : '$count groups',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        FilledButton.icon(
          onPressed: onNewGroup,
          // A compact pill beside the title, unlike the theme's full-width
          // buttons (as in the design reference).
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, kMinInteractiveDimension),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Group'),
        ),
      ],
    );
  }
}

/// A centered icon, title, optional subtitle and optional action: the empty
/// and error states.
class _Message extends StatelessWidget {
  const _Message({
    required this.icon,
    required this.title,
    this.subtitle,
    this.action,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final subtitle = this.subtitle;
    final action = this.action;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: 48, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          if (subtitle != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: AppSpacing.md),
            action,
          ],
        ],
      ),
    );
  }
}
