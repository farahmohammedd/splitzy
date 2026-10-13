import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/format/date_format.dart';

void main() {
  group('formatMonthDay', () {
    test('shows the month and day, without the year', () {
      expect(formatMonthDay(DateTime(2026, 1, 5)), 'Jan 5');
      expect(formatMonthDay(DateTime(2025, 12, 31)), 'Dec 31');
      expect(formatMonthDay(DateTime(2026, 10, 9)), 'Oct 9');
    });

    test('names every month', () {
      final months = [
        for (var month = 1; month <= 12; month++)
          formatMonthDay(DateTime(2026, month, 1)).split(' ').first,
      ];

      expect(months, [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
      ]);
    });

    test('uses the device time zone', () {
      final utc = DateTime.utc(2026, 10, 12, 12);

      expect(formatMonthDay(utc), formatMonthDay(utc.toLocal()));
    });
  });
}
