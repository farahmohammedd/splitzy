import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitzy/core/format/date_format.dart';
import 'package:splitzy/core/money/money_format.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/core/widgets/member_avatar.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/domain/money/balances.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';

/// A group's page, as in the design reference: its name and member count,
/// a card with the group's total, the user's share and balance, every
/// member's balance, the expenses (newest first) and an Add Expense button.
///
/// Presentation only: [expenses] is `null` while loading and
/// [expensesErrorMessage] is a failed load. Amounts are worked out with the
/// domain's balance functions. Tapping a member or an expense does nothing
/// yet.
class GroupDetailsScreen extends StatelessWidget {
  const GroupDetailsScreen({
    super.key,
    required this.group,
    required this.ownerId,
    required this.expenses,
    required this.onBack,
    required this.onAddExpense,
    this.expensesErrorMessage,
  });

  /// The decorative circle's diameter, as a fraction of the screen width,
  /// clamped for very narrow and very wide screens.
  static const double _circleWidthFraction = 0.55;
  static const double _circleMinDiameter = 180;
  static const double _circleMaxDiameter = 320;
  static const double _circleOpacity = 0.6;

  final Group group;

  /// The signed-in user's id, which is also their member id ("You").
  final String ownerId;

  /// The group's expenses, newest first; `null` while loading.
  final List<Expense>? expenses;
  final String? expensesErrorMessage;
  final VoidCallback onBack;
  final VoidCallback onAddExpense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final circleColor = theme.colorScheme.secondaryContainer.withValues(
      alpha: _circleOpacity,
    );
    final errorMessage = expensesErrorMessage;
    // Amounts are unknown while loading or after a failed load.
    final expenses = errorMessage == null ? this.expenses : null;
    final memberIds = [for (final member in group.members) member.id];
    final balances = expenses == null ? null : balancesOf(expenses, memberIds);

    final Widget expensesContent;
    if (errorMessage != null) {
      expensesContent = _ErrorText(errorMessage);
    } else if (expenses == null) {
      expensesContent = const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (expenses.isEmpty) {
      expensesContent = const _NoExpenses();
    } else {
      expensesContent = _ExpenseList(
        expenses: expenses,
        members: group.members,
        ownerId: ownerId,
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
              // Soft sage circle at the top-right corner, as in the design
              // reference. Decorative only.
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
                        color: circleColor,
                      ),
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: _ContentWidth(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _Header(group: group, onBack: onBack),
                              const SizedBox(height: AppSpacing.lg),
                              _SummaryCard(
                                total: expenses == null
                                    ? null
                                    : totalAmount(expenses),
                                yourShare: expenses == null
                                    ? null
                                    : shareOf(expenses, ownerId),
                                yourBalance: balances?[ownerId],
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Text('Members', style: textTheme.titleLarge),
                              const SizedBox(height: AppSpacing.sm),
                              _MemberBalances(
                                members: group.members,
                                ownerId: ownerId,
                                balances: balances,
                              ),
                              const SizedBox(height: AppSpacing.xl),
                              Text('Expenses', style: textTheme.titleLarge),
                              const SizedBox(height: AppSpacing.sm),
                              expensesContent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.sm,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: _ContentWidth(
                        child: FilledButton.icon(
                          onPressed: onAddExpense,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Expense'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// "You" for the user, otherwise the member's name.
String _displayName(Member member, String ownerId) =>
    member.id == ownerId ? 'You' : member.name;

/// Centers [child] and caps its width on wide screens.
class _ContentWidth extends StatelessWidget {
  const _ContentWidth({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: AppSizes.maxContentWidth),
        child: child,
      ),
    );
  }
}

/// The round Back button, the group's name and how many members it has.
class _Header extends StatelessWidget {
  const _Header({required this.group, required this.onBack});

  final Group group;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final count = group.members.length;

    return Row(
      children: [
        IconButton(
          onPressed: onBack,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          style: IconButton.styleFrom(
            backgroundColor: scheme.surface,
            side: BorderSide(color: scheme.outline),
          ),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(group.name, style: theme.textTheme.headlineMedium),
              Text(
                count == 1 ? '1 member' : '$count members',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// The dark card: the group's total, the user's share and what they get
/// back or owe. Amounts show "—" while unknown.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.yourShare,
    required this.yourBalance,
  });

  /// Opacity of the secondary text on the dark card.
  static const double _secondaryTextOpacity = 0.8;

  /// Opacity of the light boxes inside the card.
  static const double _boxOpacity = 0.12;

  /// The narrowest a box gets before the two go one above the other.
  static const double _minBoxWidth = 120;

  final int? total;
  final int? yourShare;
  final int? yourBalance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onCard = scheme.onPrimary;
    final secondaryText = theme.textTheme.bodyMedium?.copyWith(
      color: onCard.withValues(alpha: _secondaryTextOpacity),
    );
    final total = this.total;
    final yourShare = this.yourShare;
    final yourBalance = this.yourBalance;

    final (balanceLabel, balanceValue) = switch (yourBalance) {
      null => ('Your balance', '—'),
      0 => ('Your balance', "You're all settled"),
      > 0 => ('You get back', formatEgp(yourBalance)),
      _ => ('You owe', formatEgp(-yourBalance)),
    };

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
            Text('Total group expenses', style: secondaryText),
            const SizedBox(height: AppSpacing.xs),
            Text(
              total == null ? '—' : formatEgp(total),
              style: theme.textTheme.headlineLarge?.copyWith(
                color: onCard,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Side by side and equally wide, or one above the other when
            // they would be too narrow.
            LayoutBuilder(
              builder: (context, constraints) {
                final share = _SummaryBox(
                  label: 'Your share',
                  value: yourShare == null ? '—' : formatEgp(yourShare),
                  opacity: _boxOpacity,
                  labelStyle: secondaryText,
                );
                final balance = _SummaryBox(
                  label: balanceLabel,
                  value: balanceValue,
                  opacity: _boxOpacity,
                  labelStyle: secondaryText,
                );
                if (constraints.maxWidth < _minBoxWidth * 2 + AppSpacing.md) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      share,
                      const SizedBox(height: AppSpacing.md),
                      balance,
                    ],
                  );
                }
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: share),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: balance),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryBox extends StatelessWidget {
  const _SummaryBox({
    required this.label,
    required this.value,
    required this.opacity,
    required this.labelStyle,
  });

  final String label;
  final String value;
  final double opacity;
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onCard = theme.colorScheme.onPrimary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: onCard.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: labelStyle),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(color: onCard),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card per member with their balance, in a row that scrolls sideways
/// when the members do not fit.
class _MemberBalances extends StatelessWidget {
  const _MemberBalances({
    required this.members,
    required this.ownerId,
    required this.balances,
  });

  /// Card width, measured from the design reference (four cards fit a
  /// phone).
  static const double _cardWidth = 84;

  final List<Member> members;
  final String ownerId;

  /// `null` while unknown.
  final Map<String, int>? balances;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final balances = this.balances;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final (i, member) in members.indexed) ...[
              if (i > 0) const SizedBox(width: AppSpacing.sm),
              Container(
                width: _cardWidth,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: scheme.surface,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: scheme.outline),
                ),
                child: Column(
                  children: [
                    MemberAvatar(
                      name: member.name,
                      index: i - 1,
                      isOwner: member.id == ownerId,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _displayName(member, ownerId),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _BalanceText(balance: balances?[member.id]),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "+ 1,000" in green when owed, "- 120" in red when owing, "0" when
/// settled, "—" while unknown.
class _BalanceText extends StatelessWidget {
  const _BalanceText({required this.balance});

  final int? balance;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final balance = this.balance;
    final color = switch (balance) {
      final b? when b > 0 => context.brandColors.success,
      final b? when b < 0 => theme.colorScheme.error,
      _ => theme.colorScheme.onSurfaceVariant,
    };

    return Text(
      balance == null ? '—' : formatBalance(balance),
      textAlign: TextAlign.center,
      style: theme.textTheme.titleSmall?.copyWith(color: color),
    );
  }
}

/// The expenses in one card, newest first.
class _ExpenseList extends StatelessWidget {
  const _ExpenseList({
    required this.expenses,
    required this.members,
    required this.ownerId,
  });

  final List<Expense> expenses;
  final List<Member> members;
  final String ownerId;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        children: [
          for (final (i, expense) in expenses.indexed) ...[
            if (i > 0)
              const Divider(height: 1, indent: AppSpacing.xxl + AppSpacing.lg),
            _ExpenseRow(
              expense: expense,
              index: i,
              payer: _payerName(expense.paidBy),
            ),
          ],
        ],
      ),
    );
  }

  /// "you" for the user, otherwise the paying member's name.
  String _payerName(String memberId) {
    if (memberId == ownerId) return 'you';
    for (final member in members) {
      if (member.id == memberId) return member.name;
    }
    return 'someone';
  }
}

class _ExpenseRow extends StatelessWidget {
  const _ExpenseRow({
    required this.expense,
    required this.index,
    required this.payer,
  });

  static const double _iconTileSize = 44;

  final Expense expense;

  /// The expense's position in the list; picks the icon's colors.
  final int index;
  final String payer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final (background, foreground) = MemberAvatar.colorsFor(
      theme.colorScheme,
      index,
    );

    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // One icon for every expense (no categories are stored).
          ExcludeSemantics(
            child: Container(
              width: _iconTileSize,
              height: _iconTileSize,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(Icons.receipt_long_outlined, color: foreground),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(expense.description, style: textTheme.titleSmall),
                Text('Paid by $payer', style: textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          // Shares the row with the description, wrapping on narrow screens
          // with large text instead of overflowing; kept at the row's end.
          Flexible(
            child: Align(
              alignment: Alignment.centerRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatEgp(expense.amount),
                    textAlign: TextAlign.end,
                    style: textTheme.titleSmall,
                  ),
                  Text(
                    formatMonthDay(expense.createdAt),
                    textAlign: TextAlign.end,
                    style: textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The expenses' empty state.
class _NoExpenses extends StatelessWidget {
  const _NoExpenses();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outline),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            ExcludeSemantics(
              child: Icon(
                Icons.receipt_long_outlined,
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No expenses yet', style: theme.textTheme.titleSmall),
                  Text(
                    'Add the first one to see who owes whom.',
                    style: theme.textTheme.bodyMedium,
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

/// A failed load, announced to screen readers when it appears.
class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      liveRegion: true,
      child: Text(
        message,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }
}
