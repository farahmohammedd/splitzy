import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/core/error/error_reporter_provider.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/core/error/run_guarded.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_providers.dart';
import 'package:splitzy/features/auth/presentation/screens/sign_up_screen.dart';

part 'sign_up_controller.g.dart';

/// Runs a registration attempt and exposes its progress: data (idle or
/// done), loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: the new account is signed in, which changes the auth
/// state, and the router moves the user to Home.
@riverpod
class SignUpController extends _$SignUpController {
  @override
  FutureOr<void> build() {}

  Future<void> register(SignUpDetails details) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await runGuarded(
      () => ref.read(registerUseCaseProvider)(
        fullName: details.fullName,
        email: details.email,
        password: details.password,
        confirmPassword: details.confirmPassword,
      ),
      reporter: ref.read(errorReporterProvider),
      reason: 'Creating an account',
    );
    // Success redirects away from Sign Up, which disposes this controller.
    if (ref.mounted) state = result;
  }
}
