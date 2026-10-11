import 'package:firebase_auth/firebase_auth.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/auth/data/exceptions/auth_exceptions.dart';

/// Translates a Firebase error into a project exception, by error code.
///
/// Accepts any [FirebaseException] (including [FirebaseAuthException]) so a
/// Firebase error from another plugin is still translated, never leaked.
AppException mapFirebaseAuthException(FirebaseException exception) {
  return switch (exception.code) {
    // With email-enumeration protection Firebase mostly reports
    // `invalid-credential`; the older codes mean the same thing.
    'invalid-credential' ||
    'invalid-login-credentials' ||
    'wrong-password' ||
    'user-not-found' => const InvalidCredentialsException(),
    'email-already-in-use' => const EmailAlreadyInUseException(),
    // `password-does-not-meet-requirements` comes from the Console password
    // policy.
    'weak-password' ||
    'password-does-not-meet-requirements' => const WeakPasswordException(),
    'invalid-email' => const InvalidEmailException(),
    'user-disabled' => const UserDisabledException(),
    'too-many-requests' => const TooManyRequestsException(),
    'account-exists-with-different-credential' =>
      const AccountExistsWithDifferentCredentialException(),
    'network-request-failed' => const NetworkException(),
    final code => UnknownAuthException(code),
  };
}
