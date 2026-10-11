import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:splitzy/features/auth/data/exceptions/auth_exceptions.dart';
import 'package:splitzy/features/auth/data/mappers/google_sign_in_exception_mapper.dart';

void main() {
  group('mapGoogleSignInException', () {
    test('maps a user cancellation to GoogleSignInCancelledException', () {
      expect(
        mapGoogleSignInException(
          const GoogleSignInException(code: GoogleSignInExceptionCode.canceled),
        ),
        isA<GoogleSignInCancelledException>(),
      );
    });

    test('maps every other code to UnknownAuthException with the code', () {
      final others = GoogleSignInExceptionCode.values.where(
        (code) => code != GoogleSignInExceptionCode.canceled,
      );

      for (final code in others) {
        expect(
          mapGoogleSignInException(GoogleSignInException(code: code)),
          isA<UnknownAuthException>().having(
            (e) => e.code,
            'code',
            'google-sign-in-${code.name}',
          ),
          reason: code.name,
        );
      }
    });
  });
}
