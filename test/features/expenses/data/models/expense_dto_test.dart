import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/features/expenses/data/models/expense_dto.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';

final _created = DateTime.utc(2026, 10, 9, 20, 15);

const _dto = ExpenseDto(
  description: 'Dinner',
  amount: 60000,
  currency: 'EGP',
  paidBy: 'sara',
  splitType: SplitType.custom,
  shares: {'you': 30000, 'sara': 20000, 'mona': 10000},
);

Map<String, dynamic> _json({Object? createdAt}) => {
  'description': 'Dinner',
  'amount': 60000,
  'currency': 'EGP',
  'paidBy': 'sara',
  'splitType': 'custom',
  'shares': {'you': 30000, 'sara': 20000, 'mona': 10000},
  'createdAt': createdAt,
};

void main() {
  group('ExpenseDto', () {
    test('writes the fields Firestore stores, the split type by name', () {
      expect(_dto.toJson(), _json());
      expect(
        _dto.copyWith(splitType: SplitType.equal).toJson()['splitType'],
        'equal',
      );
    });

    test('reads the stored fields back, with the time', () {
      final dto = ExpenseDto.fromJson(
        _json(createdAt: Timestamp.fromDate(_created)),
      );

      expect(dto.copyWith(createdAt: null), _dto);
      expect(dto.createdAt?.isAtSameMomentAs(_created), isTrue);
    });

    test('reads a pending server time as null', () {
      expect(ExpenseDto.fromJson(_json()).createdAt, isNull);
    });

    test('becomes an Expense with its ids and time', () {
      expect(
        _dto.toEntity(id: 'e1', groupId: 'g1', createdAt: _created),
        Expense(
          id: 'e1',
          groupId: 'g1',
          description: 'Dinner',
          amount: 60000,
          currency: 'EGP',
          paidBy: 'sara',
          splitType: SplitType.custom,
          shares: const {'you': 30000, 'sara': 20000, 'mona': 10000},
          createdAt: _created,
        ),
      );
    });
  });
}
