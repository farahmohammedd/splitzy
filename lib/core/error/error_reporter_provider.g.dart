// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_reporter_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The app's [ErrorReporter], created by `InjectionContainer`
/// (lib/injection_container.dart) and supplied through its `ProviderScope`
/// overrides. Without that override, reading it fails fast. Kept alive
/// because the override is a single app-lifetime instance.

@ProviderFor(errorReporter)
final errorReporterProvider = ErrorReporterProvider._();

/// The app's [ErrorReporter], created by `InjectionContainer`
/// (lib/injection_container.dart) and supplied through its `ProviderScope`
/// overrides. Without that override, reading it fails fast. Kept alive
/// because the override is a single app-lifetime instance.

final class ErrorReporterProvider
    extends $FunctionalProvider<ErrorReporter, ErrorReporter, ErrorReporter>
    with $Provider<ErrorReporter> {
  /// The app's [ErrorReporter], created by `InjectionContainer`
  /// (lib/injection_container.dart) and supplied through its `ProviderScope`
  /// overrides. Without that override, reading it fails fast. Kept alive
  /// because the override is a single app-lifetime instance.
  ErrorReporterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'errorReporterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$errorReporterHash();

  @$internal
  @override
  $ProviderElement<ErrorReporter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ErrorReporter create(Ref ref) {
    return errorReporter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ErrorReporter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ErrorReporter>(value),
    );
  }
}

String _$errorReporterHash() => r'5f43955a8709e263438c7f63db9a40aba2ebb1dd';
