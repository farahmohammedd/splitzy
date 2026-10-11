import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/crashlytics_error_reporter.dart';
import 'package:splitzy/core/error/failures.dart';

class _MockCrashlytics extends Mock implements FirebaseCrashlytics {}

void main() {
  late _MockCrashlytics crashlytics;
  late CrashlyticsErrorReporter reporter;
  final stack = StackTrace.fromString('original-stack');

  setUp(() {
    crashlytics = _MockCrashlytics();
    reporter = CrashlyticsErrorReporter(crashlytics);
  });

  Future<void> anyRecordError() => crashlytics.recordError(
    any<dynamic>(),
    any(),
    reason: any<dynamic>(named: 'reason'),
    fatal: any(named: 'fatal'),
    printDetails: any(named: 'printDetails'),
  );

  void stubRecordError(Future<void> Function() answer) {
    when(anyRecordError).thenAnswer((_) => answer());
  }

  group('CrashlyticsErrorReporter.recordNonFatal', () {
    test(
      'records the error as non-fatal with its stack trace and reason',
      () async {
        stubRecordError(() async {});
        final error = StateError('unexpected');

        await reporter.recordNonFatal(error, stack, reason: 'Saving the name');

        verify(
          () => crashlytics.recordError(
            error,
            stack,
            reason: 'Saving the name',
            fatal: false,
            // Crashlytics' default: printed to the console in debug builds.
            printDetails: null,
          ),
        ).called(1);
      },
    );

    test('never reports expected failures', () async {
      await reporter.recordNonFatal(
        const NetworkFailure(),
        stack,
        reason: 'Signing in',
      );

      verifyNever(anyRecordError);
    });

    test('does not throw when Crashlytics itself fails', () async {
      stubRecordError(() async => throw Exception('channel unavailable'));

      await expectLater(
        reporter.recordNonFatal(StateError('x'), stack, reason: 'Signing in'),
        completes,
      );
    });

    test('never changes the Crashlytics collection setting', () async {
      stubRecordError(() async {});

      await reporter.recordNonFatal(StateError('x'), stack, reason: 'Test');
      await reporter.recordFatal(StateError('y'), stack, reason: 'Test');

      verifyNever(() => crashlytics.setCrashlyticsCollectionEnabled(any()));
    });
  });

  group('CrashlyticsErrorReporter.recordFatal', () {
    test('records the error as fatal with its stack trace and reason, '
        'without printing it again', () async {
      stubRecordError(() async {});
      final error = StateError('uncaught');

      await reporter.recordFatal(error, stack, reason: 'Uncaught error');

      verify(
        () => crashlytics.recordError(
          error,
          stack,
          reason: 'Uncaught error',
          fatal: true,
          printDetails: false,
        ),
      ).called(1);
    });

    test('reports even a Failure, because nothing handled it', () async {
      stubRecordError(() async {});

      await reporter.recordFatal(
        const NetworkFailure(),
        stack,
        reason: 'Uncaught error',
      );

      verify(anyRecordError).called(1);
    });

    test('does not throw when Crashlytics fails with an Error, so a '
        'reporting failure cannot trigger another report', () async {
      stubRecordError(() async => throw StateError('plugin crashed'));

      await expectLater(
        reporter.recordFatal(StateError('x'), stack, reason: 'Uncaught error'),
        completes,
      );
      await expectLater(
        reporter.recordNonFatal(StateError('y'), stack, reason: 'Signing in'),
        completes,
      );
    });
  });
}
