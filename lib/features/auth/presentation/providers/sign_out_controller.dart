import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/core/error/error_reporter_provider.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/core/error/run_guarded.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_providers.dart';

part 'sign_out_controller.g.dart';

/// Runs a log-out and exposes its progress: data (idle or done), loading, or
/// an error holding a [Failure] (see [runGuarded]).
///
/// Sign-out has no business rules, so it calls the repository directly. It
/// never navigates: a successful sign-out changes the auth state and the
/// router moves the user to Splash.
@riverpod
class SignOutController extends _$SignOutController {
  @override
  FutureOr<void> build() {}

  Future<void> logOut() async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await runGuarded(
      () => ref.read(authRepositoryProvider).signOut(),
      reporter: ref.read(errorReporterProvider),
      reason: 'Logging out',
    );
    // Success redirects away from Home, which disposes this controller.
    if (ref.mounted) state = result;
  }
}
