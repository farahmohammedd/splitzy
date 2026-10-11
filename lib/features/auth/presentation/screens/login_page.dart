import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/auth/presentation/providers/google_sign_in_controller.dart';
import 'package:splitzy/features/auth/presentation/providers/login_controller.dart';
import 'package:splitzy/features/auth/presentation/screens/login_screen.dart';

/// Connects [LoginScreen] to [LoginController] and [GoogleSignInController]:
/// forwards log-in attempts and passes their progress and failure message
/// back to the screen. Navigation callbacks come from the router.
class LoginPage extends ConsumerWidget {
  const LoginPage({
    super.key,
    required this.onBack,
    required this.onForgotPassword,
    required this.onSignUp,
  });

  final VoidCallback onBack;
  final VoidCallback onForgotPassword;
  final VoidCallback onSignUp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleProvider = googleSignInControllerProvider(
      GoogleSignInOrigin.login,
    );
    final attempt = ref.watch(loginControllerProvider);
    final googleAttempt = ref.watch(googleProvider);

    // Starting an attempt clears the other one's failure, so the message
    // shown is always the latest. The screen never starts one while the
    // other runs, so nothing in progress is reset.
    return LoginScreen(
      onBack: onBack,
      onLogIn: (email, password) {
        ref.invalidate(googleProvider);
        ref
            .read(loginControllerProvider.notifier)
            .logIn(email: email, password: password);
      },
      onForgotPassword: onForgotPassword,
      onContinueWithGoogle: () {
        ref.invalidate(loginControllerProvider);
        ref.read(googleProvider.notifier).signIn();
      },
      onSignUp: onSignUp,
      isSubmitting: attempt.isLoading,
      isGoogleSubmitting: googleAttempt.isLoading,
      errorMessage: switch ((googleAttempt, attempt)) {
        (AsyncError(:final error), _) ||
        (_, AsyncError(:final error)) => messageFor(error),
        _ => null,
      },
    );
  }
}
