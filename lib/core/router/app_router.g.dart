// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's single [GoRouter].
///
/// Flow: Launch --(replace)--> Splash --(push)--> Login <--(push/pop)--> Sign Up.
/// Signed-in users are redirected to Home (see [authRedirect]).
///
/// Kept alive for the whole app lifetime: recreating the router would reset
/// the navigation stack. It therefore *listens* to the auth state and
/// re-runs its redirect instead of being rebuilt.

@ProviderFor(appRouter)
final appRouterProvider = AppRouterProvider._();

/// The app's single [GoRouter].
///
/// Flow: Launch --(replace)--> Splash --(push)--> Login <--(push/pop)--> Sign Up.
/// Signed-in users are redirected to Home (see [authRedirect]).
///
/// Kept alive for the whole app lifetime: recreating the router would reset
/// the navigation stack. It therefore *listens* to the auth state and
/// re-runs its redirect instead of being rebuilt.

final class AppRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// The app's single [GoRouter].
  ///
  /// Flow: Launch --(replace)--> Splash --(push)--> Login <--(push/pop)--> Sign Up.
  /// Signed-in users are redirected to Home (see [authRedirect]).
  ///
  /// Kept alive for the whole app lifetime: recreating the router would reset
  /// the navigation stack. It therefore *listens* to the auth state and
  /// re-runs its redirect instead of being rebuilt.
  AppRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return appRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$appRouterHash() => r'0e76b26569befaffe213160b4cf59e0582f555d5';
