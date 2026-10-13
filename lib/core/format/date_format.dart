const _months = [
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
];

/// "Oct 12": the month and day of [date] in the device's time zone, without
/// the year (decided for group and expense dates).
///
/// Pure Dart, shared by every feature that shows dates; no formatting
/// package (see `CLAUDE.md` → Open Decisions #6, localization).
String formatMonthDay(DateTime date) {
  final local = date.toLocal();
  return '${_months[local.month - 1]} ${local.day}';
}
