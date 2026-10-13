import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/expenses/data/datasources/firestore_expense_data_source.dart';
import 'package:splitzy/features/expenses/data/exceptions/expense_exceptions.dart';
import 'package:splitzy/features/expenses/data/models/expense_dto.dart';
import 'package:splitzy/features/expenses/data/repositories/firestore_expense_repository.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/domain/failures/expense_failure.dart';

class _MockDataSource extends Mock implements FirestoreExpenseDataSource {}

/// A project exception the repository does not know about.
final class _OtherException extends AppException {
  const _OtherException();
}

final _now = DateTime.utc(2026, 10, 12, 12);
final _originalStack = StackTrace.fromString('original-data-source-stack');

const _shares = {'you': 20000, 'sara': 20000, 'mona': 20000};

void main() {
  late _MockDataSource dataSource;
  late FirestoreExpenseRepository repository;

  setUpAll(
    () => registerFallbackValue(
      const ExpenseDto(
        description: 'fallback',
        amount: 1,
        currency: 'EGP',
        paidBy: 'you',
        splitType: SplitType.equal,
        shares: {},
      ),
    ),
  );

  setUp(() {
    dataSource = _MockDataSource();
    repository = FirestoreExpenseRepository(dataSource, clock: () => _now);
  });

  Future<void> addDinner() => repository.addExpense(
    groupId: 'g1',
    description: 'Dinner',
    amount: 60000,
    paidBy: 'sara',
    splitType: SplitType.equal,
    shares: _shares,
  );

  group('watchExpenses', () {
    ExpenseDto dto(String description, {DateTime? createdAt}) => ExpenseDto(
      description: description,
      amount: 60000,
      currency: 'EGP',
      paidBy: 'sara',
      splitType: SplitType.equal,
      shares: _shares,
      createdAt: createdAt,
    );

    test('maps documents to expenses of the group, newest first', () async {
      when(() => dataSource.watchExpenses('g1')).thenAnswer(
        (_) => Stream.value([
          (id: 'old', data: dto('Taxi', createdAt: DateTime.utc(2026, 1))),
          (id: 'new', data: dto('Dinner', createdAt: DateTime.utc(2026, 9))),
        ]),
      );

      final expenses = await repository.watchExpenses('g1').first;

      expect([for (final e in expenses) e.id], ['new', 'old']);
      expect(expenses.first.groupId, 'g1');
      expect(expenses.first.description, 'Dinner');
      expect(expenses.first.shares, _shares);
    });

    test('a just-added expense (pending time) counts as added now and '
        'comes first', () async {
      when(() => dataSource.watchExpenses('g1')).thenAnswer(
        (_) => Stream.value([
          (id: 'old', data: dto('Taxi', createdAt: DateTime.utc(2026, 9))),
          (id: 'pending', data: dto('Dinner')),
        ]),
      );

      final expenses = await repository.watchExpenses('g1').first;

      expect(expenses.first.id, 'pending');
      expect(expenses.first.createdAt, _now);
    });

    test('orders expenses added at the same time by id', () async {
      final sameTime = DateTime.utc(2026, 5);
      when(() => dataSource.watchExpenses('g1')).thenAnswer(
        (_) => Stream.value([
          (id: 'b', data: dto('B', createdAt: sameTime)),
          (id: 'a', data: dto('A', createdAt: sameTime)),
        ]),
      );

      final expenses = await repository.watchExpenses('g1').first;

      expect([for (final e in expenses) e.id], ['a', 'b']);
    });

    test(
      'maps a project exception to a failure, keeping the stack trace',
      () async {
        when(() => dataSource.watchExpenses('g1')).thenAnswer(
          (_) => Stream.error(const NetworkException(), _originalStack),
        );

        try {
          await repository.watchExpenses('g1').first;
          fail('watchExpenses should have failed');
        } on NetworkFailure catch (_, stackTrace) {
          expect(stackTrace.toString(), _originalStack.toString());
        }
      },
    );

    test('passes other errors through unchanged', () async {
      final error = StateError('bug');
      when(
        () => dataSource.watchExpenses('g1'),
      ).thenAnswer((_) => Stream.error(error));

      await expectLater(
        repository.watchExpenses('g1'),
        emitsError(same(error)),
      );
    });
  });

  group('addExpense', () {
    test('writes the expense in EGP to the group', () async {
      when(() => dataSource.addExpense(any(), any())).thenAnswer((_) async {});

      await addDinner();

      verify(
        () => dataSource.addExpense(
          'g1',
          const ExpenseDto(
            description: 'Dinner',
            amount: 60000,
            currency: 'EGP',
            paidBy: 'sara',
            splitType: SplitType.equal,
            shares: _shares,
          ),
        ),
      ).called(1);
    });

    for (final (name, exception, matcher) in [
      ('no connection', const NetworkException(), isA<NetworkFailure>()),
      (
        'an unknown error',
        const UnknownExpenseException('permission-denied'),
        isA<UnknownExpenseFailure>().having(
          (f) => f.code,
          'code',
          'permission-denied',
        ),
      ),
      (
        'an unmapped exception',
        const _OtherException(),
        isA<UnexpectedFailure>(),
      ),
    ]) {
      test('maps $name to a failure, keeping the stack trace', () async {
        when(
          () => dataSource.addExpense(any(), any()),
        ).thenAnswer((_) => Future.error(exception, _originalStack));

        try {
          await addDinner();
          fail('addExpense should have thrown');
        } on Failure catch (failure, stackTrace) {
          expect(failure, matcher);
          expect(stackTrace, _originalStack);
        }
      });
    }

    test('passes any other error through unchanged', () async {
      final error = StateError('boom');
      when(() => dataSource.addExpense(any(), any())).thenThrow(error);

      await expectLater(addDinner(), throwsA(error));
    });
  });
}
