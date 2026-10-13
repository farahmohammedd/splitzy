import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_brand_colors.dart';

/// A member's initial in a colored circle. Colors cycle through the brand's
/// light container colors by [index] (the member's position), so neighbours
/// differ, as in the design reference. The group's owner ([isOwner]) is dark.
class MemberAvatar extends StatelessWidget {
  const MemberAvatar({
    super.key,
    required this.name,
    required this.index,
    this.radius = 20,
    this.isOwner = false,
    this.ringColor,
  });

  /// Width of the ring drawn when [ringColor] is set.
  static const double ringWidth = 1.5;

  final String name;

  /// The member's position in its list; picks the color.
  final int index;
  final double radius;
  final bool isOwner;

  /// A thin ring around the circle, so overlapping avatars stay apart.
  final Color? ringColor;

  /// The background and foreground colors for the item at [index]; shared
  /// with other group visuals so they cycle through the same colors.
  static (Color, Color) colorsFor(ColorScheme scheme, int index) {
    return switch (index % 3) {
      0 => (scheme.secondaryContainer, scheme.onSecondaryContainer),
      1 => (scheme.tertiaryContainer, scheme.onTertiaryContainer),
      _ => (scheme.primaryContainer, scheme.onPrimaryContainer),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (background, foreground) = isOwner
        ? (context.brandColors.primaryDark, scheme.onPrimary)
        : colorsFor(scheme, index);
    final initial = name.isEmpty ? '?' : name.characters.first.toUpperCase();

    Widget avatar = CircleAvatar(
      radius: radius,
      backgroundColor: background,
      child: Text(
        initial,
        style: theme.textTheme.titleSmall?.copyWith(color: foreground),
      ),
    );
    final ring = ringColor;
    if (ring != null) {
      avatar = DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: ring, width: ringWidth),
        ),
        child: avatar,
      );
    }

    // The name is shown or read next to it, so the initial adds nothing.
    return ExcludeSemantics(child: avatar);
  }
}
