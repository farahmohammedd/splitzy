import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';
import 'package:splitzy/core/theme/app_spacing.dart';

/// The total-balance card on Home, in its empty state: there are no expenses
/// yet, so it shows no amounts. The owed / owe figures arrive with balances.
class BalanceCard extends StatelessWidget {
  const BalanceCard({super.key});

  static const double _coinSize = 44;

  /// Opacity of the secondary text on the dark card.
  static const double _secondaryTextOpacity = 0.8;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onCard = scheme.onPrimary;
    final secondaryText = theme.textTheme.bodyMedium?.copyWith(
      color: onCard.withValues(alpha: _secondaryTextOpacity),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [context.brandColors.primaryDark, scheme.primary],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total balance', style: secondaryText),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'No expenses yet',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: onCard,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    'Add an expense to see who owes whom.',
                    style: secondaryText,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Decorative gold coin, as in the design reference.
            ExcludeSemantics(
              child: Container(
                width: _coinSize,
                height: _coinSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: scheme.tertiary,
                ),
                child: Icon(
                  Icons.attach_money_rounded,
                  color: scheme.onTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
