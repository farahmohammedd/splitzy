import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// The primary call-to-action button: a full-width filled pill with a label
/// and a trailing arrow (e.g. "Get Started →", "Log In →").
///
/// Colors, shape and size come from the theme's `filledButtonTheme`.
class PrimaryArrowButton extends StatelessWidget {
  const PrimaryArrowButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flexible lets the label wrap instead of overflowing at large
          // text sizes on narrow screens.
          Flexible(child: Text(label, textAlign: TextAlign.center)),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.arrow_forward_rounded),
        ],
      ),
    );
  }
}
