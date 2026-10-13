import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';

Expense _expense({Map<String, int> shares = const {'you': 300, 'sara': 300}}) {
  return Expense(
    id: 'e1',
    groupId: 'g1',
    description: 'Dinner',
    amount: 600,
    currency: Expense.egp,
    paidBy: 'sara',
    splitType: SplitType.equal,
    shares: shares,
    createdAt: DateTime.utc(2026, 10, 12),
  );
}

void main() {
  group('Expense', () {
    test('expenses with the same values are equal', () {
      expect(_expense(), _expense());
    });

    test('expenses with different shares are not equal', () {
      expect(
        _expense(),
        isNot(_expense(shares: const {'you': 600, 'sara': 0})),
      );
    });

    test('the only currency is EGP', () {
      expect(Expense.egp, 'EGP');
    });
  });
}
