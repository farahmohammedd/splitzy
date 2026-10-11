// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs a log-in attempt and exposes its progress: data (idle or done),
/// loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: a successful sign-in changes the auth state and the
/// router moves the user to Home.

@ProviderFor(LoginController)
final loginControllerProvider = LoginControllerProvider._();

/// Runs a log-in attempt and exposes its progress: data (idle or done),
/// loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: a successful sign-in changes the auth state and the
/// router moves the user to Home.
final class LoginControllerProvider
    extends $AsyncNotifierProvider<LoginController, void> {
  /// Runs a log-in attempt and exposes its progress: data (idle or done),
  /// loading, or an error holding a [Failure] (see [runGuarded]).
  ///
  /// It never navigates: a successful sign-in changes the auth state and the
  /// router moves the user to Home.
  LoginControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginControllerHash();

  @$internal
  @override
  LoginController create() => LoginController();
}

String _$loginControllerHash() => r'd2966a0f5f5e585a8e75af7caf42e7385d22736f';

/// Runs a log-in attempt and exposes its progress: data (idle or done),
/// loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: a successful sign-in changes the auth state and the
/// router moves the user to Home.

abstract class _$LoginController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
