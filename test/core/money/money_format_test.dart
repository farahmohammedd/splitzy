import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/money/money_format.dart';

void main() {
  group('formatEgp', () {
    test('shows a whole amount without piastres', () {
      expect(formatEgp(60000), 'EGP 600');
      expect(formatEgp(0), 'EGP 0');
    });

    test('shows two digits of piastres when there are any', () {
      expect(formatEgp(3334), 'EGP 33.34');
      expect(formatEgp(15050), 'EGP 150.50');
      expect(formatEgp(1), 'EGP 0.01');
      expect(formatEgp(105), 'EGP 1.05');
    });

    test('separates thousands', () {
      expect(formatEgp(123450), 'EGP 1,234.50');
      expect(formatEgp(100000), 'EGP 1,000');
      expect(formatEgp(99999900), 'EGP 999,999');
      expect(formatEgp(100000000), 'EGP 1,000,000');
      expect(formatEgp(12345678901), 'EGP 123,456,789.01');
    });

    test('starts a negative amount with a minus sign', () {
      expect(formatEgp(-12000), '-EGP 120');
      expect(formatEgp(-123450), '-EGP 1,234.50');
    });
  });

  group('formatBalance', () {
    test('shows an amount owed with a plus sign', () {
      expect(formatBalance(100000), '+ 1,000');
      expect(formatBalance(3334), '+ 33.34');
    });

    test('shows an amount owing with a minus sign', () {
      expect(formatBalance(-12000), '- 120');
      expect(formatBalance(-123450), '- 1,234.50');
    });

    test('shows a settled balance as 0', () {
      expect(formatBalance(0), '0');
    });
  });
}
