import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:splitzy/core/error/error_reporter.dart';

/// Sends errors that nothing in the app caught to [reporter] as fatal, after
/// printing them to the console exactly as Flutter does by default.
///
/// - [FlutterError.onError]: errors the Flutter framework caught (build,
///   layout, paint, gestures, ...).
/// - [PlatformDispatcher.onError]: uncaught asynchronous errors.
///
/// Errors handled by controllers (`runGuarded`) never reach these handlers,
/// so nothing is reported twice. Call once, after `Firebase.initializeApp`
/// and before `runApp`.
void installGlobalErrorHandlers(ErrorReporter reporter) {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    unawaited(
      reporter.recordFatal(
        details.exception,
        details.stack ?? StackTrace.empty,
        reason: _flutterErrorReason(details),
      ),
    );
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    FlutterError.presentError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'splitzy',
        context: ErrorDescription('while running asynchronous code'),
      ),
    );
    unawaited(
      reporter.recordFatal(
        error,
        stackTrace,
        reason: 'Uncaught asynchronous error',
      ),
    );
    // Handled: the error has been printed and reported.
    return true;
  };
}

String _flutterErrorReason(FlutterErrorDetails details) {
  final context = details.context?.toDescription().trim();
  return context == null || context.isEmpty
      ? 'Uncaught Flutter framework error'
      : 'Uncaught Flutter framework error $context';
}
