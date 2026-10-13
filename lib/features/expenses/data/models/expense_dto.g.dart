// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ExpenseDto _$ExpenseDtoFromJson(Map<String, dynamic> json) => _ExpenseDto(
  description: json['description'] as String,
  amount: (json['amount'] as num).toInt(),
  currency: json['currency'] as String,
  paidBy: json['paidBy'] as String,
  splitType: $enumDecode(_$SplitTypeEnumMap, json['splitType']),
  shares: Map<String, int>.from(json['shares'] as Map),
  createdAt: const TimestampConverter().fromJson(json['createdAt']),
);

Map<String, dynamic> _$ExpenseDtoToJson(_ExpenseDto instance) =>
    <String, dynamic>{
      'description': instance.description,
      'amount': instance.amount,
      'currency': instance.currency,
      'paidBy': instance.paidBy,
      'splitType': _$SplitTypeEnumMap[instance.splitType]!,
      'shares': instance.shares,
      'createdAt': const TimestampConverter().toJson(instance.createdAt),
    };

const _$SplitTypeEnumMap = {
  SplitType.equal: 'equal',
  SplitType.custom: 'custom',
};
