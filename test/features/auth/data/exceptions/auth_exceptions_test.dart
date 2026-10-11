import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/auth/data/exceptions/auth_exceptions.dart';

void main() {
  group('AuthException', () {
    test('every auth exception is a project exception', () {
      const exceptions = <AuthException>[
        InvalidCredentialsException(),
        EmailAlreadyInUseException(),
        WeakPasswordException(),
        InvalidEmailException(),
        UserDisabledException(),
        TooManyRequestsException(),
        AccountExistsWithDifferentCredentialException(),
        UnknownAuthException('internal-error'),
      ];

      for (final exception in exceptions) {
        expect(exception, isA<AppException>(), reason: '$exception');
      }
    });

    test('UnknownAuthException keeps the original code for debugging', () {
      const exception = UnknownAuthException('internal-error');

      expect(exception.code, 'internal-error');
      expect(exception.toString(), 'UnknownAuthException(internal-error)');
    });
  });
}
