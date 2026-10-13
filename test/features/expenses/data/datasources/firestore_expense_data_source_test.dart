import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/expenses/data/datasources/firestore_expense_data_source.dart';
import 'package:splitzy/features/expenses/data/exceptions/expense_exceptions.dart';
import 'package:splitzy/features/expenses/data/models/expense_dto.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';

typedef _Json = Map<String, dynamic>;

// cloud_firestore marks these SDK types @sealed so apps do not implement
// them; implementing them is the only way to mock Firestore with mocktail
// (the approved test library; a fake-Firestore package would be a new
// dependency). Test-only.
// ignore_for_file: subtype_of_sealed_class

class _MockFirestore extends Mock implements FirebaseFirestore {}

class _MockCollection extends Mock implements CollectionReference<_Json> {}

class _MockDocumentReference extends Mock implements DocumentReference<_Json> {}

class _MockQuerySnapshot extends Mock implements QuerySnapshot<_Json> {}

class _MockDocument extends Mock implements QueryDocumentSnapshot<_Json> {}

final _originalStack = StackTrace.fromString('original-firestore-stack');

const _expense = ExpenseDto(
  description: 'Dinner',
  amount: 60000,
  currency: 'EGP',
  paidBy: 'sara',
  splitType: SplitType.equal,
  shares: {'you': 20000, 'sara': 20000, 'mona': 20000},
);

void main() {
  late _MockCollection expenses;
  late FirestoreExpenseDataSource dataSource;

  setUp(() {
    final firestore = _MockFirestore();
    final groups = _MockCollection();
    final group = _MockDocumentReference();
    expenses = _MockCollection();
    when(() => firestore.collection('groups')).thenReturn(groups);
    when(() => groups.doc('g1')).thenReturn(group);
    when(() => group.collection('expenses')).thenReturn(expenses);
    dataSource = FirestoreExpenseDataSource(firestore);
  });

  group('watchExpenses', () {
    _MockDocument document(String id, _Json data) {
      final doc = _MockDocument();
      when(() => doc.id).thenReturn(id);
      when(doc.data).thenReturn(data);
      return doc;
    }

    test("reads the group's expenses, with their ids", () async {
      final snapshot = _MockQuerySnapshot();
      final doc = document('e1', {
        'description': 'Dinner',
        'amount': 60000,
        'currency': 'EGP',
        'paidBy': 'sara',
        'splitType': 'equal',
        'shares': {'you': 20000, 'sara': 20000, 'mona': 20000},
        'createdAt': null,
      });
      when(() => snapshot.docs).thenReturn([doc]);
      when(expenses.snapshots).thenAnswer((_) => Stream.value(snapshot));

      final documents = await dataSource.watchExpenses('g1').first;

      expect(documents.single.id, 'e1');
      expect(documents.single.data, _expense);
    });

    test('translates a Firestore error, keeping its stack trace', () async {
      when(expenses.snapshots).thenAnswer(
        (_) => Stream.error(
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
          _originalStack,
        ),
      );

      try {
        await dataSource.watchExpenses('g1').first;
        fail('watchExpenses should have failed');
      } on NetworkException catch (_, stackTrace) {
        expect(stackTrace.toString(), _originalStack.toString());
      }
    });

    test('passes other errors through unchanged', () async {
      final error = StateError('bug');
      when(expenses.snapshots).thenAnswer((_) => Stream.error(error));

      await expectLater(
        dataSource.watchExpenses('g1'),
        emitsError(same(error)),
      );
    });
  });

  group('addExpense', () {
    test(
      "adds the expense to the group's expenses with the server's time",
      () async {
        final added = _MockDocumentReference();
        when(() => expenses.add(any())).thenAnswer((_) async => added);

        await dataSource.addExpense('g1', _expense);

        final data =
            verify(() => expenses.add(captureAny())).captured.single as _Json;
        expect(data, {
          'description': 'Dinner',
          'amount': 60000,
          'currency': 'EGP',
          'paidBy': 'sara',
          'splitType': 'equal',
          'shares': {'you': 20000, 'sara': 20000, 'mona': 20000},
          'createdAt': FieldValue.serverTimestamp(),
        });
      },
    );

    test('translates a Firestore error, keeping its stack trace', () async {
      when(() => expenses.add(any())).thenAnswer(
        (_) => Future.error(
          FirebaseException(plugin: 'cloud_firestore', code: 'unavailable'),
          _originalStack,
        ),
      );

      try {
        await dataSource.addExpense('g1', _expense);
        fail('addExpense should have thrown');
      } on NetworkException catch (_, stackTrace) {
        expect(stackTrace, _originalStack);
      }
    });

    test('a rejected write keeps its code', () async {
      when(() => expenses.add(any())).thenThrow(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      await expectLater(
        dataSource.addExpense('g1', _expense),
        throwsA(
          isA<UnknownExpenseException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    });

    test('passes any other error through unchanged', () async {
      final error = StateError('boom');
      when(() => expenses.add(any())).thenThrow(error);

      await expectLater(dataSource.addExpense('g1', _expense), throwsA(error));
    });
  });
}
