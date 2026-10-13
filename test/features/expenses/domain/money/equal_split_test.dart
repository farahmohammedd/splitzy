import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/features/expenses/domain/money/equal_split.dart';

int _total(Map<String, int> shares) =>
    shares.values.fold(0, (sum, share) => sum + share);

void main() {
  group('splitEqually', () {
    test('divides an amount that divides exactly', () {
      expect(splitEqually(60000, ['you', 'sara', 'mona']), {
        'you': 20000,
        'sara': 20000,
        'mona': 20000,
      });
    });

    test('gives a leftover piastre to the first member', () {
      expect(splitEqually(10000, ['you', 'sara', 'mona']), {
        'you': 3334,
        'sara': 3333,
        'mona': 3333,
      });
    });

    test('gives leftover piastres one each to the first members in order', () {
      expect(splitEqually(10001, ['you', 'sara', 'mona']), {
        'you': 3334,
        'sara': 3334,
        'mona': 3333,
      });
      expect(splitEqually(10, ['a', 'b', 'c', 'd']), {
        'a': 3,
        'b': 3,
        'c': 2,
        'd': 2,
      });
    });

    test('keeps the members in group order', () {
      expect(splitEqually(5, ['mona', 'you', 'sara']).keys, [
        'mona',
        'you',
        'sara',
      ]);
    });

    test('gives some members nothing when there are more members than '
        'piastres', () {
      expect(splitEqually(2, ['a', 'b', 'c']), {'a': 1, 'b': 1, 'c': 0});
    });

    test('gives a single member the whole amount', () {
      expect(splitEqually(12345, ['you']), {'you': 12345});
    });

    test('splits the maximum amount between the most members', () {
      final members = [for (var i = 0; i < 50; i++) 'm$i'];

      final shares = splitEqually(100000000, members);

      expect(shares.values.toSet(), {2000000});
      expect(_total(shares), 100000000);
    });

    test('shares always add up to the amount and differ by at most one '
        'piastre', () {
      for (final amount in [1, 2, 7, 99, 100, 101, 9999, 10000, 100000000]) {
        for (var count = 1; count <= 7; count++) {
          final members = [for (var i = 0; i < count; i++) 'm$i'];

          final shares = splitEqually(amount, members);
          final values = shares.values.toList();

          final reason = '$amount between $count';
          expect(_total(shares), amount, reason: reason);
          expect(shares.keys, members, reason: reason);
          expect(
            values.reduce((a, b) => a > b ? a : b) -
                values.reduce((a, b) => a < b ? a : b),
            lessThanOrEqualTo(1),
            reason: reason,
          );
        }
      }
    });

    test('rejects a negative amount', () {
      expect(() => splitEqually(-1, ['you']), throwsArgumentError);
    });

    test('rejects an empty member list', () {
      expect(() => splitEqually(100, []), throwsArgumentError);
    });
  });
}
