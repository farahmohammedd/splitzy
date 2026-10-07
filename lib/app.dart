import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/auth/presentation/login_screen.dart';
import 'features/splash/presentation/launch_screen.dart';
import 'features/splash/presentation/splash_screen.dart';

/// The Splitzy application root.
class SplitzyApp extends StatelessWidget {
  const SplitzyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Splitzy',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      // Becomes `MaterialApp.router` when the router is introduced.
      home: const _LaunchPage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Temporary navigation, to be replaced by GoRouter.
//
// Screens only expose callbacks (`onLoaded`, `onGetStarted`); all wiring
// between them lives below so the router can replace it in one place.
// Flow: Launch --(replace)--> Splash --(push)--> Login.
// ---------------------------------------------------------------------------

class _LaunchPage extends StatelessWidget {
  const _LaunchPage();

  @override
  Widget build(BuildContext context) {
    return LaunchScreen(
      onLoaded: () => Navigator.of(
        context,
      ).pushReplacement(_fadeRoute(context, (_) => const _SplashPage())),
    );
  }
}

class _SplashPage extends StatelessWidget {
  const _SplashPage();

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      onGetStarted: () => Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const _LoginPage())),
    );
  }
}

class _LoginPage extends StatelessWidget {
  const _LoginPage();

  @override
  Widget build(BuildContext context) {
    // Authentication is not implemented yet: only Back navigates. The other
    // actions are intentionally no-ops until their features are built.
    return LoginScreen(
      onBack: () => Navigator.of(context).maybePop(),
      onLogIn: (_, _) {},
      onForgotPassword: () {},
      onContinueWithGoogle: () {},
      onSignUp: () {},
    );
  }
}

/// Cross-fades to the next screen; instant when the platform asks to reduce
/// motion.
Route<void> _fadeRoute(BuildContext context, WidgetBuilder builder) {
  final duration = MediaQuery.disableAnimationsOf(context)
      ? Duration.zero
      : const Duration(milliseconds: 400);

  return PageRouteBuilder<void>(
    transitionDuration: duration,
    reverseTransitionDuration: duration,
    pageBuilder: (context, _, _) => builder(context),
    transitionsBuilder: (_, animation, _, child) =>
        FadeTransition(opacity: animation, child: child),
  );
}
