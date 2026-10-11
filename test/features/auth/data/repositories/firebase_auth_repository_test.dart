import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:splitzy/features/auth/data/datasources/google_sign_in_data_source.dart';
import 'package:splitzy/features/auth/data/exceptions/auth_exceptions.dart';
import 'package:splitzy/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/domain/failures/auth_failure.dart';

import '../../../../helpers/fake_error_reporter.dart';

class _MockDataSource extends Mock implements FirebaseAuthDataSource {}

class _MockGoogleDataSource extends Mock implements GoogleSignInDataSource {}

class _MockUserCredential extends Mock implements UserCredential {}

class _MockUser extends Mock implements User {}

/// A project exception this repository has no mapping for.
class _UnmappedException extends AppException {
  const _UnmappedException();
}

_MockUser _firebaseUser({String? displayName}) {
  final user = _MockUser();
  when(() => user.uid).thenReturn('u1');
  when(() => user.email).thenReturn('sam@example.com');
  when(() => user.displayName).thenReturn(displayName);
  return user;
}

_MockUserCredential _credentialFor(User? user) {
  final credential = _MockUserCredential();
  when(() => credential.user).thenReturn(user);
  return credential;
}

final _originalStack = StackTrace.fromString('original-data-source-stack');

/// The data source reports failures as project exceptions, through the
/// returned Future.
Future<T> _fails<T>(Object error) => Future.error(error, _originalStack);

void main() {
  late _MockDataSource dataSource;
  late _MockGoogleDataSource googleDataSource;
  late FakeErrorReporter errorReporter;
  late FirebaseAuthRepository repository;

  setUpAll(() => registerFallbackValue(_MockUser()));

  setUp(() {
    dataSource = _MockDataSource();
    googleDataSource = _MockGoogleDataSource();
    errorReporter = FakeErrorReporter();
    repository = FirebaseAuthRepository(
      dataSource,
      googleDataSource,
      errorReporter,
    );
    // Signed in with email and password unless a test says otherwise.
    when(() => dataSource.isSignedInWithGoogle).thenReturn(false);
  });

  void stubSignIn(Future<UserCredential> Function() answer) {
    when(
      () => dataSource.signInWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => answer());
  }

  void stubCreate(Future<UserCredential> Function() answer) {
    when(
      () => dataSource.createUserWithEmailAndPassword(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) => answer());
  }

  Future<AppUser> signInSam() =>
      repository.signIn(email: 'sam@example.com', password: 'pw');

  Future<AppUser> registerSam() => repository.register(
    fullName: 'Sam Lee',
    email: 'sam@example.com',
    password: 'secret12',
  );

  group('userChanges', () {
    test('maps Firebase users to AppUser and sign-out to null', () {
      when(() => dataSource.userChanges()).thenAnswer(
        (_) => Stream.fromIterable([_firebaseUser(displayName: 'Sam'), null]),
      );

      expect(
        repository.userChanges(),
        emitsInOrder([
          const AppUser(id: 'u1', email: 'sam@example.com', displayName: 'Sam'),
          null,
        ]),
      );
    });

    test('maps project exceptions on the stream to failures', () {
      when(() => dataSource.userChanges()).thenAnswer(
        (_) => Stream.error(const NetworkException(), _originalStack),
      );

      expect(repository.userChanges(), emitsError(isA<NetworkFailure>()));
    });
  });

  group('signIn', () {
    test('returns the signed-in user', () async {
      stubSignIn(() async => _credentialFor(_firebaseUser(displayName: 'Sam')));

      final user = await signInSam();

      expect(
        user,
        const AppUser(id: 'u1', email: 'sam@example.com', displayName: 'Sam'),
      );
      verify(
        () => dataSource.signInWithEmailAndPassword(
          email: 'sam@example.com',
          password: 'pw',
        ),
      ).called(1);
    });

    test('maps every project exception to its failure', () async {
      final expected = <AppException, TypeMatcher<Failure>>{
        const InvalidCredentialsException(): isA<InvalidCredentials>(),
        const EmailAlreadyInUseException(): isA<EmailAlreadyInUse>(),
        const WeakPasswordException(): isA<WeakPassword>(),
        const InvalidEmailException(): isA<InvalidEmail>(),
        const UserDisabledException(): isA<UserDisabled>(),
        const TooManyRequestsException(): isA<TooManyRequests>(),
        const AccountExistsWithDifferentCredentialException():
            isA<AccountExistsWithDifferentCredential>(),
        const NetworkException(): isA<NetworkFailure>(),
        const UnknownAuthException(
          'operation-not-allowed',
        ): isA<UnknownAuthFailure>().having(
          (f) => f.code,
          'code',
          'operation-not-allowed',
        ),
        const _UnmappedException(): isA<UnexpectedFailure>(),
      };

      for (final MapEntry(key: exception, value: matcher) in expected.entries) {
        stubSignIn(() => _fails(exception));
        await expectLater(signInSam(), throwsA(matcher), reason: '$exception');
      }
    });

    test('keeps the original stack trace when translating', () async {
      stubSignIn(() => _fails(const InvalidCredentialsException()));

      try {
        await signInSam();
        fail('expected InvalidCredentials');
      } on InvalidCredentials catch (_, stackTrace) {
        expect(stackTrace.toString(), _originalStack.toString());
      }
    });

    test('does not report expected failures as unexpected errors', () async {
      for (final exception in const <AppException>[
        InvalidCredentialsException(),
        NetworkException(),
        UnknownAuthException('internal-error'),
      ]) {
        stubSignIn(() => _fails(exception));
        await expectLater(signInSam(), throwsA(isA<Failure>()));
      }

      expect(errorReporter.nonFatal, isEmpty);
    });

    test('lets errors that are not project exceptions pass through', () async {
      final error = StateError('programming error');
      stubSignIn(() => _fails(error));

      await expectLater(signInSam(), throwsA(same(error)));
    });

    test('reports a credential without a user as an unknown failure', () async {
      stubSignIn(() async => _credentialFor(null));

      await expectLater(signInSam(), throwsA(isA<UnknownAuthFailure>()));
    });
  });

  group('register', () {
    test('creates the account and saves the display name', () async {
      final user = _firebaseUser();
      stubCreate(() async => _credentialFor(user));
      when(
        () => dataSource.updateDisplayName(user, 'Sam Lee'),
      ).thenAnswer((_) async {});

      final result = await registerSam();

      expect(
        result,
        const AppUser(
          id: 'u1',
          email: 'sam@example.com',
          displayName: 'Sam Lee',
        ),
      );
      verify(
        () => dataSource.createUserWithEmailAndPassword(
          email: 'sam@example.com',
          password: 'secret12',
        ),
      ).called(1);
      verify(() => dataSource.updateDisplayName(user, 'Sam Lee')).called(1);
    });

    test('retries a failed display-name update once', () async {
      final user = _firebaseUser();
      stubCreate(() async => _credentialFor(user));
      var attempts = 0;
      when(() => dataSource.updateDisplayName(user, 'Sam Lee')).thenAnswer((
        _,
      ) async {
        if (++attempts == 1) throw const UnknownAuthException('internal');
      });

      final result = await registerSam();

      expect(result.displayName, 'Sam Lee');
      expect(attempts, 2);
    });

    test(
      'still succeeds without a display name when both attempts fail',
      () async {
        final user = _firebaseUser();
        stubCreate(() async => _credentialFor(user));
        when(
          () => dataSource.updateDisplayName(user, 'Sam Lee'),
        ).thenAnswer((_) => _fails(const NetworkException()));

        final result = await registerSam();

        expect(
          result,
          const AppUser(id: 'u1', email: 'sam@example.com', displayName: null),
        );
        verify(() => dataSource.updateDisplayName(user, 'Sam Lee')).called(2);
      },
    );

    test('reports a twice-failed display-name update as non-fatal, with its '
        'original stack trace', () async {
      final user = _firebaseUser();
      stubCreate(() async => _credentialFor(user));
      when(
        () => dataSource.updateDisplayName(user, 'Sam Lee'),
      ).thenAnswer((_) => _fails(const NetworkException()));

      await registerSam();

      final report = errorReporter.nonFatal.single;
      expect(report.error, isA<NetworkException>());
      expect(report.stackTrace.toString(), _originalStack.toString());
      expect(report.reason, 'Saving the display name after registration');
    });

    test('does not report when the display name is eventually saved', () async {
      final user = _firebaseUser();
      stubCreate(() async => _credentialFor(user));
      var attempts = 0;
      when(() => dataSource.updateDisplayName(user, 'Sam Lee')).thenAnswer((
        _,
      ) async {
        if (++attempts == 1) throw const NetworkException();
      });

      await registerSam();

      expect(errorReporter.nonFatal, isEmpty);
    });

    test('maps account-creation failures without saving a name', () async {
      stubCreate(() => _fails(const EmailAlreadyInUseException()));

      await expectLater(registerSam(), throwsA(isA<EmailAlreadyInUse>()));
      verifyNever(() => dataSource.updateDisplayName(any(), any()));
    });
  });

  group('signOut', () {
    test('signs out through the data source', () async {
      when(() => dataSource.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => dataSource.signOut()).called(1);
    });

    test('maps sign-out failures to failures', () async {
      when(
        () => dataSource.signOut(),
      ).thenAnswer((_) => _fails(const NetworkException()));

      await expectLater(repository.signOut(), throwsA(isA<NetworkFailure>()));
    });

    test('does not touch Google for an email/password user', () async {
      when(() => dataSource.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verifyNever(() => googleDataSource.signOut());
    });

    test('also ends the Google session for a Google user', () async {
      when(() => dataSource.isSignedInWithGoogle).thenReturn(true);
      when(() => dataSource.signOut()).thenAnswer((_) async {});
      when(() => googleDataSource.signOut()).thenAnswer((_) async {});

      await repository.signOut();

      verify(() => dataSource.signOut()).called(1);
      verify(() => googleDataSource.signOut()).called(1);
    });

    test('still signs out when the Google session cannot be ended, and reports '
        'it as non-fatal', () async {
      when(() => dataSource.isSignedInWithGoogle).thenReturn(true);
      when(() => dataSource.signOut()).thenAnswer((_) async {});
      when(
        () => googleDataSource.signOut(),
      ).thenAnswer((_) => _fails(const NetworkException()));

      await expectLater(repository.signOut(), completes);

      final report = errorReporter.nonFatal.single;
      expect(report.error, isA<NetworkException>());
      expect(report.stackTrace.toString(), _originalStack.toString());
      expect(report.reason, 'Signing out of Google');
    });
  });

  group('signInWithGoogle', () {
    void stubGoogleIdToken(Future<String> Function() answer) {
      when(() => googleDataSource.authenticate()).thenAnswer((_) => answer());
    }

    void stubFirebaseGoogleSignIn(Future<UserCredential> Function() answer) {
      when(
        () => dataSource.signInWithGoogleIdToken(any()),
      ).thenAnswer((_) => answer());
    }

    test('signs in to Firebase with the Google ID token', () async {
      stubGoogleIdToken(() async => 'google-id-token');
      stubFirebaseGoogleSignIn(
        () async => _credentialFor(_firebaseUser(displayName: 'Sam Lee')),
      );

      final user = await repository.signInWithGoogle();

      expect(
        user,
        const AppUser(
          id: 'u1',
          email: 'sam@example.com',
          displayName: 'Sam Lee',
        ),
      );
      verify(
        () => dataSource.signInWithGoogleIdToken('google-id-token'),
      ).called(1);
    });

    test(
      'returns null without signing in when the user cancels the picker',
      () async {
        stubGoogleIdToken(() => _fails(const GoogleSignInCancelledException()));

        final user = await repository.signInWithGoogle();

        expect(user, isNull);
        verifyNever(() => dataSource.signInWithGoogleIdToken(any()));
        expect(errorReporter.nonFatal, isEmpty);
      },
    );

    test('maps Google failures to failures, keeping the stack trace', () async {
      stubGoogleIdToken(
        () => _fails(
          const UnknownAuthException('google-sign-in-clientConfigurationError'),
        ),
      );

      try {
        await repository.signInWithGoogle();
        fail('expected UnknownAuthFailure');
      } on UnknownAuthFailure catch (failure, stackTrace) {
        expect(failure.code, 'google-sign-in-clientConfigurationError');
        expect(stackTrace.toString(), _originalStack.toString());
      }
    });

    test('maps Firebase failures after Google succeeded', () async {
      stubGoogleIdToken(() async => 'google-id-token');
      stubFirebaseGoogleSignIn(
        () => _fails(const AccountExistsWithDifferentCredentialException()),
      );

      await expectLater(
        repository.signInWithGoogle(),
        throwsA(isA<AccountExistsWithDifferentCredential>()),
      );
    });

    test('maps a network failure to NetworkFailure', () async {
      stubGoogleIdToken(() => _fails(const NetworkException()));

      await expectLater(
        repository.signInWithGoogle(),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
