import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/domain/failures/expense_failure.dart';
import 'package:splitzy/features/expenses/domain/repositories/expense_repository.dart';
import 'package:splitzy/features/expenses/domain/usecases/add_expense_use_case.dart';
import 'package:splitzy/features/expenses/domain/validation/expense_validation.dart';

class _MockExpenseRepository extends Mock implements ExpenseRepository {}

const _members = ['you', 'sara', 'mona'];

void main() {
  late _MockExpenseRepository repository;
  late AddExpenseUseCase addExpense;

  setUp(() {
    repository = _MockExpenseRepository();
    addExpense = AddExpenseUseCase(repository);
    when(
      () => repository.addExpense(
        groupId: any(named: 'groupId'),
        description: any(named: 'description'),
        amount: any(named: 'amount'),
        paidBy: any(named: 'paidBy'),
        splitType: any(named: 'splitType'),
        shares: any(named: 'shares'),
      ),
    ).thenAnswer((_) async {});
  });

  setUpAll(() => registerFallbackValue(SplitType.equal));

  /// The shares the repository received.
  Map<String, int> savedShares() {
    final captured = verify(
      () => repository.addExpense(
        groupId: any(named: 'groupId'),
        description: any(named: 'description'),
        amount: any(named: 'amount'),
        paidBy: any(named: 'paidBy'),
        splitType: any(named: 'splitType'),
        shares: captureAny(named: 'shares'),
      ),
    ).captured;
    return captured.single as Map<String, int>;
  }

  Future<void> expectRejected(
    Future<void> Function() call,
    ExpenseValidationError error,
  ) async {
    await expectLater(
      call,
      throwsA(
        isA<InvalidExpenseInput>().having((f) => f.error, 'error', error),
      ),
    );
    verifyNever(
      () => repository.addExpense(
        groupId: any(named: 'groupId'),
        description: any(named: 'description'),
        amount: any(named: 'amount'),
        paidBy: any(named: 'paidBy'),
        splitType: any(named: 'splitType'),
        shares: any(named: 'shares'),
      ),
    );
  }

  group('AddExpenseUseCase', () {
    test('saves an equal split with the trimmed description', () async {
      await addExpense(
        groupId: 'g1',
        memberIds: _members,
        description: '  Dinner ',
        amount: 60000,
        paidBy: 'sara',
        splitType: SplitType.equal,
      );

      verify(
        () => repository.addExpense(
          groupId: 'g1',
          description: 'Dinner',
          amount: 60000,
          paidBy: 'sara',
          splitType: SplitType.equal,
          shares: {'you': 20000, 'sara': 20000, 'mona': 20000},
        ),
      ).called(1);
    });

    test('gives an equal split leftover to the first members', () async {
      await addExpense(
        groupId: 'g1',
        memberIds: _members,
        description: 'Taxi',
        amount: 10000,
        paidBy: 'you',
        splitType: SplitType.equal,
      );

      expect(savedShares(), {'you': 3334, 'sara': 3333, 'mona': 3333});
    });

    test('ignores custom shares for an equal split', () async {
      await addExpense(
        groupId: 'g1',
        memberIds: _members,
        description: 'Taxi',
        amount: 300,
        paidBy: 'you',
        splitType: SplitType.equal,
        customShares: {'you': 300, 'sara': 0, 'mona': 0},
      );

      expect(savedShares(), {'you': 100, 'sara': 100, 'mona': 100});
    });

    test('saves custom shares in group order', () async {
      await addExpense(
        groupId: 'g1',
        memberIds: _members,
        description: 'Dinner',
        amount: 60000,
        paidBy: 'you',
        splitType: SplitType.custom,
        customShares: {'mona': 10000, 'you': 30000, 'sara': 20000},
      );

      final shares = savedShares();
      expect(shares, {'you': 30000, 'sara': 20000, 'mona': 10000});
      expect(shares.keys, _members);
    });

    test('rejects custom shares that do not add up', () {
      return expectRejected(
        () => addExpense(
          groupId: 'g1',
          memberIds: _members,
          description: 'Dinner',
          amount: 60000,
          paidBy: 'you',
          splitType: SplitType.custom,
          customShares: {'you': 30000, 'sara': 20000, 'mona': 5000},
        ),
        ExpenseValidationError.sharesDoNotAddUp,
      );
    });

    test('rejects a negative custom share', () {
      return expectRejected(
        () => addExpense(
          groupId: 'g1',
          memberIds: _members,
          description: 'Dinner',
          amount: 60000,
          paidBy: 'you',
          splitType: SplitType.custom,
          customShares: {'you': 70000, 'sara': -10000, 'mona': 0},
        ),
        ExpenseValidationError.negativeShare,
      );
    });

    test('rejects an empty description', () {
      return expectRejected(
        () => addExpense(
          groupId: 'g1',
          memberIds: _members,
          description: '   ',
          amount: 60000,
          paidBy: 'you',
          splitType: SplitType.equal,
        ),
        ExpenseValidationError.descriptionRequired,
      );
    });

    test('rejects amounts outside the limits', () async {
      for (final (amount, error) in [
        (0, ExpenseValidationError.amountTooSmall),
        (100000001, ExpenseValidationError.amountTooLarge),
      ]) {
        await expectRejected(
          () => addExpense(
            groupId: 'g1',
            memberIds: _members,
            description: 'Dinner',
            amount: amount,
            paidBy: 'you',
            splitType: SplitType.equal,
          ),
          error,
        );
      }
    });

    test('accepts the smallest and largest amounts', () async {
      for (final amount in [1, 100000000]) {
        await addExpense(
          groupId: 'g1',
          memberIds: _members,
          description: 'Dinner',
          amount: amount,
          paidBy: 'you',
          splitType: SplitType.equal,
        );
      }

      verify(
        () => repository.addExpense(
          groupId: any(named: 'groupId'),
          description: any(named: 'description'),
          amount: any(named: 'amount'),
          paidBy: any(named: 'paidBy'),
          splitType: any(named: 'splitType'),
          shares: any(named: 'shares'),
        ),
      ).called(2);
    });

    test('rejects a payer who is not a member', () {
      return expectRejected(
        () => addExpense(
          groupId: 'g1',
          memberIds: _members,
          description: 'Dinner',
          amount: 60000,
          paidBy: 'omar',
          splitType: SplitType.equal,
        ),
        ExpenseValidationError.unknownPayer,
      );
    });

    test("passes on the repository's failure", () async {
      when(
        () => repository.addExpense(
          groupId: any(named: 'groupId'),
          description: any(named: 'description'),
          amount: any(named: 'amount'),
          paidBy: any(named: 'paidBy'),
          splitType: any(named: 'splitType'),
          shares: any(named: 'shares'),
        ),
      ).thenThrow(const NetworkFailure());

      await expectLater(
        () => addExpense(
          groupId: 'g1',
          memberIds: _members,
          description: 'Dinner',
          amount: 60000,
          paidBy: 'you',
          splitType: SplitType.equal,
        ),
        throwsA(isA<NetworkFailure>()),
      );
    });
  });
}
