import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:splitzy/features/auth/data/exceptions/auth_exceptions.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockUserCredential extends Mock implements UserCredential {}

class _MockUser extends Mock implements User {}

class _MockUserInfo extends Mock implements UserInfo {}

void main() {
  late _MockFirebaseAuth auth;
  late FirebaseAuthDataSource dataSource;

  setUp(() {
    auth = _MockFirebaseAuth();
    dataSource = FirebaseAuthDataSource(auth);
  });

  group('FirebaseAuthDataSource', () {
    test('userChanges returns the FirebaseAuth stream', () {
      final user = _MockUser();
      when(() => auth.userChanges()).thenAnswer((_) => Stream.value(user));

      expect(dataSource.userChanges(), emits(user));
    });

    test('signInWithEmailAndPassword forwards the credentials', () async {
      final credential = _MockUserCredential();
      when(
        () => auth.signInWithEmailAndPassword(
          email: 'sam@example.com',
          password: 'pw',
        ),
      ).thenAnswer((_) async => credential);

      final result = await dataSource.signInWithEmailAndPassword(
        email: 'sam@example.com',
        password: 'pw',
      );

      expect(result, same(credential));
    });

    test('createUserWithEmailAndPassword forwards the credentials', () async {
      final credential = _MockUserCredential();
      when(
        () => auth.createUserWithEmailAndPassword(
          email: 'sam@example.com',
          password: 'secret12',
        ),
      ).thenAnswer((_) async => credential);

      final result = await dataSource.createUserWithEmailAndPassword(
        email: 'sam@example.com',
        password: 'secret12',
      );

      expect(result, same(credential));
    });

    test('updateDisplayName updates the given user', () async {
      final user = _MockUser();
      when(() => user.updateDisplayName('Sam Lee')).thenAnswer((_) async {});

      await dataSource.updateDisplayName(user, 'Sam Lee');

      verify(() => user.updateDisplayName('Sam Lee')).called(1);
    });

    test('signOut signs out of FirebaseAuth', () async {
      when(() => auth.signOut()).thenAnswer((_) async {});

      await dataSource.signOut();

      verify(() => auth.signOut()).called(1);
    });
  });

  group('Google', () {
    setUpAll(
      () => registerFallbackValue(GoogleAuthProvider.credential(idToken: 'x')),
    );

    test(
      'signs in to Firebase with a Google credential for the token',
      () async {
        final credential = _MockUserCredential();
        when(
          () => auth.signInWithCredential(any()),
        ).thenAnswer((_) async => credential);

        final result = await dataSource.signInWithGoogleIdToken('google-token');

        expect(result, same(credential));
        final sent =
            verify(
                  () => auth.signInWithCredential(captureAny()),
                ).captured.single
                as OAuthCredential;
        expect(sent.providerId, GoogleAuthProvider.PROVIDER_ID);
        expect(sent.idToken, 'google-token');
      },
    );

    test('translates Firebase errors from the Google sign-in', () async {
      when(() => auth.signInWithCredential(any())).thenAnswer(
        (_) async => throw FirebaseAuthException(
          code: 'account-exists-with-different-credential',
        ),
      );

      await expectLater(
        dataSource.signInWithGoogleIdToken('google-token'),
        throwsA(isA<AccountExistsWithDifferentCredentialException>()),
      );
    });

    UserInfo provider(String id) {
      final info = _MockUserInfo();
      when(() => info.providerId).thenReturn(id);
      return info;
    }

    test('isSignedInWithGoogle reflects the user sign-in methods', () {
      final user = _MockUser();
      final password = provider('password');
      final google = provider('google.com');
      when(() => auth.currentUser).thenReturn(user);

      when(() => user.providerData).thenReturn([password]);
      expect(dataSource.isSignedInWithGoogle, isFalse);

      when(() => user.providerData).thenReturn([password, google]);
      expect(dataSource.isSignedInWithGoogle, isTrue);
    });

    test('isSignedInWithGoogle is false when signed out', () {
      when(() => auth.currentUser).thenReturn(null);

      expect(dataSource.isSignedInWithGoogle, isFalse);
    });
  });

  group('error translation', () {
    final originalStack = StackTrace.fromString('original-firebase-stack');

    /// Firebase reports failures through the returned Future.
    Future<T> firebaseFails<T>(String code) =>
        Future.error(FirebaseAuthException(code: code), originalStack);

    void stubSignInFailure(Future<UserCredential> Function() answer) {
      when(
        () => auth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => answer());
    }

    test('turns a Firebase error into a project exception', () async {
      stubSignInFailure(() => firebaseFails('invalid-credential'));

      await expectLater(
        dataSource.signInWithEmailAndPassword(email: 'a@b.co', password: 'x'),
        throwsA(isA<InvalidCredentialsException>()),
      );
    });

    test('keeps the original stack trace', () async {
      stubSignInFailure(() => firebaseFails('network-request-failed'));

      try {
        await dataSource.signInWithEmailAndPassword(
          email: 'a@b.co',
          password: 'x',
        );
        fail('expected a NetworkException');
      } on NetworkException catch (_, stackTrace) {
        expect(stackTrace.toString(), originalStack.toString());
      }
    });

    test('translates errors from every call', () async {
      final user = _MockUser();
      when(
        () => auth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) => firebaseFails('email-already-in-use'));
      when(
        () => user.updateDisplayName(any()),
      ).thenAnswer((_) => firebaseFails('network-request-failed'));
      when(
        () => auth.signOut(),
      ).thenAnswer((_) => firebaseFails('too-many-requests'));

      await expectLater(
        dataSource.createUserWithEmailAndPassword(
          email: 'a@b.co',
          password: 'secret12',
        ),
        throwsA(isA<EmailAlreadyInUseException>()),
      );
      await expectLater(
        dataSource.updateDisplayName(user, 'Sam'),
        throwsA(isA<NetworkException>()),
      );
      await expectLater(
        dataSource.signOut(),
        throwsA(isA<TooManyRequestsException>()),
      );
    });

    test('lets errors that are not from Firebase pass through', () async {
      final error = StateError('not a Firebase error');
      stubSignInFailure(() => Future.error(error, originalStack));

      await expectLater(
        dataSource.signInWithEmailAndPassword(email: 'a@b.co', password: 'x'),
        throwsA(same(error)),
      );
    });

    test('translates Firebase errors on the user stream', () {
      when(() => auth.userChanges()).thenAnswer(
        (_) => Stream.error(
          FirebaseAuthException(code: 'network-request-failed'),
          originalStack,
        ),
      );

      expect(dataSource.userChanges(), emitsError(isA<NetworkException>()));
    });
  });
}
