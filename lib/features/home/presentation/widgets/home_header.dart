import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_spacing.dart';

/// The greeting at the top of Home: the user's initial in a circle, then
/// "Hello 👋" above their name.
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key, required this.name});

  static const double _avatarRadius = 24;

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();

    return Row(
      children: [
        // The name is read out next to it, so the initial adds nothing.
        ExcludeSemantics(
          child: CircleAvatar(
            radius: _avatarRadius,
            backgroundColor: scheme.secondaryContainer,
            child: Text(
              initial,
              style: theme.textTheme.titleLarge?.copyWith(
                color: scheme.onSecondaryContainer,
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hello 👋', style: theme.textTheme.bodyMedium),
              Text(name, style: theme.textTheme.headlineSmall),
            ],
          ),
        ),
      ],
    );
  }
}
