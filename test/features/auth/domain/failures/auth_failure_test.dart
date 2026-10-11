import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/auth/domain/failures/auth_failure.dart';
import 'package:splitzy/features/auth/domain/validation/auth_validation.dart';

void main() {
  group('AuthFailure', () {
    test('is a shared Failure', () {
      expect(const InvalidCredentials(), isA<Failure>());
    });

    test('each failure carries its user-facing message', () {
      final expected = <AuthFailure, String>{
        const InvalidCredentials(): 'Incorrect email or password.',
        const EmailAlreadyInUse(): 'An account with this email already exists.',
        const WeakPassword():
            "This password doesn't meet the requirements. "
            'Use at least 8 characters.',
        const InvalidEmail(): 'Enter a valid email address.',
        const UserDisabled(): 'This account has been disabled.',
        const TooManyRequests():
            'Too many attempts. Please wait a moment and try again.',
        const AccountExistsWithDifferentCredential():
            'An account with this email already exists. '
            'Log in with the method you used before.',
      };

      for (final MapEntry(key: failure, value: message) in expected.entries) {
        expect(failure.message, message, reason: '$failure');
      }
    });

    test('InvalidInput uses its validation error message', () {
      for (final error in ValidationError.values) {
        expect(InvalidInput(error).message, error.message, reason: '$error');
      }
    });

    test('UnknownAuthFailure shows the generic message, never its code', () {
      const failure = UnknownAuthFailure('internal-error');

      expect(failure.message, const UnexpectedFailure().message);
      expect(failure.message, isNot(contains('internal-error')));
    });
  });
}
