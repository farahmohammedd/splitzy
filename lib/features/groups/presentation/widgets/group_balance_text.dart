import 'package:flutter/material.dart';
import 'package:splitzy/core/money/money_format.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';

/// The user's balance in one group, in piastres, and whether the group has
/// any expenses. Worked out by the app root from the expenses feature.
typedef GroupBalance = ({int amount, bool hasExpenses});

/// A group card's line about the user's balance in the group, as in the
/// design reference: "You get EGP 420" in green, "You owe EGP 150" in red,
/// otherwise "Settled" or "No expenses yet". Nothing while [balance] is
/// unknown.
class GroupBalanceText extends StatelessWidget {
  const GroupBalanceText({super.key, required this.balance, this.style});

  final GroupBalance? balance;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final balance = this.balance;
    if (balance == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final (text, color) = switch (balance) {
      (hasExpenses: false, amount: _) => ('No expenses yet', muted),
      (amount: > 0, hasExpenses: _) => (
        'You get ${formatEgp(balance.amount)}',
        context.brandColors.success,
      ),
      (amount: < 0, hasExpenses: _) => (
        'You owe ${formatEgp(-balance.amount)}',
        theme.colorScheme.error,
      ),
      _ => ('Settled', muted),
    };

    return Text(
      text,
      style: (style ?? theme.textTheme.titleSmall)?.copyWith(color: color),
    );
  }
}
