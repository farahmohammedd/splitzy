import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_spacing.dart';

/// A titled section of Home: the title, an optional See all link, then
/// [child], or when there is none, the empty state: a card with an icon and a
/// message (e.g. "No groups yet").
class HomeSection extends StatelessWidget {
  const HomeSection({
    super.key,
    required this.title,
    required this.emptyIcon,
    required this.emptyMessage,
    this.child,
    this.onSeeAll,
  });

  final String title;
  final IconData emptyIcon;
  final String emptyMessage;

  /// The section's content; `null` shows the empty state.
  final Widget? child;

  /// Shows a See all link next to the title when set.
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final onSeeAll = this.onSeeAll;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: theme.textTheme.titleLarge)),
            if (onSeeAll != null)
              TextButton(onPressed: onSeeAll, child: const Text('See all')),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child ??
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
                      child: Text(
                        emptyMessage,
                        style: theme.textTheme.bodyMedium,
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
