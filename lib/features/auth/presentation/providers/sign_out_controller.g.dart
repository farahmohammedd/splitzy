// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sign_out_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs a log-out and exposes its progress: data (idle or done), loading, or
/// an error holding a [Failure] (see [runGuarded]).
///
/// Sign-out has no business rules, so it calls the repository directly. It
/// never navigates: a successful sign-out changes the auth state and the
/// router moves the user to Splash.

@ProviderFor(SignOutController)
final signOutControllerProvider = SignOutControllerProvider._();

/// Runs a log-out and exposes its progress: data (idle or done), loading, or
/// an error holding a [Failure] (see [runGuarded]).
///
/// Sign-out has no business rules, so it calls the repository directly. It
/// never navigates: a successful sign-out changes the auth state and the
/// router moves the user to Splash.
final class SignOutControllerProvider
    extends $AsyncNotifierProvider<SignOutController, void> {
  /// Runs a log-out and exposes its progress: data (idle or done), loading, or
  /// an error holding a [Failure] (see [runGuarded]).
  ///
  /// Sign-out has no business rules, so it calls the repository directly. It
  /// never navigates: a successful sign-out changes the auth state and the
  /// router moves the user to Splash.
  SignOutControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signOutControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signOutControllerHash();

  @$internal
  @override
  SignOutController create() => SignOutController();
}

String _$signOutControllerHash() => r'e37d1956e59ee8d68ceaeee58313c180b65ce3cd';

/// Runs a log-out and exposes its progress: data (idle or done), loading, or
/// an error holding a [Failure] (see [runGuarded]).
///
/// Sign-out has no business rules, so it calls the repository directly. It
/// never navigates: a successful sign-out changes the auth state and the
/// router moves the user to Splash.

abstract class _$SignOutController extends $AsyncNotifier<void> {
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
