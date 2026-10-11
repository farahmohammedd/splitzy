import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/features/auth/domain/validation/auth_validation.dart';

void main() {
  group('AuthValidation.email', () {
    test('requires an address', () {
      expect(AuthValidation.email(''), ValidationError.emailRequired);
      expect(AuthValidation.email('   '), ValidationError.emailRequired);
    });

    test('accepts a basic local@domain.tld address', () {
      expect(AuthValidation.email('sam@example.com'), isNull);
      expect(AuthValidation.email('sam.lee+split@mail.example.co'), isNull);
    });

    test('ignores surrounding whitespace', () {
      expect(AuthValidation.email('  sam@example.com '), isNull);
    });

    test('rejects addresses without the basic shape', () {
      for (final email in [
        'sam',
        'sam@',
        '@example.com',
        'sam@example',
        'sam@example.',
        'sam@@example.com',
        'sam lee@example.com',
        'sam@exa mple.com',
      ]) {
        expect(
          AuthValidation.email(email),
          ValidationError.emailInvalid,
          reason: email,
        );
      }
    });
  });

  group('AuthValidation.signInPassword', () {
    test('requires a password', () {
      expect(
        AuthValidation.signInPassword(''),
        ValidationError.passwordRequired,
      );
    });

    test('accepts any non-empty password, however short', () {
      expect(AuthValidation.signInPassword('a'), isNull);
      expect(AuthValidation.signInPassword(' '), isNull);
    });
  });

  group('AuthValidation.newPassword', () {
    test('requires a password', () {
      expect(AuthValidation.newPassword(''), ValidationError.passwordRequired);
    });

    test('rejects passwords shorter than 8 characters', () {
      expect(
        AuthValidation.newPassword('1234567'),
        ValidationError.passwordTooShort,
      );
    });

    test('accepts passwords of 8 characters or more', () {
      expect(AuthValidation.newPassword('12345678'), isNull);
      expect(AuthValidation.newPassword('a much longer passphrase'), isNull);
    });

    test('counts whitespace because passwords are not trimmed', () {
      expect(AuthValidation.newPassword(' secret '), isNull);
      expect(
        AuthValidation.newPassword('       '),
        ValidationError.passwordTooShort,
      );
    });
  });

  group('AuthValidation.passwordConfirmation', () {
    test('accepts an identical confirmation', () {
      expect(
        AuthValidation.passwordConfirmation('secret12', 'secret12'),
        isNull,
      );
    });

    test('rejects a different or empty confirmation', () {
      expect(
        AuthValidation.passwordConfirmation('secret12', 'secret13'),
        ValidationError.passwordsDoNotMatch,
      );
      expect(
        AuthValidation.passwordConfirmation('secret12', ''),
        ValidationError.passwordsDoNotMatch,
      );
    });

    test('compares exactly, including whitespace', () {
      expect(
        AuthValidation.passwordConfirmation('secret12', 'secret12 '),
        ValidationError.passwordsDoNotMatch,
      );
    });
  });

  group('AuthValidation.fullName', () {
    test('requires a name', () {
      expect(AuthValidation.fullName(''), ValidationError.fullNameRequired);
      expect(AuthValidation.fullName('   '), ValidationError.fullNameRequired);
    });

    test('accepts 1 to 50 characters after trimming', () {
      expect(AuthValidation.fullName('S'), isNull);
      expect(AuthValidation.fullName('a' * 50), isNull);
      expect(AuthValidation.fullName('  ${'a' * 50}  '), isNull);
    });

    test('rejects names longer than 50 characters', () {
      expect(
        AuthValidation.fullName('a' * 51),
        ValidationError.fullNameTooLong,
      );
    });
  });

  group('ValidationError.message', () {
    test('each error has its form-field message', () {
      final expected = {
        ValidationError.emailRequired: 'Enter your email.',
        ValidationError.emailInvalid: 'Enter a valid email address.',
        ValidationError.passwordRequired: 'Enter your password.',
        ValidationError.passwordTooShort: 'Use at least 8 characters.',
        ValidationError.passwordsDoNotMatch: "Passwords don't match.",
        ValidationError.fullNameRequired: 'Enter your full name.',
        ValidationError.fullNameTooLong: 'Name must be 50 characters or fewer.',
      };

      expect(expected.keys, containsAll(ValidationError.values));
      for (final MapEntry(key: error, value: message) in expected.entries) {
        expect(error.message, message, reason: '$error');
      }
    });
  });
}
