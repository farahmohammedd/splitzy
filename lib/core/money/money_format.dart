/// Formats [piastres] as Egyptian pounds for display: "EGP 600" for a whole
/// amount, otherwise with two digits of piastres ("EGP 1,234.50"), with
/// thousands separators. A negative amount starts with a minus sign
/// ("-EGP 120").
///
/// Pure Dart, shared by every feature that shows money (see `CLAUDE.md` →
/// Money).
String formatEgp(int piastres) {
  final sign = piastres < 0 ? '-' : '';
  return '${sign}EGP ${_pounds(piastres.abs())}';
}

/// Formats a balance in [piastres] as a signed number without the currency,
/// as in the design reference: "+ 1,000" when owed, "- 120" when owing,
/// "0" when settled.
String formatBalance(int piastres) {
  if (piastres == 0) return '0';
  final sign = piastres > 0 ? '+' : '-';
  return '$sign ${_pounds(piastres.abs())}';
}

/// [piastres] (not negative) as pounds: "1,234" or "1,234.50".
String _pounds(int piastres) {
  final pounds = _groupThousands(piastres ~/ 100);
  final rest = piastres % 100;
  final fraction = rest == 0 ? '' : '.${rest.toString().padLeft(2, '0')}';
  return '$pounds$fraction';
}

/// "1234567" → "1,234,567".
String _groupThousands(int value) {
  final digits = value.toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }
  return buffer.toString();
}
