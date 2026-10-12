import 'package:flutter/material.dart';
import 'package:splitzy/core/theme/app_spacing.dart';

/// The signed-in user's profile: their name and email, and Log out.
///
/// Presentation only: log-out is reported through [onLogOut] and the caller
/// reports its progress back through [isLoggingOut].
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.name,
    required this.email,
    required this.onLogOut,
    this.isLoggingOut = false,
  });

  final String name;
  final String email;
  final VoidCallback onLogOut;

  /// Shows the Log out button's loading state and ignores further taps.
  final bool isLoggingOut;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppSizes.maxContentWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(name, style: textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Text(email, style: textTheme.bodyMedium),
                  const SizedBox(height: AppSpacing.xl),
                  _LogOutButton(onPressed: onLogOut, isLoading: isLoggingOut),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton({required this.onPressed, required this.isLoading});

  /// Matches the icon's size, so loading keeps the layout.
  static const double _iconSize = 22;
  static const double _progressStrokeWidth = 2.5;

  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: isLoading ? null : onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLoading)
            const SizedBox.square(
              dimension: _iconSize,
              child: CircularProgressIndicator(
                strokeWidth: _progressStrokeWidth,
              ),
            )
          else
            const Icon(Icons.logout_rounded, size: _iconSize),
          const SizedBox(width: AppSpacing.sm),
          const Flexible(child: Text('Log out', textAlign: TextAlign.center)),
        ],
      ),
    );
  }
}
