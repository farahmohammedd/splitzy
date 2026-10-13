import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitzy/core/money/money_format.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/core/widgets/member_avatar.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/domain/money/equal_split.dart';
import 'package:splitzy/features/expenses/domain/validation/expense_validation.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';

/// What the Add Expense form submits: amounts in piastres, and with
/// [SplitType.custom] every member's share by member id.
typedef ExpenseInput = ({
  Group group,
  String description,
  int amount,
  String paidBy,
  SplitType splitType,
  Map<String, int> customShares,
});

/// The Add Expense form, as in the design reference: the group, what it was
/// for, the amount, who paid, and how it is split (equally, with the shares
/// shown, or by custom amounts entered per member).
///
/// Presentation only: the input is checked against the domain validation
/// rules, then [onSave] receives it. [groups] is `null` while loading; with
/// no groups the screen asks for one to be created first.
class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({
    super.key,
    required this.groups,
    required this.ownerId,
    required this.onBack,
    required this.onNewGroup,
    required this.onSave,
    this.initialGroupId,
    this.groupsErrorMessage,
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// The user's groups, newest first; `null` while loading.
  final List<Group>? groups;

  /// A failed load of [groups].
  final String? groupsErrorMessage;

  /// The signed-in user's id, which is also their member id ("You").
  final String ownerId;

  /// The group selected at first; the newest group when `null` or unknown.
  final String? initialGroupId;

  final VoidCallback onBack;
  final VoidCallback onNewGroup;
  final ValueChanged<ExpenseInput> onSave;

  /// Shows the Save button's loading state and ignores further submits.
  final bool isSubmitting;

  /// A failed save attempt, shown above the Save button.
  final String? errorMessage;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  /// The decorative circle's diameter, as a fraction of the screen width,
  /// clamped for very narrow and very wide screens.
  static const double _circleWidthFraction = 0.55;
  static const double _circleMinDiameter = 180;
  static const double _circleMaxDiameter = 320;
  static const double _circleOpacity = 0.6;

  /// The Save button's progress indicator, about the size of its text.
  static const double _progressSize = 18;

  final _formKey = GlobalKey<FormState>();
  final _description = TextEditingController();
  final _amount = TextEditingController();

  /// Custom share fields by member id, created as members are shown.
  final _shareFields = <String, TextEditingController>{};

  String? _groupId;
  String? _paidBy;
  var _splitType = SplitType.equal;

  /// A problem with the custom shares as a whole.
  String? _sharesError;

  /// Fields re-check as the user types only after a submit was rejected.
  var _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    for (final field in _shareFields.values) {
      field.dispose();
    }
    super.dispose();
  }

  /// The selected group: the chosen one while it exists, otherwise the
  /// initial group, otherwise the newest.
  Group? _selectedGroup(List<Group> groups) {
    for (final id in [_groupId, widget.initialGroupId]) {
      for (final group in groups) {
        if (group.id == id) return group;
      }
    }
    return groups.isEmpty ? null : groups.first;
  }

  /// Who paid: the chosen member while they are in [group], otherwise the
  /// user, otherwise the first member.
  String _payer(Group group) {
    final ids = [for (final member in group.members) member.id];
    for (final id in [_paidBy, widget.ownerId]) {
      if (ids.contains(id)) return id ?? '';
    }
    return ids.isEmpty ? '' : ids.first;
  }

  TextEditingController _shareField(String memberId) =>
      _shareFields.putIfAbsent(memberId, TextEditingController.new);

  /// A custom share in piastres; an empty field counts as zero.
  int? _shareOf(String memberId) {
    final text = _shareField(memberId).text;
    return text.trim().isEmpty ? 0 : ExpenseValidation.parseAmount(text);
  }

  void _selectGroup(String? id) {
    if (id == null || id == _groupId) return;
    setState(() {
      _groupId = id;
      _paidBy = null;
      _sharesError = null;
      for (final field in _shareFields.values) {
        field.clear();
      }
    });
  }

  void _submit(Group group) {
    if (widget.isSubmitting) return;
    final fieldsValid = _formKey.currentState?.validate() ?? false;
    final amount = ExpenseValidation.parseAmount(_amount.text);
    final memberIds = [for (final member in group.members) member.id];

    String? sharesError;
    final customShares = <String, int>{};
    if (_splitType == SplitType.custom && amount != null) {
      for (final id in memberIds) {
        customShares[id] = _shareOf(id) ?? -1;
      }
      // Unreadable fields show their own errors (see _SharesCard).
      if (!customShares.values.contains(-1)) {
        sharesError = ExpenseValidation.customShares(
          customShares,
          amount,
          memberIds,
        )?.message;
      }
    }
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      _sharesError = sharesError;
    });
    if (!fieldsValid || amount == null || sharesError != null) return;

    widget.onSave((
      group: group,
      description: _description.text.trim(),
      amount: amount,
      paidBy: _payer(group),
      splitType: _splitType,
      customShares: customShares,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final circleColor = theme.colorScheme.secondaryContainer.withValues(
      alpha: _circleOpacity,
    );
    final groups = widget.groups;
    final groupsError = widget.groupsErrorMessage;
    final group = groups == null ? null : _selectedGroup(groups);

    final Widget body;
    if (groupsError != null) {
      body = _Message(icon: Icons.error_outline_rounded, title: groupsError);
    } else if (groups == null) {
      body = const Center(child: CircularProgressIndicator());
    } else if (group == null) {
      body = _Message(
        icon: Icons.group_outlined,
        title: 'Create a group first',
        subtitle: 'Expenses are shared within a group.',
        action: FilledButton.icon(
          onPressed: widget.onNewGroup,
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, kMinInteractiveDimension),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New Group'),
        ),
      );
    } else {
      body = _form(context, groups, group);
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
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        0,
                      ),
                      child: _ContentWidth(
                        child: _Header(onBack: widget.onBack),
                      ),
                    ),
                    Expanded(child: body),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// The scrolling form and the Save button below it.
  Widget _form(BuildContext context, List<Group> groups, Group group) {
    final textTheme = Theme.of(context).textTheme;
    final errorMessage = widget.errorMessage;
    final sharesError = _sharesError;
    final paidBy = _payer(group);
    final amount = ExpenseValidation.parseAmount(_amount.text);
    final validAmount =
        amount != null && ExpenseValidation.amount(amount) == null;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: _ContentWidth(
              child: Form(
                key: _formKey,
                autovalidateMode: _autovalidateMode,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('Group', style: textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.sm),
                    DropdownButtonFormField<String>(
                      key: ValueKey(group.id),
                      initialValue: group.id,
                      isExpanded: true,
                      onChanged: _selectGroup,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.group_outlined),
                      ),
                      items: [
                        for (final option in groups)
                          DropdownMenuItem(
                            value: option.id,
                            child: Text(
                              option.name,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('What was it for?', style: textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _description,
                      validator: (value) =>
                          ExpenseValidation.description(value ?? '')?.message,
                      textCapitalization: TextCapitalization.sentences,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Dinner',
                        prefixIcon: Icon(Icons.edit_outlined),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Amount (EGP)', style: textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.sm),
                    TextFormField(
                      controller: _amount,
                      validator: (value) =>
                          ExpenseValidation.amountText(value ?? '')?.message,
                      onChanged: (_) => setState(() {}),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textInputAction: TextInputAction.done,
                      style: textTheme.titleLarge,
                      decoration: const InputDecoration(
                        hintText: '0.00',
                        prefixText: 'EGP  ',
                        errorMaxLines: 3,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Paid by', style: textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.sm),
                    _PayerChips(
                      members: group.members,
                      ownerId: widget.ownerId,
                      selectedId: paidBy,
                      onSelected: (id) => setState(() => _paidBy = id),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text('Split', style: textTheme.titleSmall),
                    const SizedBox(height: AppSpacing.sm),
                    SegmentedButton<SplitType>(
                      segments: const [
                        ButtonSegment(
                          value: SplitType.equal,
                          label: Text('Equally'),
                        ),
                        ButtonSegment(
                          value: SplitType.custom,
                          label: Text('Custom'),
                        ),
                      ],
                      selected: {_splitType},
                      showSelectedIcon: false,
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor:
                            context.brandColors.primaryDark,
                        selectedForegroundColor: Theme.of(
                          context,
                        ).colorScheme.onPrimary,
                      ),
                      onSelectionChanged: (selection) => setState(() {
                        _splitType = selection.first;
                        _sharesError = null;
                      }),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    _SharesCard(
                      members: group.members,
                      ownerId: widget.ownerId,
                      equalShares: _splitType == SplitType.equal
                          ? (validAmount
                                ? splitEqually(amount, [
                                    for (final member in group.members)
                                      member.id,
                                  ])
                                : const {})
                          : null,
                      shareField: _shareField,
                      onShareChanged: () => setState(() => _sharesError = null),
                    ),
                    if (_splitType == SplitType.custom) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _CustomTotal(
                        total: [
                          for (final member in group.members)
                            _shareOf(member.id) ?? 0,
                        ].fold(0, (sum, share) => sum + share),
                        amount: validAmount ? amount : null,
                      ),
                    ],
                    if (sharesError != null) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _ErrorText(sharesError),
                    ],
                  ],
                ),
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
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (errorMessage != null) ...[
                  _ErrorText(errorMessage),
                  const SizedBox(height: AppSpacing.sm),
                ],
                // No arrow, unlike PrimaryArrowButton (as in the design
                // reference). While saving it is disabled and shows progress.
                FilledButton(
                  onPressed: widget.isSubmitting ? null : () => _submit(group),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Flexible(
                        child: Text(
                          'Save Expense',
                          textAlign: TextAlign.center,
                        ),
                      ),
                      if (widget.isSubmitting) ...[
                        const SizedBox(width: AppSpacing.sm),
                        const SizedBox.square(
                          dimension: _progressSize,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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

/// The round Back button and the screen title.
class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

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
          child: Text(
            'Add Expense',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ],
    );
  }
}

/// One chip per member; exactly one, the payer, is selected.
class _PayerChips extends StatelessWidget {
  const _PayerChips({
    required this.members,
    required this.ownerId,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Member> members;
  final String ownerId;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        for (final (i, member) in members.indexed)
          ChoiceChip(
            label: Text(_displayName(member, ownerId)),
            avatar: MemberAvatar(
              name: member.name,
              index: i - 1,
              isOwner: member.id == ownerId,
              radius: 12,
            ),
            selected: member.id == selectedId,
            onSelected: (_) => onSelected(member.id),
            showCheckmark: false,
            backgroundColor: scheme.surface,
            selectedColor: scheme.secondaryContainer,
            side: BorderSide(
              color: member.id == selectedId
                  ? context.brandColors.primaryDark
                  : scheme.outline,
            ),
            shape: const StadiumBorder(),
          ),
      ],
    );
  }
}

/// Every member's share: the calculated amounts when splitting equally
/// ([equalShares], empty until the amount is valid), otherwise a field per
/// member.
class _SharesCard extends StatelessWidget {
  const _SharesCard({
    required this.members,
    required this.ownerId,
    required this.equalShares,
    required this.shareField,
    required this.onShareChanged,
  });

  /// Width of each custom share field.
  static const double _fieldWidth = 128;

  final List<Member> members;
  final String ownerId;

  /// `null` for a custom split.
  final Map<String, int>? equalShares;
  final TextEditingController Function(String memberId) shareField;
  final VoidCallback onShareChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final equalShares = this.equalShares;
    final amountStyle = theme.textTheme.titleSmall?.copyWith(
      color: context.brandColors.primaryDark,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: scheme.outline),
      ),
      child: Column(
        children: [
          for (final (i, member) in members.indexed) ...[
            if (i > 0)
              const Divider(height: 1, indent: AppSpacing.xxl + AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  MemberAvatar(
                    name: member.name,
                    index: i - 1,
                    isOwner: member.id == ownerId,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      _displayName(member, ownerId),
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  if (equalShares != null)
                    Text(switch (equalShares[member.id]) {
                      final share? => formatEgp(share),
                      null => '—',
                    }, style: amountStyle)
                  else
                    SizedBox(
                      width: _fieldWidth,
                      child: TextFormField(
                        key: ValueKey('share-${member.id}'),
                        controller: shareField(member.id),
                        onChanged: (_) => onShareChanged(),
                        validator: (value) {
                          final text = value ?? '';
                          if (text.trim().isEmpty) return null;
                          return ExpenseValidation.parseAmount(text) == null
                              ? ExpenseValidationError.amountInvalid.message
                              : null;
                        },
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.end,
                        // The member's name is read just before the field.
                        decoration: const InputDecoration(
                          hintText: '0',
                          prefixText: 'EGP ',
                          isDense: true,
                          errorMaxLines: 4,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.sm,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// "Total: EGP 550 of EGP 600": how much of the amount the custom shares
/// cover. Highlighted when they do not match.
class _CustomTotal extends StatelessWidget {
  const _CustomTotal({required this.total, required this.amount});

  final int total;

  /// `null` until a valid amount is entered.
  final int? amount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final amount = this.amount;
    final matches = amount != null && total == amount;

    return Text(
      amount == null
          ? 'Total: ${formatEgp(total)}'
          : 'Total: ${formatEgp(total)} of ${formatEgp(amount)}',
      textAlign: TextAlign.end,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: matches ? context.brandColors.success : null,
      ),
    );
  }
}

/// A centered icon, title, optional subtitle and optional action: the
/// loading-failed and no-groups states.
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

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: _ContentWidth(
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            ExcludeSemantics(
              child: Icon(icon, size: 48, color: scheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: AppSpacing.lg),
              action,
            ],
          ],
        ),
      ),
    );
  }
}

/// An error for the whole form, announced to screen readers when it appears.
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
