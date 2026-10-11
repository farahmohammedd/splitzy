import 'dart:async';
import 'dart:developer' as developer;

import 'package:firebase_auth/firebase_auth.dart';

import 'package:splitzy/core/error/error_reporter.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:splitzy/features/auth/data/datasources/google_sign_in_data_source.dart';
import 'package:splitzy/features/auth/data/exceptions/auth_exceptions.dart';
import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/domain/failures/auth_failure.dart';
import 'package:splitzy/features/auth/domain/repositories/auth_repository.dart';

/// [AuthRepository] backed by Firebase Authentication, with Google Sign-In
/// for the Google flow.
///
/// Maps Firebase users to [AppUser] and the data sources' project exceptions
/// ([AppException]) to [Failure]s, keeping the original stack trace, so no
/// Firebase or Google type leaves the data layer.
class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository(
    this._dataSource,
    this._googleDataSource,
    this._errorReporter,
  );

  final FirebaseAuthDataSource _dataSource;
  final GoogleSignInDataSource _googleDataSource;
  final ErrorReporter _errorReporter;

  @override
  Stream<AppUser?> userChanges() {
    return _dataSource
        .userChanges()
        .map((user) => user?.toAppUser())
        .transform(
          StreamTransformer<AppUser?, AppUser?>.fromHandlers(
            handleError: (error, stackTrace, sink) => sink.addError(
              error is AppException ? _toFailure(error) : error,
              stackTrace,
            ),
          ),
        );
  }

  @override
  Future<AppUser> signIn({required String email, required String password}) {
    return _guard(() async {
      final credential = await _dataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential).toAppUser();
    });
  }

  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final user = await _guard(() async {
      final credential = await _dataSource.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _requireUser(credential);
    });

    // The account exists and is signed in at this point, so registration
    // succeeds even if the name cannot be saved.
    final nameSaved = await _saveDisplayName(user, fullName);
    return user.toAppUser().copyWith(displayName: nameSaved ? fullName : null);
  }

  @override
  Future<AppUser?> signInWithGoogle() {
    return _guard(() async {
      final String idToken;
      try {
        idToken = await _googleDataSource.authenticate();
      } on GoogleSignInCancelledException {
        // The user closed the account picker: nothing to sign in.
        return null;
      }
      final credential = await _dataSource.signInWithGoogleIdToken(idToken);
      return _requireUser(credential).toAppUser();
    });
  }

  @override
  Future<void> signOut() async {
    // Read before signing out: afterwards there is no current user.
    final usedGoogle = _dataSource.isSignedInWithGoogle;
    await _guard(_dataSource.signOut);
    if (usedGoogle) await _signOutOfGoogle();
  }

  /// Ends the Google session so the account picker is shown next time. The
  /// user is already signed out of Splitzy, so a failure here is logged and
  /// reported as non-fatal rather than failing the log-out.
  Future<void> _signOutOfGoogle() async {
    try {
      await _googleDataSource.signOut();
    } on Exception catch (error, stackTrace) {
      developer.log(
        'Signed out, but the Google session could not be ended.',
        name: 'splitzy.auth',
        error: error,
        stackTrace: stackTrace,
      );
      unawaited(
        _errorReporter.recordNonFatal(
          error,
          stackTrace,
          reason: 'Signing out of Google',
        ),
      );
    }
  }

  /// Saves [displayName], retrying once immediately. Returns whether it was
  /// saved; a second failure is logged and reported as non-fatal rather than
  /// failing registration.
  Future<bool> _saveDisplayName(User user, String displayName) async {
    try {
      await _dataSource.updateDisplayName(user, displayName);
      return true;
    } on Exception {
      try {
        await _dataSource.updateDisplayName(user, displayName);
        return true;
      } on Exception catch (error, stackTrace) {
        developer.log(
          'Registration succeeded but the display name could not be saved.',
          name: 'splitzy.auth',
          error: error,
          stackTrace: stackTrace,
        );
        // Not awaited: reporting must not delay or fail the registration.
        unawaited(
          _errorReporter.recordNonFatal(
            error,
            stackTrace,
            reason: 'Saving the display name after registration',
          ),
        );
        return false;
      }
    }
  }

  /// Runs [action], rethrowing a project exception as the matching [Failure]
  /// with the original stack trace. Other errors pass through unchanged.
  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException catch (error, stackTrace) {
      Error.throwWithStackTrace(_toFailure(error), stackTrace);
    }
  }

  static User _requireUser(UserCredential credential) {
    final user = credential.user;
    if (user == null) throw const UnknownAuthFailure('no-user-in-credential');
    return user;
  }

  static Failure _toFailure(AppException exception) {
    return switch (exception) {
      NetworkException() => const NetworkFailure(),
      AuthException() => _toAuthFailure(exception),
      // A project exception this repository does not know about.
      _ => const UnexpectedFailure(),
    };
  }

  /// Exhaustive: adding an [AuthException] type fails to compile until it is
  /// mapped here.
  static AuthFailure _toAuthFailure(AuthException exception) {
    return switch (exception) {
      InvalidCredentialsException() => const InvalidCredentials(),
      EmailAlreadyInUseException() => const EmailAlreadyInUse(),
      WeakPasswordException() => const WeakPassword(),
      InvalidEmailException() => const InvalidEmail(),
      UserDisabledException() => const UserDisabled(),
      TooManyRequestsException() => const TooManyRequests(),
      AccountExistsWithDifferentCredentialException() =>
        const AccountExistsWithDifferentCredential(),
      UnknownAuthException(:final code) => UnknownAuthFailure(code),
    };
  }
}

extension on User {
  /// Email/password accounts always have an email; the empty fallback only
  /// guards against other account types.
  AppUser toAppUser() =>
      AppUser(id: uid, email: email ?? '', displayName: displayName);
}
