// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_up_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs a registration attempt and exposes its progress: data (idle or
/// done), loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: the new account is signed in, which changes the auth
/// state, and the router moves the user to Home.

@ProviderFor(SignUpController)
final signUpControllerProvider = SignUpControllerProvider._();

/// Runs a registration attempt and exposes its progress: data (idle or
/// done), loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: the new account is signed in, which changes the auth
/// state, and the router moves the user to Home.
final class SignUpControllerProvider
    extends $AsyncNotifierProvider<SignUpController, void> {
  /// Runs a registration attempt and exposes its progress: data (idle or
  /// done), loading, or an error holding a [Failure] (see [runGuarded]).
  ///
  /// It never navigates: the new account is signed in, which changes the auth
  /// state, and the router moves the user to Home.
  SignUpControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpControllerHash();

  @$internal
  @override
  SignUpController create() => SignUpController();
}

String _$signUpControllerHash() => r'0c4a82fff30b6a4a66aa38725eafde61a708c4cc';

/// Runs a registration attempt and exposes its progress: data (idle or
/// done), loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: the new account is signed in, which changes the auth
/// state, and the router moves the user to Home.

abstract class _$SignUpController extends $AsyncNotifier<void> {
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
