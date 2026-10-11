import 'package:flutter/widgets.dart';

/// Fades [child] in while sliding it by [offsetY] (a fraction of its own
/// height) into place, driven by [animation] (0 → hidden, 1 → in place).
///
/// Used for staggered screen entrances. To skip the effect (e.g. when the
/// platform asks to reduce motion), pass `AlwaysStoppedAnimation(1)`.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({
    super.key,
    required this.animation,
    required this.offsetY,
    required this.child,
  });

  final Animation<double> animation;
  final double offsetY;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset(0, offsetY),
          end: Offset.zero,
        ).animate(animation),
        child: child,
      ),
    );
  }
}
