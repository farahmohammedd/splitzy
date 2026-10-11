import 'package:google_sign_in/google_sign_in.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/auth/data/exceptions/auth_exceptions.dart';

/// Translates a Google Sign-In error into a project exception.
///
/// Only an explicit user cancellation is a cancellation; every other code
/// (interrupted flow, misconfiguration, no UI available, ...) becomes an
/// [UnknownAuthException] that keeps the code for debugging.
AppException mapGoogleSignInException(GoogleSignInException exception) {
  return switch (exception.code) {
    GoogleSignInExceptionCode.canceled =>
      const GoogleSignInCancelledException(),
    final code => UnknownAuthException('google-sign-in-${code.name}'),
  };
}
