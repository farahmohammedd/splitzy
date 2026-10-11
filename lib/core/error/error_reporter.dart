/// Reports unexpected errors to a crash-reporting service, without the rest
/// of the app knowing which service it is.
///
/// Only for errors the app did not anticipate. Expected `Failure`s (wrong
/// password, no connection, ...) are shown to the user and never reported as
/// non-fatal. Both methods never throw: reporting must not break the app or
/// trigger another report.
abstract interface class ErrorReporter {
  /// Records an unexpected error that the app caught and recovered from.
  ///
  /// [stackTrace] should be the error's original stack trace. [reason]
  /// identifies the operation that failed, e.g. `'Saving the display name
  /// after registration'`.
  Future<void> recordNonFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
  });

  /// Records an error that nothing in the app caught (reported by the global
  /// error handlers). The caller has already printed it to the console.
  Future<void> recordFatal(
    Object error,
    StackTrace stackTrace, {
    required String reason,
  });
}
