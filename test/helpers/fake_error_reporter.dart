import 'package:splitzy/core/error/error_reporter.dart';

/// One call to [FakeErrorReporter].
typedef ReportedError = ({Object error, StackTrace stackTrace, String reason});

/// In-memory [ErrorReporter] for tests: records every reported error instead
/// of sending it anywhere.
class FakeErrorReporter implements ErrorReporter {
  final nonFatal = <ReportedError>[];
  final fatal = <ReportedError>[];

  @override
  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
  }) async {
    nonFatal.add((error: error, stackTrace: stackTrace, reason: reason));
  }

  @override
  Future<void> recordFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
  }) async {
    fatal.add((error: error, stackTrace: stackTrace, reason: reason));
  }
}
