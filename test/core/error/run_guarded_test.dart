import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/core/error/run_guarded.dart';

import '../../helpers/fake_error_reporter.dart';

void main() {
  late FakeErrorReporter reporter;
  final originalStack = StackTrace.fromString('original-stack');

  setUp(() => reporter = FakeErrorReporter());

  Future<AsyncValue<void>> guard(Future<void> Function() action) =>
      runGuarded(action, reporter: reporter, reason: 'Testing an action');

  group('runGuarded', () {
    test('returns data when the action succeeds', () async {
      var ran = false;

      final result = await guard(() async => ran = true);

      expect(result, const AsyncData<void>(null));
      expect(ran, isTrue);
      expect(reporter.nonFatal, isEmpty);
    });

    test('returns a known failure as an error without reporting it', () async {
      final result = await guard(
        () => Future.error(const NetworkFailure(), originalStack),
      );

      expect(result.error, isA<NetworkFailure>());
      expect(result.stackTrace.toString(), originalStack.toString());
      expect(reporter.nonFatal, isEmpty);
    });

    test('reports an unexpected error as non-fatal with its original stack '
        'trace and reason', () async {
      final error = StateError('bug');

      await guard(() => Future.error(error, originalStack));

      final report = reporter.nonFatal.single;
      expect(report.error, same(error));
      expect(report.stackTrace.toString(), originalStack.toString());
      expect(report.reason, 'Testing an action');
    });

    test('turns an unexpected error into UnexpectedFailure with the original '
        'stack trace', () async {
      final result = await guard(
        () => Future.error(Exception('socket closed'), originalStack),
      );

      expect(result.error, isA<UnexpectedFailure>());
      expect(result.stackTrace.toString(), originalStack.toString());
      expect(messageFor(result.error), const UnexpectedFailure().message);
    });

    test('also handles errors thrown synchronously by the action', () async {
      final result = await guard(() => throw StateError('thrown immediately'));

      expect(result.error, isA<UnexpectedFailure>());
      expect(reporter.nonFatal, hasLength(1));
    });
  });
}
