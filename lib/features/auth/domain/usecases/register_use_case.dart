import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/domain/failures/auth_failure.dart';
import 'package:splitzy/features/auth/domain/repositories/auth_repository.dart';
import 'package:splitzy/features/auth/domain/validation/auth_validation.dart';

/// Creates an account after checking the registration rules.
class RegisterUseCase {
  const RegisterUseCase(this._repository);

  final AuthRepository _repository;

  /// Throws [InvalidInput] without contacting the repository when the input
  /// breaks a rule; otherwise throws whatever [AuthFailure] the repository
  /// reports. The name and email are trimmed; passwords are used as typed.
  Future<AppUser> call({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    final trimmedName = fullName.trim();
    final trimmedEmail = email.trim();
    final error =
        AuthValidation.fullName(trimmedName) ??
        AuthValidation.email(trimmedEmail) ??
        AuthValidation.newPassword(password) ??
        AuthValidation.passwordConfirmation(password, confirmPassword);
    if (error != null) throw InvalidInput(error);

    return _repository.register(
      fullName: trimmedName,
      email: trimmedEmail,
      password: password,
    );
  }
}
