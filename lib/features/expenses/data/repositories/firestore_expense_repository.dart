import 'dart:async';

import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/expenses/data/datasources/firestore_expense_data_source.dart';
import 'package:splitzy/features/expenses/data/exceptions/expense_exceptions.dart';
import 'package:splitzy/features/expenses/data/models/expense_dto.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/domain/failures/expense_failure.dart';
import 'package:splitzy/features/expenses/domain/repositories/expense_repository.dart';

/// [ExpenseRepository] backed by Cloud Firestore.
///
/// Maps expense documents to [Expense]s and the data source's project
/// exceptions ([AppException]) to [Failure]s, keeping the original stack
/// trace, so no Firestore type leaves the data layer.
class FirestoreExpenseRepository implements ExpenseRepository {
  FirestoreExpenseRepository(this._dataSource, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final FirestoreExpenseDataSource _dataSource;

  /// Stands in for an expense's time while the server timestamp is still
  /// pending (the expense was just added on this device).
  final DateTime Function() _clock;

  @override
  Stream<List<Expense>> watchExpenses(String groupId) {
    return _dataSource
        .watchExpenses(groupId)
        .map((documents) => _toExpenses(groupId, documents))
        .transform(
          StreamTransformer<List<Expense>, List<Expense>>.fromHandlers(
            handleError: (error, stackTrace, sink) => sink.addError(
              error is AppException ? _toFailure(error) : error,
              stackTrace,
            ),
          ),
        );
  }

  @override
  Future<void> addExpense({
    required String groupId,
    required String description,
    required int amount,
    required String paidBy,
    required SplitType splitType,
    required Map<String, int> shares,
  }) async {
    try {
      await _dataSource.addExpense(
        groupId,
        ExpenseDto(
          description: description,
          amount: amount,
          currency: Expense.egp,
          paidBy: paidBy,
          splitType: splitType,
          shares: shares,
        ),
      );
    } on AppException catch (error, stackTrace) {
      Error.throwWithStackTrace(_toFailure(error), stackTrace);
    }
  }

  /// Newest first; expenses added at the same time are ordered by id so the
  /// order is stable.
  List<Expense> _toExpenses(String groupId, List<ExpenseDocument> documents) {
    final now = _clock();
    final expenses = [
      for (final (:id, :data) in documents)
        data.toEntity(
          id: id,
          groupId: groupId,
          createdAt: data.createdAt ?? now,
        ),
    ];
    return expenses..sort((a, b) {
      final byTime = b.createdAt.compareTo(a.createdAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
  }

  static Failure _toFailure(AppException exception) {
    return switch (exception) {
      NetworkException() => const NetworkFailure(),
      UnknownExpenseException(:final code) => UnknownExpenseFailure(code),
      // A project exception this repository does not know about.
      _ => const UnexpectedFailure(),
    };
  }
}
