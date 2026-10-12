import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_providers.dart';
import 'package:splitzy/features/auth/presentation/providers/sign_out_controller.dart';
import 'package:splitzy/features/auth/presentation/screens/profile_screen.dart';

/// Connects [ProfileScreen] to the signed-in user and [SignOutController].
///
/// A successful log-out changes the auth state and the redirect moves the
/// user to Splash; a failure keeps them on Profile and shows its message in a
/// SnackBar (the generic fallback for anything that is not a known failure).
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(signOutControllerProvider, (_, next) {
      if (next case AsyncError(:final error)) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(messageFor(error))));
      }
    });

    // Briefly null while signing out, before the redirect leaves Profile.
    final user = ref.watch(authStateProvider).value;
    final attempt = ref.watch(signOutControllerProvider);

    return ProfileScreen(
      name: user?.nameToShow ?? '',
      email: user?.email ?? '',
      onLogOut: () => ref.read(signOutControllerProvider.notifier).logOut(),
      isLoggingOut: attempt.isLoading,
    );
  }
}
