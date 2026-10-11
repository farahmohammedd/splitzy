import 'package:google_sign_in/google_sign_in.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/auth/data/exceptions/auth_exceptions.dart';
import 'package:splitzy/features/auth/data/mappers/google_sign_in_exception_mapper.dart';

/// Thin wrapper over [GoogleSignIn]: one method per SDK operation, no
/// business rules. Google errors are translated into project exceptions
/// ([AppException]) with their original stack trace.
///
/// On Android, no client ID is passed: the plugin reads the web OAuth client
/// from `google-services.json`.
class GoogleSignInDataSource {
  GoogleSignInDataSource(this._googleSignIn);

  final GoogleSignIn _googleSignIn;

  /// `GoogleSignIn.initialize` must complete exactly once before any other
  /// call. Cleared on failure so a later attempt can retry it.
  Future<void>? _initialization;

  /// Shows the Google account picker and returns the chosen account's ID
  /// token, which Firebase uses to sign in. Throws
  /// [GoogleSignInCancelledException] if the user closes the picker.
  Future<String> authenticate() {
    return _guard(() async {
      await _ensureInitialized();
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        throw const UnknownAuthException('google-sign-in-missing-id-token');
      }
      return idToken;
    });
  }

  /// Ends the Google session, so the account picker is shown next time.
  Future<void> signOut() {
    return _guard(() async {
      await _ensureInitialized();
      await _googleSignIn.signOut();
    });
  }

  Future<void> _ensureInitialized() {
    return _initialization ??= _googleSignIn.initialize().catchError((
      Object error,
      StackTrace stackTrace,
    ) {
      _initialization = null;
      Error.throwWithStackTrace(error, stackTrace);
    });
  }

  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on GoogleSignInException catch (error, stackTrace) {
      Error.throwWithStackTrace(mapGoogleSignInException(error), stackTrace);
    }
  }
}
