import 'dart:async';

import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/auth/domain/repositories/auth_repository.dart';

/// In-memory [AuthRepository] for app, router and controller tests.
///
/// - [emit] sets who is signed in and notifies [userChanges] listeners.
/// - [failNextWith] makes the next call throw the given (expected) failure.
/// - [throwNextWith] makes the next call throw an unexpected error with the
///   given stack trace.
/// - [gate], when set, holds every call until it completes, so tests can
///   observe the loading state.
/// - [cancelNextGoogleSignIn] makes the next [signInWithGoogle] behave as if
///   the user closed the account picker (returns `null`, no auth change).
/// - Successful [signIn]/[register]/[signInWithGoogle] emit the user;
///   [signOut] emits `null`.
/// - Every call's arguments are recorded.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({AppUser? signedInUser}) : _currentUser = signedInUser;

  static const AppUser defaultUser = AppUser(
    id: 'fake-uid',
    email: 'sam@example.com',
    displayName: 'Sam Lee',
  );

  final _changes = StreamController<AppUser?>.broadcast();
  AppUser? _currentUser;
  Object? _nextError;
  StackTrace? _nextStackTrace;

  /// Holds calls until completed; `null` lets calls finish immediately.
  Completer<void>? gate;

  final signInCalls = <({String email, String password})>[];
  final registerCalls = <({String fullName, String email, String password})>[];
  int googleSignInCalls = 0;
  int signOutCalls = 0;
  bool _cancelNextGoogleSignIn = false;

  AppUser? get currentUser => _currentUser;

  void emit(AppUser? user) {
    _currentUser = user;
    _changes.add(user);
  }

  void failNextWith(Failure failure) {
    _nextError = failure;
    _nextStackTrace = null;
  }

  void throwNextWith(Object error, StackTrace stackTrace) {
    _nextError = error;
    _nextStackTrace = stackTrace;
  }

  void cancelNextGoogleSignIn() => _cancelNextGoogleSignIn = true;

  /// Emits the current user, then every later change. Subscribes to changes
  /// as soon as it is listened to, so no change is missed.
  @override
  Stream<AppUser?> userChanges() {
    StreamSubscription<AppUser?>? subscription;
    late final StreamController<AppUser?> controller;
    controller = StreamController<AppUser?>(
      onListen: () {
        controller.add(_currentUser);
        subscription = _changes.stream.listen(controller.add);
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<AppUser> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls.add((email: email, password: password));
    await _beforeResult();
    final user = defaultUser.copyWith(email: email);
    emit(user);
    return user;
  }

  @override
  Future<AppUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    registerCalls.add((fullName: fullName, email: email, password: password));
    await _beforeResult();
    final user = defaultUser.copyWith(email: email, displayName: fullName);
    emit(user);
    return user;
  }

  @override
  Future<AppUser?> signInWithGoogle() async {
    googleSignInCalls++;
    await _beforeResult();
    if (_cancelNextGoogleSignIn) {
      _cancelNextGoogleSignIn = false;
      return null;
    }
    emit(defaultUser);
    return defaultUser;
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    await _beforeResult();
    emit(null);
  }

  Future<void> _beforeResult() async {
    final pending = gate;
    if (pending != null) await pending.future;
    final error = _nextError;
    if (error == null) return;
    final stackTrace = _nextStackTrace;
    _nextError = null;
    _nextStackTrace = null;
    if (stackTrace == null) throw error;
    Error.throwWithStackTrace(error, stackTrace);
  }

  Future<void> dispose() => _changes.close();
}
