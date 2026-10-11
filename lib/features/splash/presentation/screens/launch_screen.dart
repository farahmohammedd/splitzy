import 'package:flutter/material.dart';

import 'package:splitzy/core/assets/app_images.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/core/widgets/brand_background.dart';

/// The first screen shown on app start: brand logo, wordmark, tagline and a
/// loading bar.
///
/// The bar fills over [minimumDuration]; when it completes, [onLoaded] is
/// called once. Navigation is not handled here — the caller decides what
/// happens next.
class LaunchScreen extends StatefulWidget {
  const LaunchScreen({
    super.key,
    this.minimumDuration = defaultMinimumDuration,
    this.onLoaded,
  });

  static const Duration defaultMinimumDuration = Duration(milliseconds: 3000);

  final Duration minimumDuration;
  final VoidCallback? onLoaded;

  @override
  State<LaunchScreen> createState() => _LaunchScreenState();
}

class _LaunchScreenState extends State<LaunchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.minimumDuration,
    // Keep the real duration even when the platform asks to reduce motion;
    // by default Flutter would shorten it ~20x and skip the minimum loading
    // time. Reduced motion is handled in build() instead.
    animationBehavior: AnimationBehavior.preserve,
  )..addStatusListener(_onStatusChanged);

  // Entrance: logo first, then the wordmark and tagline.
  late final Animation<double> _logoFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.3, curve: Curves.easeOut),
  );
  late final Animation<double> _logoScale = Tween<double>(begin: 0.9, end: 1)
      .animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.35, curve: Curves.easeOutBack),
        ),
      );
  late final Animation<double> _textFade = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.2, 0.45, curve: Curves.easeOut),
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOut,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  void _onStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed) widget.onLoaded?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // With reduced motion, content appears immediately; the progress bar still
    // advances because it conveys loading state rather than decoration.
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    const shown = AlwaysStoppedAnimation<double>(1);

    return Scaffold(
      body: BrandBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final logoSize = _logoSizeFor(constraints);
              final barWidth = (constraints.maxWidth * 0.63).clamp(
                0.0,
                AppSizes.maxContentWidth * 0.7,
              );

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    // Keep content in the clear band between the top-right
                    // shape and the bottom waves of BrandBackground.
                    padding: EdgeInsets.fromLTRB(
                      AppSpacing.lg,
                      constraints.maxHeight * 0.15,
                      AppSpacing.lg,
                      constraints.maxHeight * 0.21,
                    ),
                    child: Center(
                      child: _LaunchContent(
                        logoSize: logoSize,
                        barWidth: barWidth,
                        sectionGap:
                            constraints.maxHeight < AppSizes.compactHeight
                            ? AppSpacing.lg
                            : AppSpacing.xl + AppSpacing.sm,
                        logoFade: reduceMotion ? shown : _logoFade,
                        logoScale: reduceMotion ? shown : _logoScale,
                        textFade: reduceMotion ? shown : _textFade,
                        progress: _progress,
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

  /// The icon asset includes transparent padding around its rounded tile, so
  /// it is drawn larger than the visible tile.
  static double _logoSizeFor(BoxConstraints constraints) {
    final byWidth = constraints.maxWidth * 0.42;
    final byHeight = constraints.maxHeight * 0.22;
    return (byWidth < byHeight ? byWidth : byHeight).clamp(112.0, 220.0);
  }
}

class _LaunchContent extends StatelessWidget {
  const _LaunchContent({
    required this.logoSize,
    required this.barWidth,
    required this.sectionGap,
    required this.logoFade,
    required this.logoScale,
    required this.textFade,
    required this.progress,
  });

  /// The reference track is a paler sage than the theme default.
  static const double _trackOpacity = 0.55;

  final double logoSize;
  final double barWidth;

  /// Space between the tagline and the loading bar.
  final double sectionGap;
  final Animation<double> logoFade;
  final Animation<double> logoScale;
  final Animation<double> textFade;
  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final pixelRatio = MediaQuery.devicePixelRatioOf(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FadeTransition(
          opacity: logoFade,
          child: ScaleTransition(
            scale: logoScale,
            child: Image.asset(
              AppImages.splitzyIcon,
              width: logoSize,
              height: logoSize,
              cacheWidth: (logoSize * pixelRatio).round(),
              semanticLabel: 'Splitzy logo',
            ),
          ),
        ),
        FadeTransition(
          opacity: textFade,
          child: Column(
            children: [
              Text(
                'Splitzy',
                style: textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Split Together, Stay Closer',
                style: textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        SizedBox(height: sectionGap),
        SizedBox(
          width: barWidth,
          child: AnimatedBuilder(
            animation: progress,
            builder: (context, _) => LinearProgressIndicator(
              value: progress.value,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.primaryContainer.withValues(alpha: _trackOpacity),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              semanticsLabel: 'Loading',
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // The progress bar already announces "Loading" to screen readers.
        ExcludeSemantics(
          child: Text('Loading...', style: textTheme.bodyMedium),
        ),
      ],
    );
  }
}
