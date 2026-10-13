import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:splitzy/core/firestore/timestamp_converter.dart';
import 'package:splitzy/features/expenses/domain/entities/expense.dart';

part 'expense_dto.freezed.dart';
part 'expense_dto.g.dart';

/// An expense document as stored in Firestore
/// (`groups/{groupId}/expenses/{expenseId}`). The document and group ids are
/// not part of the data; they are passed to [toEntity].
@freezed
abstract class ExpenseDto with _$ExpenseDto {
  const ExpenseDto._();

  const factory ExpenseDto({
    required String description,

    /// In piastres.
    required int amount,
    required String currency,

    /// The paying member's id.
    required String paidBy,

    /// Stored by name: `equal` or `custom`.
    required SplitType splitType,

    /// Every member's share in piastres, by member id.
    required Map<String, int> shares,

    /// `null` while a just-written server timestamp is still pending. The
    /// data source writes the server's time instead of this value.
    @TimestampConverter() DateTime? createdAt,
  }) = _ExpenseDto;

  factory ExpenseDto.fromJson(Map<String, dynamic> json) =>
      _$ExpenseDtoFromJson(json);

  /// The domain [Expense] with document id [id] in group [groupId].
  /// [createdAt] replaces this DTO's own value, which can be pending (see
  /// [ExpenseDto.createdAt]).
  Expense toEntity({
    required String id,
    required String groupId,
    required DateTime createdAt,
  }) {
    return Expense(
      id: id,
      groupId: groupId,
      description: description,
      amount: amount,
      currency: currency,
      paidBy: paidBy,
      splitType: splitType,
      shares: shares,
      createdAt: createdAt,
    );
  }
}
