import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/auth/presentation/providers/sign_out_controller.dart';
import 'package:splitzy/injection_container.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_error_reporter.dart';

void main() {
  late FakeAuthRepository repository;
  late FakeErrorReporter reporter;
  late ProviderContainer container;

  setUp(() {
    repository = FakeAuthRepository(
      signedInUser: FakeAuthRepository.defaultUser,
    );
    reporter = FakeErrorReporter();
    container = ProviderContainer.test(
      overrides: InjectionContainer(
        authRepository: repository,
        errorReporter: reporter,
      ).overrides,
    );
    // Keep the auto-disposed controller alive, as the Home route does.
    container.listen(signOutControllerProvider, (_, _) {});
  });

  tearDown(() => repository.dispose());

  SignOutController controller() =>
      container.read(signOutControllerProvider.notifier);
  AsyncValue<void> state() => container.read(signOutControllerProvider);

  group('SignOutController', () {
    test('signs out through the repository', () async {
      await controller().logOut();

      expect(repository.signOutCalls, 1);
      expect(repository.currentUser, isNull);
      expect(state(), const AsyncData<void>(null));
    });

    test('is loading while the sign-out is in progress', () async {
      final gate = repository.gate = Completer<void>();

      final attempt = controller().logOut();
      expect(state().isLoading, isTrue);

      gate.complete();
      await attempt;
      expect(state().isLoading, isFalse);
    });

    test('exposes a failed sign-out as an error state', () async {
      repository.failNextWith(const NetworkFailure());

      await controller().logOut();

      expect(state().error, isA<NetworkFailure>());
      expect(repository.currentUser, isNotNull);
      expect(reporter.nonFatal, isEmpty);
    });

    test('reports an unexpected error and shows the generic failure', () async {
      final error = StateError('bug');
      final stack = StackTrace.fromString('original-sign-out-stack');
      repository.throwNextWith(error, stack);

      await controller().logOut();

      expect(state().error, isA<UnexpectedFailure>());
      expect(state().isLoading, isFalse);
      expect(repository.currentUser, isNotNull);
      final report = reporter.nonFatal.single;
      expect(report.error, same(error));
      expect(report.stackTrace.toString(), stack.toString());
      expect(report.reason, 'Logging out');
    });

    test('ignores a second attempt while one is in progress', () async {
      final gate = repository.gate = Completer<void>();

      final first = controller().logOut();
      await controller().logOut();
      gate.complete();
      await first;

      expect(repository.signOutCalls, 1);
    });
  });
}
