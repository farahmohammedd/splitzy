import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/crashlytics_error_reporter.dart';
import 'package:splitzy/core/error/error_reporter_provider.dart';
import 'package:splitzy/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_providers.dart';
import 'package:splitzy/injection_container.dart';

import 'helpers/fake_auth_repository.dart';
import 'helpers/fake_error_reporter.dart';

class _MockFirebaseAuth extends Mock implements FirebaseAuth {}

class _MockCrashlytics extends Mock implements FirebaseCrashlytics {}

class _MockGoogleSignIn extends Mock implements GoogleSignIn {}

void main() {
  group('InjectionContainer', () {
    test('supplies its instances through the providers', () {
      final repository = FakeAuthRepository();
      addTearDown(repository.dispose);
      final injection = InjectionContainer(
        authRepository: repository,
        errorReporter: FakeErrorReporter(),
      );
      final container = ProviderContainer.test(overrides: injection.overrides);

      expect(container.read(authRepositoryProvider), same(repository));
      expect(
        container.read(signInUseCaseProvider),
        same(injection.signInUseCase),
      );
      expect(
        container.read(registerUseCaseProvider),
        same(injection.registerUseCase),
      );
    });

    test('create wires Firebase into the production implementations', () {
      final injection = InjectionContainer.create(
        firebaseAuth: _MockFirebaseAuth(),
        crashlytics: _MockCrashlytics(),
        googleSignIn: _MockGoogleSignIn(),
      );

      expect(injection.authRepository, isA<FirebaseAuthRepository>());
      expect(injection.errorReporter, isA<CrashlyticsErrorReporter>());
    });

    test('supplies its error reporter through the provider', () {
      final repository = FakeAuthRepository();
      addTearDown(repository.dispose);
      final reporter = FakeErrorReporter();
      final container = ProviderContainer.test(
        overrides: InjectionContainer(
          authRepository: repository,
          errorReporter: reporter,
        ).overrides,
      );

      expect(container.read(errorReporterProvider), same(reporter));
    });

    test('the use cases use the container repository', () async {
      final repository = FakeAuthRepository();
      addTearDown(repository.dispose);
      final injection = InjectionContainer(
        authRepository: repository,
        errorReporter: FakeErrorReporter(),
      );

      await injection.signInUseCase(email: 'sam@example.com', password: 'pw');
      await injection.registerUseCase(
        fullName: 'Sam Lee',
        email: 'sam@example.com',
        password: 'secret12',
        confirmPassword: 'secret12',
      );

      expect(repository.signInCalls, hasLength(1));
      expect(repository.registerCalls, hasLength(1));
    });
  });
}
