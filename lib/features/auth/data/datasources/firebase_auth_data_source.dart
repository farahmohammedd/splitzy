import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/auth/data/mappers/firebase_auth_exception_mapper.dart';

/// Thin wrapper over [FirebaseAuth]: one method per SDK call, no business
/// rules. Firebase errors are translated into project exceptions
/// ([AppException]) with their original stack trace; any other error passes
/// through unchanged. Firebase types such as [User] are still returned and
/// are mapped by the repository.
class FirebaseAuthDataSource {
  const FirebaseAuthDataSource(this._auth);

  final FirebaseAuth _auth;

  /// Emits on sign-in, sign-out and profile changes (e.g. display name).
  Stream<User?> userChanges() {
    return _auth.userChanges().transform(
      StreamTransformer<User?, User?>.fromHandlers(
        handleError: (error, stackTrace, sink) =>
            sink.addError(_translate(error), stackTrace),
      ),
    );
  }

  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _guard(
      () => _auth.signInWithEmailAndPassword(email: email, password: password),
    );
  }

  Future<UserCredential> createUserWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    return _guard(
      () => _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      ),
    );
  }

  /// Signs in to Firebase with a Google ID token. Firebase creates the user on
  /// first sign-in and reuses it afterwards.
  Future<UserCredential> signInWithGoogleIdToken(String idToken) {
    return _guard(
      () => _auth.signInWithCredential(
        GoogleAuthProvider.credential(idToken: idToken),
      ),
    );
  }

  /// Whether the signed-in user has Google as a sign-in method.
  bool get isSignedInWithGoogle {
    final providers = _auth.currentUser?.providerData ?? const [];
    return providers.any(
      (info) => info.providerId == GoogleAuthProvider.PROVIDER_ID,
    );
  }

  Future<void> updateDisplayName(User user, String displayName) {
    return _guard(() => user.updateDisplayName(displayName));
  }

  Future<void> signOut() => _guard(_auth.signOut);

  /// Runs [call], rethrowing a Firebase error as a project exception with the
  /// original stack trace.
  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on FirebaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(mapFirebaseAuthException(error), stackTrace);
    }
  }

  static Object _translate(Object error) =>
      error is FirebaseException ? mapFirebaseAuthException(error) : error;
}
