/// An application-level failure, in domain terms, with the text to show the
/// user.
///
/// Shared failures live here; feature-specific families (e.g. `AuthFailure`)
/// extend this class in their own feature's domain layer.
abstract class Failure implements Exception {
  const Failure();

  /// A short, user-facing explanation. Never contains technical details.
  String get message;
}

/// The backend could not be reached (e.g. no internet connection).
final class NetworkFailure extends Failure {
  const NetworkFailure();

  @override
  String get message =>
      'No internet connection. Check your network and try again.';
}

/// Something went wrong that the app did not anticipate. Its message is the
/// safe generic fallback for any error that is not a known [Failure].
final class UnexpectedFailure extends Failure {
  const UnexpectedFailure();

  @override
  String get message => 'Something went wrong. Please try again.';
}

/// The text to show the user for [error]: a [Failure]'s own message, or the
/// generic fallback for anything else.
String messageFor(Object? error) {
  return error is Failure ? error.message : const UnexpectedFailure().message;
}
