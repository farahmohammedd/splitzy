import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/global_error_handlers.dart';

import '../../helpers/fake_error_reporter.dart';

void main() {
  late FakeErrorReporter reporter;
  late FlutterExceptionHandler? originalOnError;
  late FlutterExceptionHandler originalPresentError;
  late ErrorCallback? originalPlatformOnError;
  late List<FlutterErrorDetails> presented;
  final originalStack = StackTrace.fromString('original-stack');

  setUp(() {
    reporter = FakeErrorReporter();
    presented = [];
    originalOnError = FlutterError.onError;
    originalPresentError = FlutterError.presentError;
    originalPlatformOnError = PlatformDispatcher.instance.onError;
    // Record what would be printed instead of printing it.
    FlutterError.presentError = presented.add;
    installGlobalErrorHandlers(reporter);
  });

  tearDown(() {
    // Restore the test framework's handlers.
    FlutterError.onError = originalOnError;
    FlutterError.presentError = originalPresentError;
    PlatformDispatcher.instance.onError = originalPlatformOnError;
  });

  group('FlutterError.onError', () {
    test('prints the error and reports it as fatal with its stack trace', () {
      final error = StateError('build failed');
      final details = FlutterErrorDetails(
        exception: error,
        stack: originalStack,
        context: ErrorDescription('while building HomeScreen'),
      );

      FlutterError.onError!(details);

      expect(presented.single, same(details));
      final report = reporter.fatal.single;
      expect(report.error, same(error));
      expect(report.stackTrace.toString(), originalStack.toString());
      expect(
        report.reason,
        'Uncaught Flutter framework error while building HomeScreen',
      );
      expect(reporter.nonFatal, isEmpty);
    });

    test('reports an error without context or stack trace', () {
      FlutterError.onError!(FlutterErrorDetails(exception: StateError('x')));

      final report = reporter.fatal.single;
      expect(report.stackTrace, StackTrace.empty);
      expect(report.reason, 'Uncaught Flutter framework error');
    });
  });

  group('PlatformDispatcher.onError', () {
    test('prints the error, reports it as fatal and marks it handled', () {
      final error = Exception('unawaited future failed');

      final handled = PlatformDispatcher.instance.onError!(
        error,
        originalStack,
      );

      expect(handled, isTrue);
      expect(presented.single.exception, same(error));
      expect(presented.single.stack, same(originalStack));
      final report = reporter.fatal.single;
      expect(report.error, same(error));
      expect(report.stackTrace.toString(), originalStack.toString());
      expect(report.reason, 'Uncaught asynchronous error');
      expect(reporter.nonFatal, isEmpty);
    });
  });

  test('each uncaught error is reported once', () {
    FlutterError.onError!(FlutterErrorDetails(exception: StateError('a')));
    PlatformDispatcher.instance.onError!(StateError('b'), originalStack);

    expect(reporter.fatal, hasLength(2));
  });
}
