import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/auth/domain/failures/auth_failure.dart';
import 'package:splitzy/features/auth/domain/validation/auth_validation.dart';
import 'package:splitzy/features/auth/presentation/providers/sign_up_controller.dart';
import 'package:splitzy/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:splitzy/injection_container.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_error_reporter.dart';

const SignUpDetails _details = (
  fullName: 'Sam Lee',
  email: 'sam@example.com',
  password: 'secret12',
  confirmPassword: 'secret12',
);

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
        errorReporter: reporter,
      ).overrides,
    );
    // Keep the auto-disposed controller alive, as the Sign Up page does.
    container.listen(signUpControllerProvider, (_, _) {});
  });

  tearDown(() => repository.dispose());

  SignUpController controller() =>
      container.read(signUpControllerProvider.notifier);
  AsyncValue<void> state() => container.read(signUpControllerProvider);

  group('SignUpController', () {
    test('registers through the use case', () async {
      await controller().register(_details);

      expect(repository.registerCalls.single, (
        fullName: 'Sam Lee',
        email: 'sam@example.com',
        password: 'secret12',
      ));
      expect(repository.currentUser?.displayName, 'Sam Lee');
      expect(state(), const AsyncData<void>(null));
    });

    test('is loading while the registration is in progress', () async {
      final gate = repository.gate = Completer<void>();

      final attempt = controller().register(_details);
      expect(state().isLoading, isTrue);

      gate.complete();
      await attempt;
      expect(state().isLoading, isFalse);
    });

    test('exposes a failed registration as an error state', () async {
      repository.failNextWith(const EmailAlreadyInUse());

      await controller().register(_details);

      expect(state().error, isA<EmailAlreadyInUse>());
      expect(
        messageFor(state().error),
        'An account with this email already exists.',
      );
      expect(reporter.nonFatal, isEmpty);
    });

    test('reports an unexpected error and shows the generic failure', () async {
      final error = StateError('bug');
      final stack = StackTrace.fromString('original-register-stack');
      repository.throwNextWith(error, stack);

      await controller().register(_details);

      expect(state().error, isA<UnexpectedFailure>());
      expect(state().isLoading, isFalse);
      final report = reporter.nonFatal.single;
      expect(report.error, same(error));
      expect(report.stackTrace.toString(), stack.toString());
      expect(report.reason, 'Creating an account');
    });

    test('exposes invalid input as an error without registering', () async {
      await controller().register((
        fullName: 'Sam Lee',
        email: 'sam@example.com',
        password: 'secret12',
        confirmPassword: 'secret13',
      ));

      expect(
        state().error,
        isA<InvalidInput>().having(
          (f) => f.error,
          'error',
          ValidationError.passwordsDoNotMatch,
        ),
      );
      expect(repository.registerCalls, isEmpty);
    });

    test('ignores a second attempt while one is in progress', () async {
      final gate = repository.gate = Completer<void>();

      final first = controller().register(_details);
      await controller().register(_details);
      gate.complete();
      await first;

      expect(repository.registerCalls, hasLength(1));
    });
  });
}
