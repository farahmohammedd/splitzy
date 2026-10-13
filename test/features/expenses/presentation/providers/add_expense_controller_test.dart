import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/error_reporter_provider.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/domain/failures/expense_failure.dart';
import 'package:splitzy/features/expenses/domain/usecases/add_expense_use_case.dart';
import 'package:splitzy/features/expenses/domain/validation/expense_validation.dart';
import 'package:splitzy/features/expenses/presentation/providers/add_expense_controller.dart';
import 'package:splitzy/features/expenses/presentation/providers/expense_providers.dart';

import '../../../../helpers/fake_error_reporter.dart';
import '../../../../helpers/fake_expense_repository.dart';

void main() {
  late FakeExpenseRepository repository;
  late FakeErrorReporter reporter;
  late ProviderContainer container;

  setUp(() {
    repository = FakeExpenseRepository();
    reporter = FakeErrorReporter();
    container = ProviderContainer.test(
      overrides: [
        errorReporterProvider.overrideWithValue(reporter),
        addExpenseUseCaseProvider.overrideWithValue(
          AddExpenseUseCase(repository),
        ),
      ],
    );
    // Keep the auto-disposed controller alive, as the Add Expense page does.
    container.listen(addExpenseControllerProvider, (_, _) {});
  });

  AddExpenseController controller() =>
      container.read(addExpenseControllerProvider.notifier);
  AsyncValue<void> state() => container.read(addExpenseControllerProvider);

  Future<void> add({int amount = 60000}) {
    return controller().add(
      groupId: 'g1',
      memberIds: const ['you', 'sara', 'mona'],
      description: 'Dinner',
      amount: amount,
      paidBy: 'sara',
      splitType: SplitType.equal,
    );
  }

  group('AddExpenseController', () {
    test('starts idle', () {
      expect(state(), const AsyncData<void>(null));
    });

    test('adds the expense through the use case', () async {
      await add();

      final call = repository.addCalls.single;
      expect(call.groupId, 'g1');
      expect(call.description, 'Dinner');
      expect(call.amount, 60000);
      expect(call.paidBy, 'sara');
      expect(call.splitType, SplitType.equal);
      expect(call.shares, {'you': 20000, 'sara': 20000, 'mona': 20000});
      expect(state(), const AsyncData<void>(null));
    });

    test('is loading while the expense is being added', () async {
      final gate = repository.gate = Completer<void>();

      final attempt = add();
      expect(state().isLoading, isTrue);

      gate.complete();
      await attempt;
      expect(state().isLoading, isFalse);
    });

    test('exposes invalid input as an error without adding', () async {
      await add(amount: 0);

      expect(
        state().error,
        isA<InvalidExpenseInput>().having(
          (f) => f.error,
          'error',
          ExpenseValidationError.amountTooSmall,
        ),
      );
      expect(repository.addCalls, isEmpty);
      expect(reporter.nonFatal, isEmpty);
    });

    test('exposes an expected failure, unreported', () async {
      repository.failNextWith(const NetworkFailure());

      await add();

      expect(state().error, isA<NetworkFailure>());
      expect(reporter.nonFatal, isEmpty);
    });

    test('reports an unexpected error and shows the generic failure', () async {
      final error = StateError('bug');
      final stack = StackTrace.fromString('original-add-stack');
      repository.throwNextWith(error, stack);

      await add();

      expect(state().error, isA<UnexpectedFailure>());
      final report = reporter.nonFatal.single;
      expect(report.error, same(error));
      expect(report.stackTrace.toString(), stack.toString());
      expect(report.reason, 'Adding an expense');
    });

    test('ignores a second attempt while one is in progress', () async {
      final gate = repository.gate = Completer<void>();

      final first = add();
      await add();
      gate.complete();
      await first;

      expect(repository.addCalls, hasLength(1));
    });
  });
}
