import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';
import 'package:splitzy/features/groups/presentation/providers/group_providers.dart';
import 'package:splitzy/injection_container.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_error_reporter.dart';
import '../../../../helpers/fake_group_repository.dart';

Group _group(String id, String ownerId) => Group(
  id: id,
  ownerId: ownerId,
  name: 'Group $id',
  members: [
    Member(id: ownerId, name: 'Owner'),
    const Member(id: 'm2', name: 'Sara'),
  ],
  createdAt: DateTime.utc(2026),
);

void main() {
  group('group providers', () {
    test('fail fast when InjectionContainer is not used', () {
      final container = ProviderContainer.test();

      // Riverpod wraps the UnimplementedError, so only "it throws" is stable.
      expect(() => container.read(groupRepositoryProvider), throwsA(anything));
      expect(
        () => container.read(createGroupUseCaseProvider),
        throwsA(anything),
      );
    });

    test(
      "groups lists only the given owner's groups and follows changes",
      () async {
        final auth = FakeAuthRepository();
        final repository = FakeGroupRepository(
          groups: [_group('mine', 'u1'), _group('theirs', 'u2')],
        );
        addTearDown(auth.dispose);
        addTearDown(repository.dispose);
        final container = ProviderContainer.test(
          overrides: InjectionContainer(
            authRepository: auth,
            groupRepository: repository,
            errorReporter: FakeErrorReporter(),
          ).overrides,
        );
        final updates = <List<String>>[];
        container.listen(groupsProvider('u1'), (_, next) {
          if (next case AsyncData(:final value)) {
            updates.add([for (final g in value) g.id]);
          }
        });

        await container.read(groupsProvider('u1').future);
        await repository.createGroup(
          ownerId: 'u1',
          ownerName: 'Owner',
          name: 'New',
          memberNames: ['Sara'],
        );
        await Future<void>.delayed(Duration.zero);

        expect(updates, [
          ['mine'],
          ['group-1', 'mine'],
        ]);
      },
    );
  });
}
