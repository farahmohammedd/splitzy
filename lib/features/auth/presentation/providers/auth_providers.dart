import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/domain/repositories/auth_repository.dart';
import 'package:splitzy/features/auth/domain/usecases/register_use_case.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_use_case.dart';

part 'auth_providers.g.dart';

// The instances below are created by `InjectionContainer`
// (lib/injection_container.dart) and supplied through its `ProviderScope`
// overrides. Without those overrides, reading them fails fast. They are kept
// alive because each override is a single app-lifetime instance.

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => throw UnimplementedError(
  'authRepositoryProvider is supplied by InjectionContainer.overrides',
);

@Riverpod(keepAlive: true)
SignInUseCase signInUseCase(Ref ref) => throw UnimplementedError(
  'signInUseCaseProvider is supplied by InjectionContainer.overrides',
);

@Riverpod(keepAlive: true)
RegisterUseCase registerUseCase(Ref ref) => throw UnimplementedError(
  'registerUseCaseProvider is supplied by InjectionContainer.overrides',
);

/// The signed-in user, or `null` when signed out.
///
/// Kept alive because the router depends on it for the whole app lifetime.
@Riverpod(keepAlive: true)
Stream<AppUser?> authState(Ref ref) {
  return ref.watch(authRepositoryProvider).userChanges();
}
