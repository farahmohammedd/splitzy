import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/domain/failures/auth_failure.dart';
import 'package:splitzy/features/auth/domain/repositories/auth_repository.dart';
import 'package:splitzy/features/auth/domain/validation/auth_validation.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_use_case.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _user = AppUser(id: 'u1', email: 'sam@example.com');

void main() {
  late _MockAuthRepository repository;
  late SignInUseCase signIn;

  setUp(() {
    repository = _MockAuthRepository();
    signIn = SignInUseCase(repository);
  });

  void stubSignIn() {
    when(
      () => repository.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async => _user);
  }

  group('SignInUseCase', () {
    test('signs in with the trimmed email and the password as typed', () async {
      stubSignIn();

      final user = await signIn(email: '  sam@example.com ', password: ' pw ');

      expect(user, _user);
      verify(
        () => repository.signIn(email: 'sam@example.com', password: ' pw '),
      ).called(1);
    });

    test('rejects invalid input without calling the repository', () async {
      final cases = {
        ('', 'pw'): ValidationError.emailRequired,
        ('sam', 'pw'): ValidationError.emailInvalid,
        ('sam@example.com', ''): ValidationError.passwordRequired,
      };

      for (final MapEntry(key: (email, password), value: error)
          in cases.entries) {
        await expectLater(
          signIn(email: email, password: password),
          throwsA(isA<InvalidInput>().having((f) => f.error, 'error', error)),
          reason: '$email / $password',
        );
      }
      verifyNever(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('passes repository failures through unchanged', () async {
      when(
        () => repository.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const InvalidCredentials());

      await expectLater(
        signIn(email: 'sam@example.com', password: 'pw'),
        throwsA(isA<InvalidCredentials>()),
      );
    });
  });
}
