import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/groups/domain/failures/group_failure.dart';
import 'package:splitzy/features/groups/domain/validation/group_validation.dart';
import 'package:splitzy/features/groups/presentation/providers/create_group_controller.dart';
import 'package:splitzy/injection_container.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_error_reporter.dart';
import '../../../../helpers/fake_group_repository.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeGroupRepository repository;
  late FakeErrorReporter reporter;
  late ProviderContainer container;

  setUp(() {
    auth = FakeAuthRepository();
    repository = FakeGroupRepository();
    reporter = FakeErrorReporter();
    container = ProviderContainer.test(
      overrides: InjectionContainer(
        authRepository: auth,
        groupRepository: repository,
        errorReporter: reporter,
      ).overrides,
    );
    // Keep the auto-disposed controller alive, as the Create Group page does.
    container.listen(createGroupControllerProvider, (_, _) {});
  });

  tearDown(() async {
    await auth.dispose();
    await repository.dispose();
  });

  CreateGroupController controller() =>
      container.read(createGroupControllerProvider.notifier);
  AsyncValue<void> state() => container.read(createGroupControllerProvider);

  Future<void> create({List<String> memberNames = const ['Sara']}) {
    return controller().create(
      ownerId: 'u1',
      ownerName: 'Farah',
      name: 'Trip to Dahab',
      memberNames: memberNames,
    );
  }

  group('CreateGroupController', () {
    test('starts idle', () {
      expect(state(), const AsyncData<void>(null));
    });

    test('creates the group through the use case', () async {
      await create(memberNames: [' Sara ', 'Mona']);

      final call = repository.createCalls.single;
      expect(call.ownerId, 'u1');
      expect(call.ownerName, 'Farah');
      expect(call.name, 'Trip to Dahab');
      expect(call.memberNames, ['Sara', 'Mona']);
      expect(state(), const AsyncData<void>(null));
    });

    test('is loading while the group is being created', () async {
      final gate = repository.gate = Completer<void>();

      final attempt = create();
      expect(state().isLoading, isTrue);

      gate.complete();
      await attempt;
      expect(state().isLoading, isFalse);
    });

    test('exposes invalid input as an error without creating', () async {
      await create(memberNames: []);

      expect(
        state().error,
        isA<InvalidGroupInput>().having(
          (f) => f.error,
          'error',
          GroupValidationError.tooFewMembers,
        ),
      );
      expect(repository.createCalls, isEmpty);
      expect(reporter.nonFatal, isEmpty);
    });

    test('exposes an expected failure, unreported', () async {
      repository.failNextWith(const NetworkFailure());

      await create();

      expect(state().error, isA<NetworkFailure>());
      expect(reporter.nonFatal, isEmpty);
    });

    test('reports an unexpected error and shows the generic failure', () async {
      final error = StateError('bug');
      final stack = StackTrace.fromString('original-create-stack');
      repository.throwNextWith(error, stack);

      await create();

      expect(state().error, isA<UnexpectedFailure>());
      final report = reporter.nonFatal.single;
      expect(report.error, same(error));
      expect(report.stackTrace.toString(), stack.toString());
      expect(report.reason, 'Creating a group');
    });

    test('ignores a second attempt while one is in progress', () async {
      final gate = repository.gate = Completer<void>();

      final first = create();
      await create();
      gate.complete();
      await first;

      expect(repository.createCalls, hasLength(1));
    });
  });
}
