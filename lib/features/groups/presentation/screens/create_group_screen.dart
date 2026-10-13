import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/core/widgets/member_avatar.dart';
import 'package:splitzy/core/widgets/primary_arrow_button.dart';
import 'package:splitzy/features/groups/domain/validation/group_validation.dart';

/// The Create Group form: a group name, then members added one by one from a
/// single field. The owner is a member automatically and is not listed.
///
/// Presentation only: the input is checked against the domain validation
/// rules, then [onCreate] receives the trimmed name and member names. The
/// caller reports progress and failures back through [isSubmitting] and
/// [errorMessage].
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({
    super.key,
    required this.ownerName,
    required this.onBack,
    required this.onCreate,
    this.isSubmitting = false,
    this.errorMessage,
  });

  /// The signed-in user's name; other members may not repeat it.
  final String ownerName;
  final VoidCallback onBack;

  /// Called with the trimmed group name and the other members' names, in the
  /// order they were added.
  final void Function(String name, List<String> memberNames) onCreate;

  /// Shows the Create Group button's loading state and ignores further
  /// submits.
  final bool isSubmitting;

  /// A failed create attempt, shown above the Create Group button.
  final String? errorMessage;

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  /// The decorative circles' diameter, as a fraction of the screen width,
  /// clamped for very narrow and very wide screens.
  static const double _circleWidthFraction = 0.55;
  static const double _circleMinDiameter = 180;
  static const double _circleMaxDiameter = 320;
  static const double _circleOpacity = 0.6;

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _memberInput = TextEditingController();
  final _memberFocus = FocusNode();
  final _members = <String>[];

  /// Why the name in the member field could not be added.
  String? _memberError;

  /// A problem with the member list as a whole (e.g. nobody added).
  String? _membersError;

  /// Fields re-check as the user types only after a submit was rejected.
  var _autovalidateMode = AutovalidateMode.disabled;

  @override
  void dispose() {
    _name.dispose();
    _memberInput.dispose();
    _memberFocus.dispose();
    super.dispose();
  }

  /// Adds the member field's name to the list. Returns whether the field is
  /// now empty (nothing typed, or the name was added).
  bool _addMember() {
    final candidate = _memberInput.text.trim();
    if (candidate.isEmpty) return true;

    final error = GroupValidation.members([
      widget.ownerName,
      ..._members,
      candidate,
    ]);
    setState(() {
      _memberError = error?.message;
      if (error == null) {
        _members.add(candidate);
        _memberInput.clear();
        _membersError = null;
      }
    });
    _memberFocus.requestFocus();
    return error == null;
  }

  void _removeMember(int index) {
    setState(() {
      _members.removeAt(index);
      _memberError = null;
    });
  }

  void _submit() {
    if (widget.isSubmitting) return;
    // A name still in the member field counts, so it is not silently lost.
    final memberAdded = _addMember();
    final nameValid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _autovalidateMode = AutovalidateMode.onUserInteraction;
      _membersError = _members.isEmpty
          ? GroupValidationError.tooFewMembers.message
          : null;
    });
    if (!memberAdded || !nameValid || _members.isEmpty) return;

    widget.onCreate(_name.text.trim(), List.unmodifiable(_members));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final circleColor = theme.colorScheme.secondaryContainer.withValues(
      alpha: _circleOpacity,
    );
    final errorMessage = widget.errorMessage;

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
              // Soft sage circles at the top-right and bottom-left corners,
              // as in the design reference. Decorative only.
              Positioned(
                top: -circle * 0.35,
                right: -circle * 0.35,
                child: _DecorativeCircle(size: circle, color: circleColor),
              ),
              Positioned(
                bottom: circle * 0.4,
                left: -circle * 0.55,
                child: _DecorativeCircle(
                  size: circle * 0.8,
                  color: circleColor,
                ),
              ),
              SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: _ContentWidth(
                          child: Form(
                            key: _formKey,
                            autovalidateMode: _autovalidateMode,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _Header(onBack: widget.onBack),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  "You're included automatically.",
                                  style: textTheme.bodyMedium,
                                ),
                                const SizedBox(height: AppSpacing.xl),
                                Text('Group name', style: textTheme.titleSmall),
                                const SizedBox(height: AppSpacing.sm),
                                TextFormField(
                                  controller: _name,
                                  validator: (value) =>
                                      GroupValidation.groupName(
                                        value ?? '',
                                      )?.message,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    hintText: 'e.g. Trip to Dahab',
                                    prefixIcon: Icon(Icons.group_outlined),
                                  ),
                                ),
                                const SizedBox(height: AppSpacing.lg),
                                _MembersHeader(count: _members.length),
                                const SizedBox(height: AppSpacing.sm),
                                _MemberInput(
                                  controller: _memberInput,
                                  focusNode: _memberFocus,
                                  errorText: _memberError,
                                  onAdd: _addMember,
                                ),
                                if (_members.isNotEmpty) ...[
                                  const SizedBox(height: AppSpacing.md),
                                  _MemberList(
                                    members: _members,
                                    onRemove: _removeMember,
                                  ),
                                ],
                                if (_membersError case final error?) ...[
                                  const SizedBox(height: AppSpacing.sm),
                                  _ErrorText(error),
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
                            PrimaryArrowButton(
                              label: 'Create Group',
                              onPressed: _submit,
                              isLoading: widget.isSubmitting,
                            ),
                          ],
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

class _DecorativeCircle extends StatelessWidget {
  const _DecorativeCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ExcludeSemantics(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
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
            'Create Group',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
      ],
    );
  }
}

/// "Members" and how many have been added.
class _MembersHeader extends StatelessWidget {
  const _MembersHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.sm,
      children: [
        Text('Members', style: textTheme.titleSmall),
        Text('$count added', style: textTheme.bodyMedium),
      ],
    );
  }
}

/// The single member-name field and its round Add button.
class _MemberInput extends StatelessWidget {
  const _MemberInput({
    required this.controller,
    required this.focusNode,
    required this.errorText,
    required this.onAdd,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String? errorText;
  final bool Function() onAdd;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            onSubmitted: (_) => onAdd(),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.name],
            decoration: InputDecoration(
              hintText: 'Enter member name',
              prefixIcon: const Icon(Icons.person_outline_rounded),
              errorText: errorText,
              errorMaxLines: 3,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        IconButton.filled(
          onPressed: onAdd,
          tooltip: 'Add member',
          style: IconButton.styleFrom(
            backgroundColor: context.brandColors.primaryDark,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            fixedSize: const Size.square(AppSizes.buttonHeight),
          ),
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

/// The added members, each with its avatar and a Remove button.
class _MemberList extends StatelessWidget {
  const _MemberList({required this.members, required this.onRemove});

  /// Opacity of the Remove button's red background.
  static const double _removeBackgroundOpacity = 0.12;

  final List<String> members;
  final ValueChanged<int> onRemove;

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
      child: Column(
        children: [
          for (final (index, name) in members.indexed) ...[
            if (index > 0)
              const Divider(height: 1, indent: AppSpacing.xxl + AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: [
                  // The owner is member 0, so others start at 1 and match
                  // their colors on the group card.
                  MemberAvatar(name: name, index: index + 1),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Text(name, style: theme.textTheme.bodyLarge)),
                  IconButton(
                    onPressed: () => onRemove(index),
                    tooltip: 'Remove $name',
                    style: IconButton.styleFrom(
                      backgroundColor: scheme.error.withValues(
                        alpha: _removeBackgroundOpacity,
                      ),
                      foregroundColor: scheme.error,
                    ),
                    icon: const Icon(Icons.close_rounded),
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
