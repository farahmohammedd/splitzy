import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:splitzy/core/assets/app_images.dart';
import 'package:splitzy/core/theme/app_spacing.dart';
import 'package:splitzy/core/widgets/fade_slide_in.dart';
import 'package:splitzy/core/widgets/primary_arrow_button.dart';
import 'package:splitzy/features/splash/presentation/widgets/splash_background.dart';

/// The branded welcome screen: logo, wordmark, friends illustration, value
/// proposition and a "Get Started" call to action.
///
/// Navigation is not handled here — [onGetStarted] is called when the user
/// taps the button and the caller decides where to go.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onGetStarted});

  /// Total length of the staggered entrance animation.
  static const Duration entranceDuration = Duration(milliseconds: 1200);

  final VoidCallback onGetStarted;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: SplashScreen.entranceDuration,
  );

  // Staggered entrance: header, illustration, copy, then the button.
  late final Animation<double> _header = _interval(0, 0.35);
  late final Animation<double> _illustration = _interval(0.2, 0.6);
  late final Animation<double> _copy = _interval(0.45, 0.8);
  late final Animation<double> _button = _interval(0.65, 1);

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
      body: SplashBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final layout = _SplashLayout.from(constraints);

              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        FadeSlideIn(
                          animation: reduceMotion ? shown : _header,
                          offsetY: -0.15,
                          child: _Header(logoSize: layout.logoSize),
                        ),
                        const Spacer(),
                        FadeSlideIn(
                          animation: reduceMotion ? shown : _illustration,
                          offsetY: 0.08,
                          child: _FriendsIllustration(
                            width: layout.illustrationWidth,
                            height: layout.illustrationHeight,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        FadeSlideIn(
                          animation: reduceMotion ? shown : _copy,
                          offsetY: 0.2,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: Column(
                              children: [
                                Text(
                                  'Split Expenses\nBuild Stronger Bonds',
                                  style: textTheme.headlineSmall,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  'A simple way to share expenses\n'
                                  'with friends and family.',
                                  style: textTheme.bodyMedium,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: AppSpacing.lg),
                        FadeSlideIn(
                          animation: reduceMotion ? shown : _button,
                          offsetY: 0.4,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(
                                maxWidth: AppSizes.maxContentWidth,
                              ),
                              child: PrimaryArrowButton(
                                label: 'Get Started',
                                onPressed: widget.onGetStarted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                      ],
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

/// Size decisions for the splash layout, derived from the available space.
class _SplashLayout {
  const _SplashLayout({
    required this.logoSize,
    required this.illustrationWidth,
    required this.illustrationHeight,
  });

  /// Width / height of `splash_friends.png`.
  static const double _illustrationAspectRatio = 1.5;

  factory _SplashLayout.from(BoxConstraints constraints) {
    // The icon asset has transparent padding around its tile, so it is drawn
    // larger than the visible tile.
    final logoSize = math
        .min(constraints.maxWidth * 0.345, constraints.maxHeight * 0.14)
        .clamp(72.0, 160.0);

    // Full width on phones; limited by height on short or wide screens.
    final illustrationHeight = math.min(
      constraints.maxWidth / _illustrationAspectRatio,
      constraints.maxHeight * 0.31,
    );

    return _SplashLayout(
      logoSize: logoSize,
      illustrationWidth: illustrationHeight * _illustrationAspectRatio,
      illustrationHeight: illustrationHeight,
    );
  }

  final double logoSize;
  final double illustrationWidth;
  final double illustrationHeight;
}

class _Header extends StatelessWidget {
  const _Header({required this.logoSize});

  final double logoSize;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        Image.asset(
          AppImages.splitzyIcon,
          width: logoSize,
          height: logoSize,
          cacheWidth: (logoSize * MediaQuery.devicePixelRatioOf(context))
              .round(),
          semanticLabel: 'Splitzy logo',
        ),
        Text('Splitzy', style: textTheme.displaySmall),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Text(
            'Split Together, Stay Closer',
            style: textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}

/// The friends illustration on a soft sage halo.
class _FriendsIllustration extends StatelessWidget {
  const _FriendsIllustration({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final sage = Theme.of(context).colorScheme.secondaryContainer;

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeSemantics(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.2),
                  radius: 0.58,
                  colors: [
                    sage,
                    sage.withValues(alpha: 0.6),
                    sage.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
          ),
          Image.asset(
            AppImages.splashFriends,
            fit: BoxFit.contain,
            cacheWidth: (width * MediaQuery.devicePixelRatioOf(context))
                .round(),
            semanticLabel: 'Three friends laughing while looking at a phone',
          ),
        ],
      ),
    );
  }
}
