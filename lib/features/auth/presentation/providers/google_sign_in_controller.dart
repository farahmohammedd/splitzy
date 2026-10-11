import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/core/error/error_reporter_provider.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/core/error/run_guarded.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_providers.dart';

part 'google_sign_in_controller.g.dart';

/// The auth screen a Google sign-in attempt starts from.
enum GoogleSignInOrigin { login, signUp }

/// Runs a Google sign-in attempt and exposes its progress: data (idle, done
/// or cancelled), loading, or an error holding a [Failure] (see
/// [runGuarded]).
///
/// One instance per [GoogleSignInOrigin]: Login stays mounted under Sign Up,
/// so a shared instance would show a Login failure on Sign Up.
///
/// Google sign-in has no business rules, so it calls the repository
/// directly. A cancelled account picker ends in the idle state with no
/// message. It never navigates: a successful sign-in changes the auth state
/// and the router moves the user to Home.
@riverpod
class GoogleSignInController extends _$GoogleSignInController {
  @override
  FutureOr<void> build(GoogleSignInOrigin origin) {}

  Future<void> signIn() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await runGuarded(
      () => ref.read(authRepositoryProvider).signInWithGoogle(),
      reporter: ref.read(errorReporterProvider),
      reason: 'Signing in with Google',
    );
    // Success redirects away from the auth screen, which disposes this
    // controller.
    if (ref.mounted) state = result;
  }
}
