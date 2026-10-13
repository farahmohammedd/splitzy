import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/features/expenses/domain/validation/expense_validation.dart';

const _members = ['you', 'sara', 'mona'];

void main() {
  group('ExpenseValidation.description', () {
    test('accepts 1 to 50 characters, ignoring surrounding spaces', () {
      expect(ExpenseValidation.description('D'), isNull);
      expect(ExpenseValidation.description('  Dinner  '), isNull);
      expect(ExpenseValidation.description('a' * 50), isNull);
    });

    test('rejects an empty description', () {
      expect(
        ExpenseValidation.description('   '),
        ExpenseValidationError.descriptionRequired,
      );
    });

    test('rejects more than 50 characters', () {
      expect(
        ExpenseValidation.description('a' * 51),
        ExpenseValidationError.descriptionTooLong,
      );
    });
  });

  group('ExpenseValidation.amount', () {
    test('accepts 1 piastre up to EGP 1,000,000', () {
      expect(ExpenseValidation.amount(1), isNull);
      expect(ExpenseValidation.amount(60000), isNull);
      expect(ExpenseValidation.amount(100000000), isNull);
    });

    test('rejects zero and negative amounts', () {
      expect(
        ExpenseValidation.amount(0),
        ExpenseValidationError.amountTooSmall,
      );
      expect(
        ExpenseValidation.amount(-100),
        ExpenseValidationError.amountTooSmall,
      );
    });

    test('rejects more than EGP 1,000,000', () {
      expect(
        ExpenseValidation.amount(100000001),
        ExpenseValidationError.amountTooLarge,
      );
    });
  });

  group('ExpenseValidation.parseAmount', () {
    test('reads pounds as piastres', () {
      expect(ExpenseValidation.parseAmount('600'), 60000);
      expect(ExpenseValidation.parseAmount('150.50'), 15050);
      expect(ExpenseValidation.parseAmount('150.5'), 15050);
      expect(ExpenseValidation.parseAmount('0.01'), 1);
      expect(ExpenseValidation.parseAmount(' 12.34 '), 1234);
      expect(ExpenseValidation.parseAmount('1000000'), 100000000);
    });

    test('rejects text that is not an amount', () {
      for (final text in [
        '',
        'abc',
        '150.505',
        '-5',
        '1,000',
        '1.',
        '.5',
        '1.2.3',
        '1 000',
        '١٢',
      ]) {
        expect(ExpenseValidation.parseAmount(text), isNull, reason: text);
      }
    });

    test('reads a huge number as too large instead of overflowing', () {
      final parsed = ExpenseValidation.parseAmount('9' * 30);

      expect(parsed, isNotNull);
      expect(
        ExpenseValidation.amount(parsed ?? 0),
        ExpenseValidationError.amountTooLarge,
      );
    });
  });

  group('ExpenseValidation.amountText', () {
    test('accepts a valid amount', () {
      expect(ExpenseValidation.amountText('150.50'), isNull);
    });

    test('names the problem with the typed amount', () {
      expect(
        ExpenseValidation.amountText('  '),
        ExpenseValidationError.amountRequired,
      );
      expect(
        ExpenseValidation.amountText('abc'),
        ExpenseValidationError.amountInvalid,
      );
      expect(
        ExpenseValidation.amountText('0'),
        ExpenseValidationError.amountTooSmall,
      );
      expect(
        ExpenseValidation.amountText('0.00'),
        ExpenseValidationError.amountTooSmall,
      );
      expect(
        ExpenseValidation.amountText('1000000.01'),
        ExpenseValidationError.amountTooLarge,
      );
    });
  });

  group('ExpenseValidation.payer', () {
    test('accepts a member of the group', () {
      expect(ExpenseValidation.payer('sara', _members), isNull);
    });

    test('rejects anyone else', () {
      expect(
        ExpenseValidation.payer('omar', _members),
        ExpenseValidationError.unknownPayer,
      );
    });
  });

  group('ExpenseValidation.customShares', () {
    test('accepts shares that add up to the amount, zero included', () {
      expect(
        ExpenseValidation.customShares(
          {'you': 30000, 'sara': 30000, 'mona': 0},
          60000,
          _members,
        ),
        isNull,
      );
    });

    test('rejects shares that do not add up to the amount', () {
      expect(
        ExpenseValidation.customShares(
          {'you': 30000, 'sara': 20000, 'mona': 5000},
          60000,
          _members,
        ),
        ExpenseValidationError.sharesDoNotAddUp,
      );
      expect(
        ExpenseValidation.customShares(
          {'you': 30000, 'sara': 20000, 'mona': 10001},
          60000,
          _members,
        ),
        ExpenseValidationError.sharesDoNotAddUp,
      );
    });

    test('rejects a negative share even when the total matches', () {
      expect(
        ExpenseValidation.customShares(
          {'you': 70000, 'sara': -10000, 'mona': 0},
          60000,
          _members,
        ),
        ExpenseValidationError.negativeShare,
      );
    });

    test('rejects a missing, extra or unknown member', () {
      expect(
        ExpenseValidation.customShares(
          {'you': 30000, 'sara': 30000},
          60000,
          _members,
        ),
        ExpenseValidationError.sharesDoNotMatchMembers,
      );
      expect(
        ExpenseValidation.customShares(
          {'you': 30000, 'sara': 30000, 'mona': 0, 'omar': 0},
          60000,
          _members,
        ),
        ExpenseValidationError.sharesDoNotMatchMembers,
      );
      expect(
        ExpenseValidation.customShares(
          {'you': 30000, 'sara': 30000, 'omar': 0},
          60000,
          _members,
        ),
        ExpenseValidationError.sharesDoNotMatchMembers,
      );
    });
  });

  group('ExpenseValidationError.message', () {
    test('every error has a message', () {
      for (final error in ExpenseValidationError.values) {
        expect(error.message, isNotEmpty, reason: error.name);
      }
    });

    test('states the limits', () {
      expect(
        ExpenseValidationError.descriptionTooLong.message,
        'Description must be 50 characters or fewer.',
      );
      expect(
        ExpenseValidationError.amountTooLarge.message,
        "Amount can't be more than EGP 1,000,000.",
      );
    });
  });
}
