import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/auth/data/datasources/google_sign_in_data_source.dart';
import 'package:splitzy/features/auth/data/exceptions/auth_exceptions.dart';

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

class _MockAccount extends Mock implements GoogleSignInAccount {}

void main() {
  late _MockGoogleSignIn googleSignIn;
  late GoogleSignInDataSource dataSource;
  final originalStack = StackTrace.fromString('original-google-stack');

  setUp(() {
    googleSignIn = _MockGoogleSignIn();
    dataSource = GoogleSignInDataSource(googleSignIn);
    when(() => googleSignIn.initialize()).thenAnswer((_) async {});
  });

  _MockAccount accountWithIdToken(String? idToken) {
    final account = _MockAccount();
    when(
      () => account.authentication,
    ).thenReturn(GoogleSignInAuthentication(idToken: idToken));
    return account;
  }

  group('authenticate', () {
    test('returns the chosen account ID token', () async {
      final account = accountWithIdToken('google-id-token');
      when(() => googleSignIn.authenticate()).thenAnswer((_) async => account);

      expect(await dataSource.authenticate(), 'google-id-token');
    });

    test('initializes Google Sign-In once, before the first use', () async {
      final account = accountWithIdToken('google-id-token');
      when(() => googleSignIn.authenticate()).thenAnswer((_) async => account);
      when(() => googleSignIn.signOut()).thenAnswer((_) async {});

      await dataSource.authenticate();
      await dataSource.authenticate();
      await dataSource.signOut();

      verify(() => googleSignIn.initialize()).called(1);
    });

    test('retries initialization after it failed', () async {
      var attempts = 0;
      when(() => googleSignIn.initialize()).thenAnswer((_) async {
        if (++attempts == 1) {
          throw const GoogleSignInException(
            code: GoogleSignInExceptionCode.providerConfigurationError,
          );
        }
      });
      final account = accountWithIdToken('google-id-token');
      when(() => googleSignIn.authenticate()).thenAnswer((_) async => account);

      await expectLater(
        dataSource.authenticate(),
        throwsA(isA<UnknownAuthException>()),
      );
      expect(await dataSource.authenticate(), 'google-id-token');
      expect(attempts, 2);
    });

    test(
      'turns a cancelled picker into GoogleSignInCancelledException, keeping '
      'the stack trace',
      () async {
        when(() => googleSignIn.authenticate()).thenAnswer(
          (_) => Future.error(
            const GoogleSignInException(
              code: GoogleSignInExceptionCode.canceled,
            ),
            originalStack,
          ),
        );

        try {
          await dataSource.authenticate();
          fail('expected GoogleSignInCancelledException');
        } on GoogleSignInCancelledException catch (_, stackTrace) {
          expect(stackTrace.toString(), originalStack.toString());
        }
      },
    );

    test('turns other Google errors into project exceptions', () async {
      when(() => googleSignIn.authenticate()).thenAnswer(
        (_) => Future.error(
          const GoogleSignInException(
            code: GoogleSignInExceptionCode.clientConfigurationError,
          ),
        ),
      );

      await expectLater(
        dataSource.authenticate(),
        throwsA(isA<AppException>()),
      );
    });

    test('reports a missing ID token as an unknown auth error', () async {
      final account = accountWithIdToken(null);
      when(() => googleSignIn.authenticate()).thenAnswer((_) async => account);

      await expectLater(
        dataSource.authenticate(),
        throwsA(
          isA<UnknownAuthException>().having(
            (e) => e.code,
            'code',
            'google-sign-in-missing-id-token',
          ),
        ),
      );
    });
  });

  group('signOut', () {
    test('ends the Google session', () async {
      when(() => googleSignIn.signOut()).thenAnswer((_) async {});

      await dataSource.signOut();

      verify(() => googleSignIn.signOut()).called(1);
    });
  });
}
