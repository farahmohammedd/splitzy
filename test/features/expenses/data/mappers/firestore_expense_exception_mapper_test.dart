import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/expenses/data/exceptions/expense_exceptions.dart';
import 'package:splitzy/features/expenses/data/mappers/firestore_expense_exception_mapper.dart';

FirebaseException _firestoreError(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

void main() {
  group('mapFirestoreExpenseException', () {
    test('an unreachable backend is a network error', () {
      expect(
        mapFirestoreExpenseException(_firestoreError('unavailable')),
        isA<NetworkException>(),
      );
    });

    test('any other code is an unknown expense error keeping the code', () {
      for (final code in ['permission-denied', 'not-found', 'internal']) {
        expect(
          mapFirestoreExpenseException(_firestoreError(code)),
          isA<UnknownExpenseException>().having((e) => e.code, 'code', code),
          reason: code,
        );
      }
    });
  });

  group('UnknownExpenseException', () {
    test('is a project exception that shows its code when printed', () {
      const exception = UnknownExpenseException('permission-denied');

      expect(exception, isA<AppException>());
      expect(exception.toString(), contains('permission-denied'));
    });
  });
}
