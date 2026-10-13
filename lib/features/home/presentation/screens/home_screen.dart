import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/features/home/presentation/widgets/balance_card.dart';
import 'package:splitzy/features/home/presentation/widgets/home_header.dart';
import 'package:splitzy/features/home/presentation/widgets/home_section.dart';
import 'package:splitzy/features/home/presentation/widgets/quick_actions.dart';

/// The signed-in home screen: greeting, total balance, quick actions, the
/// user's groups and recent activity (empty until that feature exists).
///
/// Presentation only: [name], the balance and the groups content come from
/// the caller and every action is reported through a callback. Log out lives
/// on the Profile tab.
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.name,
    required this.onAddExpense,
    required this.onNewGroup,
    this.groups,
    this.onSeeAllGroups,
    this.balance,
    this.balanceLoading = false,
    this.balanceFailed = false,
  });

  /// The decorative circle's diameter, as a fraction of the screen width,
  /// clamped for very narrow and very wide screens.
  static const double _circleWidthFraction = 0.55;
  static const double _circleMinDiameter = 180;
  static const double _circleMaxDiameter = 320;

  /// Opacity of the decorative circle.
  static const double _circleOpacity = 0.6;

  final String name;
  final VoidCallback onAddExpense;
  final VoidCallback onNewGroup;

  /// Shown under Your Groups; `null` shows its empty state.
  final Widget? groups;

  /// Shows See all next to Your Groups when set.
  final VoidCallback? onSeeAllGroups;

  /// The user's balance across groups; `null` when there are no expenses.
  final HomeBalance? balance;

  /// The balance is still loading.
  final bool balanceLoading;

  /// The balance could not be loaded.
  final bool balanceFailed;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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

          return SingleChildScrollView(
            child: Stack(
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
                      child: Padding(
                        // Extra bottom room so the docked Add button never
                        // covers the last section.
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.lg,
                          AppSpacing.xxl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            HomeHeader(name: name),
                            const SizedBox(height: AppSpacing.lg),
                            BalanceCard(
                              balance: balance,
                              isLoading: balanceLoading,
                              loadFailed: balanceFailed,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            QuickActions(
                              onAddExpense: onAddExpense,
                              onNewGroup: onNewGroup,
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            HomeSection(
                              title: 'Your Groups',
                              emptyIcon: Icons.group_outlined,
                              emptyMessage: 'No groups yet',
                              onSeeAll: onSeeAllGroups,
                              child: groups,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            const HomeSection(
                              title: 'Recent Activity',
                              emptyIcon: Icons.receipt_long_outlined,
                              emptyMessage: 'No activity yet',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
