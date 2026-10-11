import 'package:splitzy/core/error/exceptions.dart';

/// Authentication errors reported by the auth data source, independent of
/// the SDK that produced them. Shared errors such as `NetworkException` come
/// from `core/error/exceptions.dart`.
sealed class AuthException extends AppException {
  const AuthException();
}

/// Wrong email or password (the backend does not say which).
final class InvalidCredentialsException extends AuthException {
  const InvalidCredentialsException();
}

final class EmailAlreadyInUseException extends AuthException {
  const EmailAlreadyInUseException();
}

/// The password does not meet the backend's password requirements.
final class WeakPasswordException extends AuthException {
  const WeakPasswordException();
}

/// The backend rejected the email address format.
final class InvalidEmailException extends AuthException {
  const InvalidEmailException();
}

final class UserDisabledException extends AuthException {
  const UserDisabledException();
}

final class TooManyRequestsException extends AuthException {
  const TooManyRequestsException();
}

/// The email already belongs to an account that uses a different sign-in
/// method.
final class AccountExistsWithDifferentCredentialException
    extends AuthException {
  const AccountExistsWithDifferentCredentialException();
}

/// Any other authentication error; [code] keeps the original error code for
/// debugging.
final class UnknownAuthException extends AuthException {
  const UnknownAuthException(this.code);

  final String code;

  @override
  String toString() => 'UnknownAuthException($code)';
}

/// The user closed the Google account picker. Not an authentication error,
/// so it is not part of [AuthException]: the repository treats it as "no
/// sign-in happened".
final class GoogleSignInCancelledException extends AppException {
  const GoogleSignInCancelledException();
}
