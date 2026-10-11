import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/core/error/error_reporter.dart';
import 'package:splitzy/core/error/failures.dart';

/// Runs a controller [action] and turns its outcome into the state to show.
///
/// - Success: `AsyncData(null)`.
/// - A known [Failure]: `AsyncError(failure, stackTrace)`. It is an expected
///   outcome with its own message, so it is not reported.
/// - Anything else: reported through [reporter] as non-fatal with its
///   original stack trace and [reason] (the operation, e.g. `'Logging in'`),
///   then `AsyncError(UnexpectedFailure(), stackTrace)`, so the UI shows the
///   generic message and never technical details.
///
/// Never throws.
Future<AsyncValue<void>> runGuarded(
  Future<void> Function() action, {
  required ErrorReporter reporter,
  required String reason,
}) async {
  try {
    await action();
    return const AsyncData(null);
  } on Failure catch (failure, stackTrace) {
    return AsyncError(failure, stackTrace);
  } catch (error, stackTrace) {
    // Not awaited: reporting must not delay showing the error. The reporter
    // never throws.
    unawaited(reporter.recordNonFatal(error, stackTrace, reason: reason));
    return AsyncError(const UnexpectedFailure(), stackTrace);
  }
}
