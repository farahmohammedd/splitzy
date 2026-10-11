import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/domain/failures/auth_failure.dart';
import 'package:splitzy/features/auth/domain/repositories/auth_repository.dart';
import 'package:splitzy/features/auth/domain/validation/auth_validation.dart';

/// Signs in with email and password after checking the sign-in rules.
class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  /// Throws [InvalidInput] without contacting the repository when the input
  /// breaks a rule; otherwise throws whatever [AuthFailure] the repository
  /// reports.
  Future<AppUser> call({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    final error =
        AuthValidation.email(trimmedEmail) ??
        AuthValidation.signInPassword(password);
    if (error != null) throw InvalidInput(error);

    return _repository.signIn(email: trimmedEmail, password: password);
  }
}
