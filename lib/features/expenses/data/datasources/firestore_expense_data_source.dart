import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/expenses/data/mappers/firestore_expense_exception_mapper.dart';
import 'package:splitzy/features/expenses/data/models/expense_dto.dart';

/// An expense document read from Firestore: its id and its data.
typedef ExpenseDocument = ({String id, ExpenseDto data});

/// Thin wrapper over each group's `expenses` subcollection: one method per
/// Firestore call, no business rules. Firestore errors are translated into
/// project exceptions ([AppException]) with their original stack trace; any
/// other error passes through unchanged.
class FirestoreExpenseDataSource {
  const FirestoreExpenseDataSource(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> _expenses(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('expenses');

  /// The expenses of the group [groupId], unordered, then again on every
  /// change. The security rules allow it only for the group's owner.
  Stream<List<ExpenseDocument>> watchExpenses(String groupId) {
    return _expenses(groupId)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              (id: doc.id, data: ExpenseDto.fromJson(doc.data())),
          ],
        )
        .transform(
          StreamTransformer<
            List<ExpenseDocument>,
            List<ExpenseDocument>
          >.fromHandlers(
            handleError: (error, stackTrace, sink) =>
                sink.addError(_translate(error), stackTrace),
          ),
        );
  }

  /// Adds [expense] to the group [groupId], stamped with the server's time
  /// (its own `createdAt` is ignored).
  Future<void> addExpense(String groupId, ExpenseDto expense) async {
    try {
      await _expenses(
        groupId,
      ).add({...expense.toJson(), 'createdAt': FieldValue.serverTimestamp()});
    } on FirebaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(
        mapFirestoreExpenseException(error),
        stackTrace,
      );
    }
  }

  static Object _translate(Object error) =>
      error is FirebaseException ? mapFirestoreExpenseException(error) : error;
}
