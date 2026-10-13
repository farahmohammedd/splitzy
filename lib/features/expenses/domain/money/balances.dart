import 'package:splitzy/features/expenses/domain/entities/expense.dart';

/// The total of [expenses]' amounts, in piastres.
int totalAmount(List<Expense> expenses) =>
    expenses.fold(0, (total, expense) => total + expense.amount);

/// How much of [expenses] is [memberId]'s share, in piastres.
int shareOf(List<Expense> expenses, String memberId) => expenses.fold(
  0,
  (total, expense) => total + (expense.shares[memberId] ?? 0),
);

/// The user's position across groups, from their balance in each group (in
/// piastres): [owed] adds up the groups where they are owed, [owe] the
/// groups where they owe (as a positive amount), and [total] is
/// `owed - owe`.
///
/// Groups are added up separately because a debt in one group is to
/// different people than a credit in another.
({int owed, int owe, int total}) overallBalance(Iterable<int> groupBalances) {
  var owed = 0;
  var owe = 0;
  for (final balance in groupBalances) {
    if (balance > 0) {
      owed += balance;
    } else {
      owe -= balance;
    }
  }
  return (owed: owed, owe: owe, total: owed - owe);
}

/// Every member's balance in piastres, by member id, in [memberIds]' order:
/// what they paid minus their shares. Positive: they are owed; negative:
/// they owe.
///
/// Every expense's shares add up to its amount, so the balances of a
/// group's members always add up to zero.
Map<String, int> balancesOf(List<Expense> expenses, List<String> memberIds) {
  final balances = {for (final id in memberIds) id: 0};
  for (final expense in expenses) {
    // Expenses only name group members (see the security rules); anyone
    // else is ignored rather than added.
    if (balances.containsKey(expense.paidBy)) {
      balances.update(expense.paidBy, (balance) => balance + expense.amount);
    }
    expense.shares.forEach((id, share) {
      if (balances.containsKey(id)) {
        balances.update(id, (balance) => balance - share);
      }
    });
  }
  return balances;
}
