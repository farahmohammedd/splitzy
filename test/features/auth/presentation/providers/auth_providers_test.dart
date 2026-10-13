import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_providers.dart';
import 'package:splitzy/injection_container.dart';

import '../../../../helpers/fake_auth_repository.dart';
import '../../../../helpers/fake_expense_repository.dart';
import '../../../../helpers/fake_group_repository.dart';
import '../../../../helpers/fake_error_reporter.dart';

void main() {
  group('auth providers', () {
    test('fail fast when the injection container did not supply them', () {
      final container = ProviderContainer.test();

      expect(() => container.read(authRepositoryProvider), throwsA(anything));
    });

    test('authState follows the repository user changes', () async {
      const user = AppUser(id: 'u1', email: 'sam@example.com');
      final repository = FakeAuthRepository();
      addTearDown(repository.dispose);
      final container = ProviderContainer.test(
        overrides: InjectionContainer(
          authRepository: repository,
          groupRepository: FakeGroupRepository(),
          expenseRepository: FakeExpenseRepository(),
          errorReporter: FakeErrorReporter(),
        ).overrides,
      );
      final states = <AppUser?>[];
      container.listen(authStateProvider, (_, next) {
        if (next case AsyncData(:final value)) states.add(value);
      }, fireImmediately: true);

      await container.read(authStateProvider.future);
      repository.emit(user);
      await pumpEventQueue();
      repository.emit(null);
      await pumpEventQueue();

      expect(states, [null, user, null]);
    });
  });
}
