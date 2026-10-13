import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/auth/domain/failures/auth_failure.dart';
import 'package:splitzy/features/auth/presentation/providers/google_sign_in_controller.dart';
import 'package:splitzy/injection_container.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_expense_repository.dart';
import '../../../../helpers/fake_group_repository.dart';
import '../../../../helpers/fake_error_reporter.dart';

final _login = googleSignInControllerProvider(GoogleSignInOrigin.login);
final _signUp = googleSignInControllerProvider(GoogleSignInOrigin.signUp);

void main() {
  late FakeAuthRepository repository;
  late FakeErrorReporter reporter;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository();
    reporter = FakeErrorReporter();
    container = ProviderContainer.test(
      overrides: InjectionContainer(
        authRepository: repository,
        groupRepository: FakeGroupRepository(),
        expenseRepository: FakeExpenseRepository(),
        errorReporter: reporter,
      ).overrides,
    );
    // Keep the auto-disposed controller alive, as the auth pages do.
    container.listen(_login, (_, _) {});
  });

  tearDown(() => repository.dispose());

  GoogleSignInController controller() => container.read(_login.notifier);
  AsyncValue<void> state() => container.read(_login);

  group('GoogleSignInController', () {
    test('starts idle', () {
      expect(state(), const AsyncData<void>(null));
    });

    test('signs in with Google', () async {
      await controller().signIn();

      expect(repository.googleSignInCalls, 1);
      expect(repository.currentUser, FakeAuthRepository.defaultUser);
      expect(state(), const AsyncData<void>(null));
    });

    test('is loading while the sign-in is in progress', () async {
      final gate = repository.gate = Completer<void>();

      final attempt = controller().signIn();
      expect(state().isLoading, isTrue);

      gate.complete();
      await attempt;
      expect(state().isLoading, isFalse);
    });

    test('a cancelled picker ends idle, with no error and no report', () async {
      repository.cancelNextGoogleSignIn();

      await controller().signIn();

      expect(state(), const AsyncData<void>(null));
      expect(repository.currentUser, isNull);
      expect(reporter.nonFatal, isEmpty);
    });

    test('exposes an expected failure with its message, unreported', () async {
      repository.failNextWith(const AccountExistsWithDifferentCredential());

      await controller().signIn();

      expect(state().error, isA<AccountExistsWithDifferentCredential>());
      expect(
        messageFor(state().error),
        'An account with this email already exists. '
        'Log in with the method you used before.',
      );
      expect(reporter.nonFatal, isEmpty);
    });

    test('reports an unexpected error and shows the generic failure', () async {
      final error = StateError('bug');
      final stack = StackTrace.fromString('original-google-stack');
      repository.throwNextWith(error, stack);

      await controller().signIn();

      expect(state().error, isA<UnexpectedFailure>());
      expect(state().isLoading, isFalse);
      final report = reporter.nonFatal.single;
      expect(report.error, same(error));
      expect(report.stackTrace.toString(), stack.toString());
      expect(report.reason, 'Signing in with Google');
    });

    test('ignores a second attempt while one is in progress', () async {
      final gate = repository.gate = Completer<void>();

      final first = controller().signIn();
      await controller().signIn();
      gate.complete();
      await first;

      expect(repository.googleSignInCalls, 1);
    });

    test('can try again after a cancellation', () async {
      repository.cancelNextGoogleSignIn();
      await controller().signIn();

      await controller().signIn();

      expect(repository.googleSignInCalls, 2);
      expect(repository.currentUser, isNotNull);
    });

    test('Login and Sign Up attempts do not share state', () async {
      container.listen(_signUp, (_, _) {});
      repository.failNextWith(const NetworkFailure());

      await controller().signIn();

      expect(state().error, isA<NetworkFailure>());
      expect(container.read(_signUp), const AsyncData<void>(null));
    });
  });
}
