/// Divides [amount] piastres evenly between [memberIds], in their group
/// order. When it does not divide exactly, the leftover piastres go one each
/// to the first members, so the shares always add up to [amount].
///
/// For example, 10000 piastres (EGP 100) between three members gives 3334,
/// 3333 and 3333.
///
/// Throws an [ArgumentError] when [amount] is negative or [memberIds] is
/// empty.
Map<String, int> splitEqually(int amount, List<String> memberIds) {
  if (amount < 0) {
    throw ArgumentError.value(amount, 'amount', 'must not be negative');
  }
  if (memberIds.isEmpty) {
    throw ArgumentError.value(memberIds, 'memberIds', 'must not be empty');
  }

  final base = amount ~/ memberIds.length;
  final leftover = amount % memberIds.length;
  return {
    for (final (i, id) in memberIds.indexed) id: base + (i < leftover ? 1 : 0),
  };
}
