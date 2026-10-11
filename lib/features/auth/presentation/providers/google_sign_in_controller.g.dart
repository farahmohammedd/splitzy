// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_sign_in_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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

@ProviderFor(GoogleSignInController)
final googleSignInControllerProvider = GoogleSignInControllerFamily._();

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
final class GoogleSignInControllerProvider
    extends $AsyncNotifierProvider<GoogleSignInController, void> {
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
  GoogleSignInControllerProvider._({
    required GoogleSignInControllerFamily super.from,
    required GoogleSignInOrigin super.argument,
  }) : super(
         retry: null,
         name: r'googleSignInControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$googleSignInControllerHash();

  @override
  String toString() {
    return r'googleSignInControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  GoogleSignInController create() => GoogleSignInController();

  @override
  bool operator ==(Object other) {
    return other is GoogleSignInControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$googleSignInControllerHash() =>
    r'd568d2f47197950746c99bafe6f646f2993d4be7';

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

final class GoogleSignInControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          GoogleSignInController,
          AsyncValue<void>,
          void,
          FutureOr<void>,
          GoogleSignInOrigin
        > {
  GoogleSignInControllerFamily._()
    : super(
        retry: null,
        name: r'googleSignInControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

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

  GoogleSignInControllerProvider call(GoogleSignInOrigin origin) =>
      GoogleSignInControllerProvider._(argument: origin, from: this);

  @override
  String toString() => r'googleSignInControllerProvider';
}

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

abstract class _$GoogleSignInController extends $AsyncNotifier<void> {
  late final _$args = ref.$arg as GoogleSignInOrigin;
  GoogleSignInOrigin get origin => _$args;

  FutureOr<void> build(GoogleSignInOrigin origin);
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
    element.handleCreate(ref, () => build(_$args));
  }
}
