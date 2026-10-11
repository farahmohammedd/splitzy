/// Why an authentication input was rejected.
enum ValidationError {
  emailRequired,
  emailInvalid,
  passwordRequired,
  passwordTooShort,
  passwordsDoNotMatch,
  fullNameRequired,
  fullNameTooLong;

  /// The text shown under the rejected form field.
  String get message {
    return switch (this) {
      emailRequired => 'Enter your email.',
      emailInvalid => 'Enter a valid email address.',
      passwordRequired => 'Enter your password.',
      passwordTooShort =>
        'Use at least ${AuthValidation.minPasswordLength} characters.',
      passwordsDoNotMatch => "Passwords don't match.",
      fullNameRequired => 'Enter your full name.',
      fullNameTooLong =>
        'Name must be ${AuthValidation.maxFullNameLength} characters or fewer.',
    };
  }
}

/// Input rules for signing in and registering. Each check returns the first
/// problem found, or `null` when the input is valid.
abstract final class AuthValidation {
  static const int minPasswordLength = 8;
  static const int maxFullNameLength = 50;

  /// A basic `local@domain.tld` shape with no spaces. Firebase remains the
  /// authority on whether an address is actually valid.
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  /// Checks an email address, ignoring surrounding whitespace.
  static ValidationError? email(String email) {
    final value = email.trim();
    if (value.isEmpty) return ValidationError.emailRequired;
    if (!_emailPattern.hasMatch(value)) return ValidationError.emailInvalid;
    return null;
  }

  /// Sign-in only requires a password; its rules are enforced at sign-up.
  static ValidationError? signInPassword(String password) {
    return password.isEmpty ? ValidationError.passwordRequired : null;
  }

  /// Checks a password chosen at registration. Passwords are not trimmed.
  static ValidationError? newPassword(String password) {
    if (password.isEmpty) return ValidationError.passwordRequired;
    if (password.length < minPasswordLength) {
      return ValidationError.passwordTooShort;
    }
    return null;
  }

  static ValidationError? passwordConfirmation(
    String password,
    String confirmation,
  ) {
    return confirmation == password
        ? null
        : ValidationError.passwordsDoNotMatch;
  }

  /// Checks a full name, ignoring surrounding whitespace.
  static ValidationError? fullName(String fullName) {
    final value = fullName.trim();
    if (value.isEmpty) return ValidationError.fullNameRequired;
    if (value.length > maxFullNameLength) {
      return ValidationError.fullNameTooLong;
    }
    return null;
  }
}
