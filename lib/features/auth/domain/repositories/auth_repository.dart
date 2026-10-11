import 'package:splitzy/features/auth/domain/entities/app_user.dart';

/// What the app needs from an authentication provider.
///
/// Every method throws a `Failure` when the operation fails: an `AuthFailure`
/// or a shared failure such as `NetworkFailure`.
abstract interface class AuthRepository {
  /// The signed-in user (`null` when signed out): the current value first,
  /// then every sign-in, sign-out and profile change.
  Stream<AppUser?> userChanges();

  Future<AppUser> signIn({required String email, required String password});

  /// Creates an account, signs it in and saves [fullName] as its display
  /// name.
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
  });

  /// Signs in with a Google account chosen by the user. Creates the account
  /// on first sign-in and signs the same account in afterwards.
  ///
  /// Returns `null` when the user closes the account picker: a cancellation
  /// is not a failure.
  Future<AppUser?> signInWithGoogle();

  /// Signs out, including any Google session.
  Future<void> signOut();
}
