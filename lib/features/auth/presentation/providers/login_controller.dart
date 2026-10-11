import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/core/error/error_reporter_provider.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/core/error/run_guarded.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_providers.dart';

part 'login_controller.g.dart';

/// Runs a log-in attempt and exposes its progress: data (idle or done),
/// loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: a successful sign-in changes the auth state and the
/// router moves the user to Home.
@riverpod
class LoginController extends _$LoginController {
  @override
  FutureOr<void> build() {}

  Future<void> logIn({required String email, required String password}) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await runGuarded(
      () => ref.read(signInUseCaseProvider)(email: email, password: password),
      reporter: ref.read(errorReporterProvider),
      reason: 'Logging in',
    );
    // Success redirects away from Login, which disposes this controller.
    if (ref.mounted) state = result;
  }
}
