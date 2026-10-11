import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/core/error/error_reporter.dart';

part 'error_reporter_provider.g.dart';

/// The app's [ErrorReporter], created by `InjectionContainer`
/// (lib/injection_container.dart) and supplied through its `ProviderScope`
/// overrides. Without that override, reading it fails fast. Kept alive
/// because the override is a single app-lifetime instance.
@Riverpod(keepAlive: true)
ErrorReporter errorReporter(Ref ref) => throw UnimplementedError(
  'errorReporterProvider is supplied by InjectionContainer.overrides',
);
