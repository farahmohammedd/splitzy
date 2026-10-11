import 'dart:developer' as developer;

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:splitzy/core/error/error_reporter.dart';
import 'package:splitzy/core/error/failures.dart';

/// [ErrorReporter] backed by Firebase Crashlytics. The only class that uses
/// the Crashlytics SDK.
///
/// Whether reports are actually sent is decided once in `main()` (off in
/// debug, on otherwise), so this class never changes the collection setting.
/// In debug builds Crashlytics still prints each non-fatal error to the
/// console.
class CrashlyticsErrorReporter implements ErrorReporter {
  const CrashlyticsErrorReporter(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
  }) async {
    // Known failures are expected outcomes shown to the user, not crashes.
    if (error is Failure) return;

    await _record(error, stackTrace, reason: reason, fatal: false);
  }

  @override
  Future<void> recordFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
  }) {
    // Every uncaught error is reported, even a Failure: it should have been
    // handled. The global handlers already printed it, so do not print again.
    return _record(
      error,
      stackTrace,
      reason: reason,
      fatal: true,
      printDetails: false,
    );
  }

  Future<void> _record(
    Object error,
    StackTrace stackTrace, {
    required String reason,
    required bool fatal,
    bool? printDetails,
  }) async {
    try {
      await _crashlytics.recordError(
        error,
        stackTrace,
        reason: reason,
        fatal: fatal,
        printDetails: printDetails,
      );
      // Catches everything, not only Exceptions: a reporting failure that
      // escaped would reach the global handlers and be reported again.
    } catch (reportingError, reportingStack) {
      // Reporting must never break the app; keep a local trace instead.
      developer.log(
        'Could not report an error to Crashlytics ($reason).',
        name: 'splitzy.error',
        error: reportingError,
        stackTrace: reportingStack,
      );
    }
  }
}
