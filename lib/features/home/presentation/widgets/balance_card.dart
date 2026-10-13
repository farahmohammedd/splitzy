import 'package:flutter/material.dart';
import 'package:splitzy/core/money/money_format.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';
import 'package:splitzy/core/theme/app_spacing.dart';

/// The user's position across all their groups, in piastres: what they are
/// owed and what they owe (both positive).
typedef HomeBalance = ({int owed, int owe});

/// The total-balance card on Home, as in the design reference: the overall
/// balance with a line about it, then what the user is owed and owes.
///
/// [balance] is `null` when there are no expenses yet. While [isLoading] it
/// shows progress; when [loadFailed] it says the balance could not be
/// loaded.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    this.balance,
    this.isLoading = false,
    this.loadFailed = false,
  });

  static const double _coinSize = 44;

  /// Opacity of the secondary text on the dark card.
  static const double _secondaryTextOpacity = 0.8;

  final HomeBalance? balance;
  final bool isLoading;
  final bool loadFailed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onCard = scheme.onPrimary;
    final secondaryText = theme.textTheme.bodyMedium?.copyWith(
      color: onCard.withValues(alpha: _secondaryTextOpacity),
    );
    final headline = theme.textTheme.headlineSmall?.copyWith(color: onCard);
    final balance = this.balance;

    final List<Widget> content;
    if (isLoading) {
      content = [
        const SizedBox(height: AppSpacing.sm),
        SizedBox.square(
          dimension: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: onCard),
        ),
      ];
    } else if (loadFailed) {
      content = [
        const SizedBox(height: AppSpacing.sm),
        Text("Couldn't load your balance.", style: headline),
      ];
    } else if (balance == null) {
      content = [
        const SizedBox(height: AppSpacing.sm),
        Text('No expenses yet', style: headline),
        const SizedBox(height: AppSpacing.xs),
        Text('Add an expense to see who owes whom.', style: secondaryText),
      ];
    } else {
      final total = balance.owed - balance.owe;
      content = [
        const SizedBox(height: AppSpacing.sm),
        Text(
          switch (total) {
            > 0 => '+ ${formatEgp(total)}',
            < 0 => '- ${formatEgp(-total)}',
            _ => formatEgp(0),
          },
          style: theme.textTheme.headlineMedium?.copyWith(
            color: onCard,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(switch (total) {
          > 0 => "You're all good — friends owe you more 🎉",
          < 0 => "You owe a bit more than you're owed.",
          _ => "You're all settled.",
        }, style: secondaryText),
      ];
    }

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Total balance', style: secondaryText),
                      ...content,
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
            if (balance != null && !isLoading && !loadFailed) ...[
              const SizedBox(height: AppSpacing.md),
              _OwedBoxes(balance: balance, labelStyle: secondaryText),
            ],
          ],
        ),
      ),
    );
  }
}

/// "You are owed" and "You owe", side by side and equally wide, or one
/// above the other when they would be too narrow.
class _OwedBoxes extends StatelessWidget {
  const _OwedBoxes({required this.balance, required this.labelStyle});

  /// The narrowest a box gets before the two go one above the other.
  static const double _minBoxWidth = 120;

  final HomeBalance balance;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final owed = _OwedBox(
          icon: Icons.check_rounded,
          label: 'You are owed',
          amount: balance.owed,
          labelStyle: labelStyle,
        );
        final owe = _OwedBox(
          icon: Icons.north_east_rounded,
          label: 'You owe',
          amount: balance.owe,
          labelStyle: labelStyle,
        );
        if (constraints.maxWidth < _minBoxWidth * 2 + AppSpacing.md) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              owed,
              const SizedBox(height: AppSpacing.sm),
              owe,
            ],
          );
        }
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: owed),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: owe),
            ],
          ),
        );
      },
    );
  }
}

class _OwedBox extends StatelessWidget {
  const _OwedBox({
    required this.icon,
    required this.label,
    required this.amount,
    required this.labelStyle,
  });

  /// Opacity of the light box and its icon circle on the dark card.
  static const double _boxOpacity = 0.12;
  static const double _iconCircleOpacity = 0.2;
  static const double _iconCircleSize = 28;

  final IconData icon;
  final String label;
  final int amount;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onCard = theme.colorScheme.onPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: onCard.withValues(alpha: _boxOpacity),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Container(
                width: _iconCircleSize,
                height: _iconCircleSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: onCard.withValues(alpha: _iconCircleOpacity),
                ),
                child: Icon(icon, size: 16, color: onCard),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: labelStyle),
                  Text(
                    formatEgp(amount),
                    style: theme.textTheme.titleSmall?.copyWith(color: onCard),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
