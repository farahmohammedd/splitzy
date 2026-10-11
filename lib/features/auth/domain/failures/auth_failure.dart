import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/auth/domain/validation/auth_validation.dart';

/// Why an authentication operation failed, in domain terms, with the text to
/// show the user.
///
/// Thrown by the auth repository and use cases; controllers turn it into an
/// `AsyncError` through `runGuarded`. Firebase exceptions never cross out of
/// the data layer. Shared failures such as `NetworkFailure` come from
/// `core/error/failures.dart`.
sealed class AuthFailure extends Failure {
  const AuthFailure();
}

/// The input broke a validation rule; nothing was sent to Firebase.
final class InvalidInput extends AuthFailure {
  const InvalidInput(this.error);

  final ValidationError error;

  @override
  String get message => error.message;

  @override
  String toString() => 'InvalidInput($error)';
}

/// Wrong email or password (Firebase does not say which).
final class InvalidCredentials extends AuthFailure {
  const InvalidCredentials();

  @override
  String get message => 'Incorrect email or password.';
}

final class EmailAlreadyInUse extends AuthFailure {
  const EmailAlreadyInUse();

  @override
  String get message => 'An account with this email already exists.';
}

/// The password does not meet Firebase's password requirements.
final class WeakPassword extends AuthFailure {
  const WeakPassword();

  @override
  String get message =>
      "This password doesn't meet the requirements. "
      'Use at least ${AuthValidation.minPasswordLength} characters.';
}

/// Firebase rejected the email address format.
final class InvalidEmail extends AuthFailure {
  const InvalidEmail();

  @override
  String get message => 'Enter a valid email address.';
}

final class UserDisabled extends AuthFailure {
  const UserDisabled();

  @override
  String get message => 'This account has been disabled.';
}

final class TooManyRequests extends AuthFailure {
  const TooManyRequests();

  @override
  String get message =>
      'Too many attempts. Please wait a moment and try again.';
}

/// The email already belongs to an account that uses a different sign-in
/// method.
final class AccountExistsWithDifferentCredential extends AuthFailure {
  const AccountExistsWithDifferentCredential();

  @override
  String get message =>
      'An account with this email already exists. '
      'Log in with the method you used before.';
}

/// Any other failure; [code] keeps the original error code for debugging and
/// is never shown to the user.
final class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure(this.code);

  final String code;

  @override
  String get message => const UnexpectedFailure().message;

  @override
  String toString() => 'UnknownAuthFailure($code)';
}
