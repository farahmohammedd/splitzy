import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/domain/failures/auth_failure.dart';
import 'package:splitzy/features/auth/domain/repositories/auth_repository.dart';
import 'package:splitzy/features/auth/domain/validation/auth_validation.dart';
import 'package:splitzy/features/auth/domain/usecases/register_use_case.dart';

class _MockAuthRepository extends Mock implements AuthRepository {}

const _user = AppUser(id: 'u1', email: 'sam@example.com', displayName: 'Sam');

void main() {
  late _MockAuthRepository repository;
  late RegisterUseCase register;

  setUp(() {
    repository = _MockAuthRepository();
    register = RegisterUseCase(repository);
  });

  Future<AppUser> registerWith({
    String fullName = 'Sam Lee',
    String email = 'sam@example.com',
    String password = 'secret12',
    String? confirmPassword,
  }) {
    return register(
      fullName: fullName,
      email: email,
      password: password,
      confirmPassword: confirmPassword ?? password,
    );
  }

  void verifyNoRegistration() {
    verifyNever(
      () => repository.register(
        fullName: any(named: 'fullName'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  }

  group('RegisterUseCase', () {
    test(
      'registers with the trimmed name and email and the raw password',
      () async {
        when(
          () => repository.register(
            fullName: any(named: 'fullName'),
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => _user);

        final user = await registerWith(
          fullName: '  Sam Lee ',
          email: ' sam@example.com ',
          password: ' secret1 ',
        );

        expect(user, _user);
        verify(
          () => repository.register(
            fullName: 'Sam Lee',
            email: 'sam@example.com',
            password: ' secret1 ',
          ),
        ).called(1);
      },
    );

    test('rejects invalid input without calling the repository', () async {
      final cases = <Future<AppUser> Function(), ValidationError>{
        () => registerWith(fullName: '  '): ValidationError.fullNameRequired,
        () => registerWith(fullName: 'a' * 51): ValidationError.fullNameTooLong,
        () => registerWith(email: ''): ValidationError.emailRequired,
        () => registerWith(email: 'sam@'): ValidationError.emailInvalid,
        () => registerWith(password: ''): ValidationError.passwordRequired,
        () => registerWith(password: '1234567'):
            ValidationError.passwordTooShort,
        () => registerWith(password: 'secret12', confirmPassword: 'secret13'):
            ValidationError.passwordsDoNotMatch,
      };

      for (final MapEntry(key: attempt, value: error) in cases.entries) {
        await expectLater(
          attempt(),
          throwsA(isA<InvalidInput>().having((f) => f.error, 'error', error)),
          reason: '$error',
        );
      }
      verifyNoRegistration();
    });

    test('passes repository failures through unchanged', () async {
      when(
        () => repository.register(
          fullName: any(named: 'fullName'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const EmailAlreadyInUse());

      await expectLater(registerWith(), throwsA(isA<EmailAlreadyInUse>()));
    });
  });
}
