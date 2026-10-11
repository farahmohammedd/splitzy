import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/auth/data/exceptions/auth_exceptions.dart';
import 'package:splitzy/features/auth/data/mappers/firebase_auth_exception_mapper.dart';

AppException _map(String code) =>
    mapFirebaseAuthException(FirebaseAuthException(code: code));

void main() {
  group('mapFirebaseAuthException', () {
    test('maps every credential error to InvalidCredentialsException', () {
      for (final code in [
        'invalid-credential',
        'invalid-login-credentials',
        'wrong-password',
        'user-not-found',
      ]) {
        expect(_map(code), isA<InvalidCredentialsException>(), reason: code);
      }
    });

    test('maps both password-rule errors to WeakPasswordException', () {
      for (final code in [
        'weak-password',
        'password-does-not-meet-requirements',
      ]) {
        expect(_map(code), isA<WeakPasswordException>(), reason: code);
      }
    });

    test('maps the remaining known codes to their exceptions', () {
      final expected = <String, TypeMatcher<AppException>>{
        'email-already-in-use': isA<EmailAlreadyInUseException>(),
        'invalid-email': isA<InvalidEmailException>(),
        'user-disabled': isA<UserDisabledException>(),
        'too-many-requests': isA<TooManyRequestsException>(),
        'account-exists-with-different-credential':
            isA<AccountExistsWithDifferentCredentialException>(),
        'network-request-failed': isA<NetworkException>(),
      };

      for (final MapEntry(key: code, value: matcher) in expected.entries) {
        expect(_map(code), matcher, reason: code);
      }
    });

    test('maps an unknown code to UnknownAuthException, keeping the code', () {
      expect(
        _map('operation-not-allowed'),
        isA<UnknownAuthException>().having(
          (e) => e.code,
          'code',
          'operation-not-allowed',
        ),
      );
    });

    test('maps an empty code to UnknownAuthException', () {
      expect(
        _map(''),
        isA<UnknownAuthException>().having((e) => e.code, 'code', ''),
      );
    });

    test('translates Firebase errors from other plugins too', () {
      final result = mapFirebaseAuthException(
        FirebaseException(plugin: 'firebase_core', code: 'unknown'),
      );

      expect(
        result,
        isA<UnknownAuthException>().having((e) => e.code, 'code', 'unknown'),
      );
    });
  });
}
