import 'dart:async';

import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';
import 'package:splitzy/features/expenses/domain/repositories/expense_repository.dart';

/// One [FakeExpenseRepository.addExpense] call's arguments.
typedef AddExpenseCall = ({
  String groupId,
  String description,
  int amount,
  String paidBy,
  SplitType splitType,
  Map<String, int> shares,
});

/// In-memory [ExpenseRepository] for app, router and controller tests.
///
/// - Every [addExpense] call's arguments are recorded in [addCalls].
/// - [failNextWith] makes the next [addExpense] throw the given (expected)
///   failure; [throwNextWith] makes it throw an unexpected error.
/// - [gate], when set, holds [addExpense] until it completes, so tests can
///   observe the loading state.
class FakeExpenseRepository implements ExpenseRepository {
  /// [expenses] are the stored expenses, newest first. [addExpense] stores
  /// a new one at the front and [watchExpenses] emits a group's expenses now
  /// and after every change.
  FakeExpenseRepository({List<Expense> expenses = const []})
    : _expenses = [...expenses];

  final List<Expense> _expenses;
  final _changes = StreamController<void>.broadcast();
  int _nextId = 0;

  final addCalls = <AddExpenseCall>[];
  Object? _nextError;
  StackTrace? _nextStackTrace;

  /// Holds [addExpense] until completed; `null` lets it finish at once.
  Completer<void>? gate;

  void failNextWith(Failure failure) {
    _nextError = failure;
    _nextStackTrace = null;
  }

  void throwNextWith(Object error, StackTrace stackTrace) {
    _nextError = error;
    _nextStackTrace = stackTrace;
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
    addCalls.add((
      groupId: groupId,
      description: description,
      amount: amount,
      paidBy: paidBy,
      splitType: splitType,
      shares: shares,
    ));
    final pending = gate;
    if (pending != null) await pending.future;
    final error = _nextError;
    if (error != null) {
      final stackTrace = _nextStackTrace;
      _nextError = null;
      _nextStackTrace = null;
      if (stackTrace == null) throw error;
      Error.throwWithStackTrace(error, stackTrace);
    }
    _expenses.insert(
      0,
      Expense(
        id: 'expense-${++_nextId}',
        groupId: groupId,
        description: description,
        amount: amount,
        currency: Expense.egp,
        paidBy: paidBy,
        splitType: splitType,
        shares: shares,
        createdAt: DateTime.utc(2026, 10, 1).add(Duration(minutes: _nextId)),
      ),
    );
    _changes.add(null);
  }

  @override
  Stream<List<Expense>> watchExpenses(String groupId) {
    List<Expense> ofGroup() => [
      for (final expense in _expenses)
        if (expense.groupId == groupId) expense,
    ];

    StreamSubscription<void>? subscription;
    late final StreamController<List<Expense>> controller;
    controller = StreamController<List<Expense>>(
      onListen: () {
        controller.add(ofGroup());
        subscription = _changes.stream.listen((_) => controller.add(ofGroup()));
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  Future<void> dispose() => _changes.close();
}
