import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';
import 'package:splitzy/core/theme/app_spacing.dart';

/// The quick actions under the balance card: Add Expense and New Group.
class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    required this.onAddExpense,
    required this.onNewGroup,
  });

  final VoidCallback onAddExpense;
  final VoidCallback onNewGroup;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _QuickAction(
            icon: Icons.receipt_long_outlined,
            label: 'Add Expense',
            onTap: onAddExpense,
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: _QuickAction(
            icon: Icons.group_add_outlined,
            label: 'New Group',
            onTap: onNewGroup,
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  static const double _tileSize = 56;

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: _tileSize,
                height: _tileSize,
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: scheme.outline),
                ),
                child: Icon(icon, color: context.brandColors.primaryDark),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: scheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
