import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

/// The primary call-to-action button: a full-width filled pill with a label
/// and a trailing arrow (e.g. "Get Started →", "Log In →").
///
/// While [isLoading], a progress indicator replaces the arrow and the button
/// is disabled, so repeated taps are ignored. The label stays, keeping the
/// button's size and its accessible name.
///
/// Colors, shape and size come from the theme's `filledButtonTheme`.
class PrimaryArrowButton extends StatelessWidget {
  const PrimaryArrowButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flexible lets the label wrap instead of overflowing at large
          // text sizes on narrow screens.
          Flexible(child: Text(label, textAlign: TextAlign.center)),
          const SizedBox(width: AppSpacing.sm),
          if (isLoading)
            const _ProgressIcon()
          else
            const Icon(Icons.arrow_forward_rounded),
        ],
      ),
    );
  }
}

/// A progress indicator sized and colored like the button's icon, so the
/// button keeps its layout while loading.
class _ProgressIcon extends StatelessWidget {
  const _ProgressIcon();

  /// Keeps the spinner inside the icon box, like a glyph's built-in padding.
  static const double _inset = 3;
  static const double _strokeWidth = 2.5;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);

    return SizedBox.square(
      dimension: iconTheme.size,
      child: Padding(
        padding: const EdgeInsets.all(_inset),
        child: CircularProgressIndicator(
          strokeWidth: _strokeWidth,
          color: iconTheme.color,
        ),
      ),
    );
  }
}
