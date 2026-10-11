import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitzy/core/assets/app_images.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/core/widgets/fade_slide_in.dart';
import 'package:splitzy/features/auth/presentation/widgets/google_mark.dart';
import 'package:splitzy/features/auth/presentation/widgets/login_background.dart';

/// The shared layout of the authentication screens (Login, Sign Up).
///
/// Provides the background, back button and friends illustration, the
/// heading, a screen-specific [form], the "or continue with" Google option and
/// a bottom prompt for switching to the other auth screen — with a subtle
/// staggered entrance that is skipped when reduced motion is requested.
///
/// Presentation only: every action is reported through a callback.
class AuthScaffold extends StatefulWidget {
  const AuthScaffold({
    super.key,
    required this.onBack,
    required this.title,
    required this.subtitle,
    required this.form,
    required this.onContinueWithGoogle,
    required this.switchPrompt,
    required this.switchActionLabel,
    required this.onSwitch,
    this.isGoogleLoading = false,
    this.illustrationScale = 1,
  });

  /// Total length of the staggered entrance animation.
  static const Duration entranceDuration = Duration(milliseconds: 900);

  final VoidCallback onBack;
  final String title;
  final String subtitle;

  /// The screen-specific fields and primary action.
  final Widget form;

  /// `null` disables the Google button (e.g. while another attempt runs).
  final VoidCallback? onContinueWithGoogle;

  /// Shows a progress indicator in the Google button.
  final bool isGoogleLoading;

  /// E.g. "Don’t have an account?" with [switchActionLabel] "Sign Up".
  final String switchPrompt;
  final String switchActionLabel;
  final VoidCallback onSwitch;

  /// Scales the illustration height; screens with longer forms use less.
  final double illustrationScale;

  @override
  State<AuthScaffold> createState() => _AuthScaffoldState();
}

class _AuthScaffoldState extends State<AuthScaffold>
    with SingleTickerProviderStateMixin {
  /// Width / height of `login_friends.png`.
  static const double _illustrationAspectRatio = 1.5;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AuthScaffold.entranceDuration,
  );

  // Subtle staggered entrance: illustration, heading, form, then the rest.
  late final Animation<double> _illustration = _interval(0, 0.5);
  late final Animation<double> _heading = _interval(0.2, 0.65);
  late final Animation<double> _form = _interval(0.35, 0.85);
  late final Animation<double> _footer = _interval(0.5, 1);

  Animation<double> _interval(double begin, double end) {
    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // With reduced motion, everything is shown in its final state at once.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    const shown = AlwaysStoppedAnimation<double>(1);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: LoginBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Compact screens tighten the gaps and the illustration.
              final compact = constraints.maxHeight < AppSizes.compactHeight;
              final gap = compact ? AppSpacing.sm : AppSpacing.lg;
              final contentWidth =
                  math.min(constraints.maxWidth, AppSizes.maxContentWidth) -
                  AppSpacing.xl * 2;
              final illustrationHeight = math.min(
                contentWidth / _illustrationAspectRatio,
                constraints.maxHeight *
                    (compact ? 0.16 : 0.27) *
                    widget.illustrationScale,
              );

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                      maxWidth: AppSizes.maxContentWidth,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: AppSpacing.sm),
                            _IllustrationHeader(
                              animation: reduceMotion ? shown : _illustration,
                              height: illustrationHeight,
                              aspectRatio: _illustrationAspectRatio,
                              onBack: widget.onBack,
                            ),
                            SizedBox(height: gap),
                            FadeSlideIn(
                              animation: reduceMotion ? shown : _heading,
                              offsetY: 0.2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.title,
                                    style: textTheme.headlineMedium,
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Text(
                                    widget.subtitle,
                                    style: textTheme.titleMedium,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: gap),
                            FadeSlideIn(
                              animation: reduceMotion ? shown : _form,
                              offsetY: 0.05,
                              child: widget.form,
                            ),
                            SizedBox(height: gap),
                            FadeSlideIn(
                              animation: reduceMotion ? shown : _footer,
                              offsetY: 0.1,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const _OrDivider(),
                                  SizedBox(height: gap),
                                  _GoogleButton(
                                    onPressed: widget.onContinueWithGoogle,
                                    isLoading: widget.isGoogleLoading,
                                  ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            const SizedBox(height: AppSpacing.md),
                            FadeSlideIn(
                              animation: reduceMotion ? shown : _footer,
                              offsetY: 0.2,
                              child: _SwitchPrompt(
                                prompt: widget.switchPrompt,
                                actionLabel: widget.switchActionLabel,
                                onPressed: widget.onSwitch,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The friends illustration with the back button over its top-left corner.
class _IllustrationHeader extends StatelessWidget {
  const _IllustrationHeader({
    required this.animation,
    required this.height,
    required this.aspectRatio,
    required this.onBack,
  });

  static const double _sageDotRadius = 40;

  final Animation<double> animation;
  final double height;
  final double aspectRatio;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final width = height * aspectRatio;
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Decorative circle peeking in from the screen edge beside the
          // illustration. Anchored to the illustration's bottom edge (not
          // below it) so it never reaches the title, even when compact.
          Positioned(
            left: -AppSpacing.xl - _sageDotRadius,
            bottom: 0,
            child: IgnorePointer(
              child: ExcludeSemantics(
                child: Container(
                  width: _sageDotRadius * 2,
                  height: _sageDotRadius * 2,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: scheme.primaryContainer,
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: FadeSlideIn(
              animation: animation,
              offsetY: 0.06,
              child: Image.asset(
                AppImages.loginFriends,
                width: width,
                height: height,
                cacheWidth: (width * MediaQuery.devicePixelRatioOf(context))
                    .round(),
                semanticLabel: 'Three friends splitting a bill',
              ),
            ),
          ),
          Positioned(
            // Align the icon (not its tap target) with the content edge.
            left: -AppSpacing.md,
            top: 0,
            child: IconButton(
              onPressed: onBack,
              color: scheme.onSurface,
              icon: const Icon(Icons.arrow_back_rounded),
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // One full-width line with the label on a background-colored patch, so
    // the label can wrap at large text sizes instead of overflowing a Row.
    return Stack(
      alignment: Alignment.center,
      children: [
        const Divider(),
        ColoredBox(
          color: theme.scaffoldBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(
              'or continue with',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed, required this.isLoading});

  /// Matches the size of the Google mark, so loading keeps the layout.
  static const double _iconSize = 22;
  static const double _progressStrokeWidth = 2.5;

  final VoidCallback? onPressed;
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
            const GoogleMark(size: _iconSize),
          const SizedBox(width: AppSpacing.md),
          const Flexible(
            child: Text('Continue with Google', textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}

/// "Don’t have an account? Sign Up" / "Already have an account? Sign In".
class _SwitchPrompt extends StatelessWidget {
  const _SwitchPrompt({
    required this.prompt,
    required this.actionLabel,
    required this.onPressed,
  });

  final String prompt;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(prompt, style: Theme.of(context).textTheme.bodyMedium),
        TextButton(onPressed: onPressed, child: Text(actionLabel)),
      ],
    );
  }
}
