import 'package:freezed_annotation/freezed_annotation.dart';

part 'expense.freezed.dart';

/// How an expense's amount is divided between the group's members.
enum SplitType {
  /// The amount divided evenly; leftover piastres go one each to the first
  /// members in group order (see `splitEqually`).
  equal,

  /// Every member's share entered by hand; the shares add up to the amount.
  custom,
}

/// Money one member paid for the group, and how much of it is each member's
/// share. Amounts are integer piastres (EGP minor units), never `double`.
@freezed
abstract class Expense with _$Expense {
  const factory Expense({
    required String id,
    required String groupId,
    required String description,

    /// In piastres: EGP 150.50 is 15050.
    required int amount,

    /// The ISO 4217 code; only [egp] for now.
    required String currency,

    /// The member id of the one member who paid the whole amount.
    required String paidBy,
    required SplitType splitType,

    /// Every group member's share in piastres, by member id; they add up to
    /// [amount]. Stored when the expense is added, so later membership
    /// changes never rewrite it.
    required Map<String, int> shares,
    required DateTime createdAt,
  }) = _Expense;

  /// The only currency for now (see `CLAUDE.md` → Money).
  static const String egp = 'EGP';
}
