import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/domain/money/balances.dart';
import 'package:splitzy/features/expenses/domain/money/equal_split.dart';

const _members = ['you', 'sara', 'mona', 'omar'];

Expense _expense(
  int amount,
  String paidBy,
  Map<String, int> shares, {
  SplitType splitType = SplitType.custom,
}) {
  return Expense(
    id: 'e-$amount-$paidBy',
    groupId: 'g1',
    description: 'Expense',
    amount: amount,
    currency: Expense.egp,
    paidBy: paidBy,
    splitType: splitType,
    shares: shares,
    createdAt: DateTime.utc(2026, 10, 12),
  );
}

Expense _equal(int amount, String paidBy) => _expense(
  amount,
  paidBy,
  splitEqually(amount, _members),
  splitType: SplitType.equal,
);

int _sum(Map<String, int> balances) =>
    balances.values.fold(0, (sum, balance) => sum + balance);

/// The design reference's example: EGP 2,400 between four members.
final _trip = [
  _equal(160000, 'you'), // Hotel
  _equal(48000, 'sara'), // Dinner
  _equal(32000, 'omar'), // Transport
];

void main() {
  group('totalAmount', () {
    test('adds up the amounts', () {
      expect(totalAmount(_trip), 240000);
    });

    test('is zero without expenses', () {
      expect(totalAmount(const []), 0);
    });
  });

  group('shareOf', () {
    test("adds up a member's shares", () {
      expect(shareOf(_trip, 'you'), 60000);
      expect(shareOf(_trip, 'mona'), 60000);
    });

    test('is zero for a member with no shares', () {
      expect(shareOf(const [], 'you'), 0);
      expect(
        shareOf([
          _expense(1000, 'you', {'you': 1000, 'sara': 0}),
        ], 'sara'),
        0,
      );
    });
  });

  group('overallBalance', () {
    test('adds up what you are owed and what you owe separately', () {
      expect(overallBalance([42000, -15000, 8500]), (
        owed: 50500,
        owe: 15000,
        total: 35500,
      ));
    });

    test('is all owed when every group owes you', () {
      expect(overallBalance([100, 200]), (owed: 300, owe: 0, total: 300));
    });

    test('is all owing when you owe in every group', () {
      expect(overallBalance([-100, -200]), (owed: 0, owe: 300, total: -300));
    });

    test('is settled with no groups or only settled groups', () {
      expect(overallBalance(const []), (owed: 0, owe: 0, total: 0));
      expect(overallBalance([0, 0]), (owed: 0, owe: 0, total: 0));
    });

    test('a credit in one group does not cancel a debt in another', () {
      final result = overallBalance([500, -500]);

      expect(result.owed, 500);
      expect(result.owe, 500);
      expect(result.total, 0);
    });
  });

  group('balancesOf', () {
    test('is what each member paid minus their shares', () {
      expect(balancesOf(_trip, _members), {
        'you': 100000,
        'sara': -12000,
        'mona': -60000,
        'omar': -28000,
      });
    });

    test('lists every member, in group order, at zero without expenses', () {
      final balances = balancesOf(const [], _members);

      expect(balances, {'you': 0, 'sara': 0, 'mona': 0, 'omar': 0});
      expect(balances.keys, _members);
    });

    test('combines equal and custom splits', () {
      final balances = balancesOf([
        _equal(10000, 'sara'),
        _expense(60000, 'you', {
          'you': 30000,
          'sara': 20000,
          'mona': 10000,
          'omar': 0,
        }),
      ], _members);

      expect(balances, {
        'you': 60000 - 2500 - 30000,
        'sara': 10000 - 2500 - 20000,
        'mona': -2500 - 10000,
        'omar': -2500,
      });
    });

    test('a member who paid exactly their share is settled', () {
      final balances = balancesOf([
        _expense(20000, 'you', {'you': 20000, 'sara': 0, 'mona': 0, 'omar': 0}),
      ], _members);

      expect(balances['you'], 0);
    });

    test('always adds up to zero, leftover piastres included', () {
      for (final amounts in [
        [1],
        [10000, 1, 7],
        [100000000, 100000000, 99],
        [3333, 3334, 3335, 101],
      ]) {
        final expenses = [
          for (final (i, amount) in amounts.indexed)
            _equal(amount, _members[i % _members.length]),
        ];

        expect(_sum(balancesOf(expenses, _members)), 0, reason: '$amounts');
      }
    });

    test('ignores anyone who is not a member', () {
      final balances = balancesOf(
        [
          _expense(1000, 'stranger', {'you': 500, 'stranger': 500}),
        ],
        const ['you', 'sara'],
      );

      expect(balances, {'you': -500, 'sara': 0});
    });
  });
}
