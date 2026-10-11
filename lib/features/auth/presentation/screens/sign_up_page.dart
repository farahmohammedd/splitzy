import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/auth/presentation/providers/google_sign_in_controller.dart';
import 'package:splitzy/features/auth/presentation/providers/sign_up_controller.dart';
import 'package:splitzy/features/auth/presentation/screens/sign_up_screen.dart';

/// Connects [SignUpScreen] to [SignUpController] and
/// [GoogleSignInController]: forwards registration and Google sign-in
/// attempts and passes their progress and failure message back to the
/// screen. Navigation callbacks come from the router.
class SignUpPage extends ConsumerWidget {
  const SignUpPage({super.key, required this.onBack, required this.onSignIn});

  final VoidCallback onBack;
  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final googleProvider = googleSignInControllerProvider(
      GoogleSignInOrigin.signUp,
    );
    final attempt = ref.watch(signUpControllerProvider);
    final googleAttempt = ref.watch(googleProvider);

    // Starting an attempt clears the other one's failure, so the message
    // shown is always the latest. The screen never starts one while the
    // other runs, so nothing in progress is reset.
    return SignUpScreen(
      onBack: onBack,
      onCreateAccount: (details) {
        ref.invalidate(googleProvider);
        ref.read(signUpControllerProvider.notifier).register(details);
      },
      onContinueWithGoogle: () {
        ref.invalidate(signUpControllerProvider);
        ref.read(googleProvider.notifier).signIn();
      },
      onSignIn: onSignIn,
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
