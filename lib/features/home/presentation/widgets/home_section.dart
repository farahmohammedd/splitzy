import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_spacing.dart';

/// A titled section of Home in its empty state: the title, then a card with
/// an icon and a message (e.g. "No groups yet").
class HomeSection extends StatelessWidget {
  const HomeSection({
    super.key,
    required this.title,
    required this.emptyIcon,
    required this.emptyMessage,
  });

  final String title;
  final IconData emptyIcon;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.sm),
        DecoratedBox(
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
                  child: Icon(emptyIcon, color: scheme.onSurfaceVariant),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(emptyMessage, style: theme.textTheme.bodyMedium),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
