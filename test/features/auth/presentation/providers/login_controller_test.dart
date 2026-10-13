import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/auth/domain/failures/auth_failure.dart';
import 'package:splitzy/features/auth/domain/validation/auth_validation.dart';
import 'package:splitzy/features/auth/presentation/providers/login_controller.dart';
import 'package:splitzy/injection_container.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_group_repository.dart';
import '../../../../helpers/fake_error_reporter.dart';

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
        errorReporter: reporter,
      ).overrides,
    );
    // Keep the auto-disposed controller alive, as the Login page does.
    container.listen(loginControllerProvider, (_, _) {});
  });

  tearDown(() => repository.dispose());

  LoginController controller() =>
      container.read(loginControllerProvider.notifier);
  AsyncValue<void> state() => container.read(loginControllerProvider);

  group('LoginController', () {
    test('starts idle', () {
      expect(state(), const AsyncData<void>(null));
    });

    test('is loading while the sign-in is in progress', () async {
      final gate = repository.gate = Completer<void>();

      final attempt = controller().logIn(
        email: 'sam@example.com',
        password: 'secret',
      );
      expect(state().isLoading, isTrue);

      gate.complete();
      await attempt;
      expect(state(), const AsyncData<void>(null));
    });

    test('signs in through the use case with the given credentials', () async {
      await controller().logIn(email: ' sam@example.com ', password: 'secret');

      expect(repository.signInCalls.single, (
        email: 'sam@example.com',
        password: 'secret',
      ));
      expect(repository.currentUser, isNotNull);
    });

    test('exposes a failed sign-in as an error state', () async {
      repository.failNextWith(const InvalidCredentials());

      await controller().logIn(email: 'sam@example.com', password: 'wrong');

      expect(state().error, isA<InvalidCredentials>());
      expect(messageFor(state().error), 'Incorrect email or password.');
      expect(state().isLoading, isFalse);
    });

    test('does not report expected failures', () async {
      repository.failNextWith(const InvalidCredentials());
      await controller().logIn(email: 'sam@example.com', password: 'wrong');
      await controller().logIn(email: 'sam', password: 'secret');

      expect(reporter.nonFatal, isEmpty);
    });

    test('reports an unexpected error and shows the generic failure', () async {
      final error = StateError('bug');
      final stack = StackTrace.fromString('original-sign-in-stack');
      repository.throwNextWith(error, stack);

      await controller().logIn(email: 'sam@example.com', password: 'secret');

      expect(state().error, isA<UnexpectedFailure>());
      expect(state().isLoading, isFalse);
      final report = reporter.nonFatal.single;
      expect(report.error, same(error));
      expect(report.stackTrace.toString(), stack.toString());
      expect(report.reason, 'Logging in');
    });

    test('can log in again after an unexpected error', () async {
      repository.throwNextWith(StateError('bug'), StackTrace.empty);
      await controller().logIn(email: 'sam@example.com', password: 'secret');

      await controller().logIn(email: 'sam@example.com', password: 'secret');

      expect(state(), const AsyncData<void>(null));
      expect(repository.signInCalls, hasLength(2));
    });

    test('exposes invalid input as an error without signing in', () async {
      await controller().logIn(email: 'sam', password: 'secret');

      expect(
        state().error,
        isA<InvalidInput>().having(
          (f) => f.error,
          'error',
          ValidationError.emailInvalid,
        ),
      );
      expect(repository.signInCalls, isEmpty);
    });

    test('ignores a second attempt while one is in progress', () async {
      final gate = repository.gate = Completer<void>();

      final first = controller().logIn(
        email: 'sam@example.com',
        password: 'secret',
      );
      await controller().logIn(email: 'sam@example.com', password: 'secret');
      gate.complete();
      await first;

      expect(repository.signInCalls, hasLength(1));
    });

    test('a new attempt clears the previous error', () async {
      repository.failNextWith(const NetworkFailure());
      await controller().logIn(email: 'sam@example.com', password: 'secret');
      expect(state().hasError, isTrue);

      await controller().logIn(email: 'sam@example.com', password: 'secret');

      expect(state(), const AsyncData<void>(null));
    });
  });
}
