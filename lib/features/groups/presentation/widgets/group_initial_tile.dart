import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/core/widgets/member_avatar.dart';

/// A group's initial in a rounded square, as in the design reference. Colors
/// cycle by [index] (the group's position in its list), like [MemberAvatar].
class GroupInitialTile extends StatelessWidget {
  const GroupInitialTile({
    super.key,
    required this.name,
    required this.index,
    this.size = 56,
  });

  final String name;
  final int index;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (background, foreground) = MemberAvatar.colorsFor(
      theme.colorScheme,
      index,
    );
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();

    // The group's name is shown next to it, so the initial adds nothing.
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          // A fixed-size tile: its letter does not grow with the text scale.
          child: Center(
            child: MediaQuery.withNoTextScaling(
              child: Text(
                initial,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
