/// Why the input for a new expense was rejected.
enum ExpenseValidationError {
  descriptionRequired,
  descriptionTooLong,
  amountRequired,
  amountInvalid,
  amountTooSmall,
  amountTooLarge,
  unknownPayer,
  sharesDoNotMatchMembers,
  negativeShare,
  sharesDoNotAddUp;

  /// The text shown to the user.
  String get message {
    return switch (this) {
      descriptionRequired => 'Enter what it was for.',
      descriptionTooLong =>
        'Description must be ${ExpenseValidation.maxDescriptionLength} '
            'characters or fewer.',
      amountRequired => 'Enter an amount.',
      amountInvalid => 'Enter an amount like 150 or 150.50.',
      amountTooSmall => 'Amount must be at least EGP 0.01.',
      amountTooLarge => "Amount can't be more than EGP 1,000,000.",
      unknownPayer => 'Choose who paid.',
      sharesDoNotMatchMembers => 'Enter a share for every member.',
      negativeShare => "Shares can't be negative.",
      sharesDoNotAddUp => 'Shares must add up to the amount.',
    };
  }
}

/// Input rules for adding an expense. Each check returns the first problem
/// found, or `null` when the input is valid. Amounts are integer piastres.
abstract final class ExpenseValidation {
  static const int maxDescriptionLength = 50;

  /// 1 piastre (EGP 0.01).
  static const int minAmount = 1;

  /// EGP 1,000,000 in piastres.
  static const int maxAmount = 100000000;

  /// Whole pounds, optionally followed by a dot and one or two digits of
  /// piastres: "150", "150.5", "150.50".
  static final RegExp _amountPattern = RegExp(r'^(\d+)(?:\.(\d{1,2}))?$');

  static ExpenseValidationError? description(String description) {
    final value = description.trim();
    if (value.isEmpty) return ExpenseValidationError.descriptionRequired;
    if (value.length > maxDescriptionLength) {
      return ExpenseValidationError.descriptionTooLong;
    }
    return null;
  }

  static ExpenseValidationError? amount(int amount) {
    if (amount < minAmount) return ExpenseValidationError.amountTooSmall;
    if (amount > maxAmount) return ExpenseValidationError.amountTooLarge;
    return null;
  }

  /// Reads an amount typed in pounds (surrounding whitespace ignored) as
  /// piastres: "150.50" is 15050. Returns `null` when [text] is not written
  /// like that (e.g. "abc", "1.505", "-5" or "1,000").
  static int? parseAmount(String text) {
    final match = _amountPattern.firstMatch(text.trim());
    if (match == null) return null;

    final pounds = match.group(1) ?? '';
    final piastres = (match.group(2) ?? '').padRight(2, '0');
    // Longer than the maximum's digits: too large, and safe from overflow.
    if (pounds.length > 9) return maxAmount + 1;
    return int.parse(pounds) * 100 + int.parse(piastres);
  }

  /// Checks an amount typed in pounds: present, written like "150.50", and
  /// within the limits.
  static ExpenseValidationError? amountText(String text) {
    if (text.trim().isEmpty) return ExpenseValidationError.amountRequired;
    final parsed = parseAmount(text);
    if (parsed == null) return ExpenseValidationError.amountInvalid;
    return amount(parsed);
  }

  static ExpenseValidationError? payer(String paidBy, List<String> memberIds) {
    return memberIds.contains(paidBy)
        ? null
        : ExpenseValidationError.unknownPayer;
  }

  /// Checks hand-entered shares: exactly one per member, none negative, and
  /// adding up to [amount].
  static ExpenseValidationError? customShares(
    Map<String, int> shares,
    int amount,
    List<String> memberIds,
  ) {
    if (shares.length != memberIds.length ||
        !memberIds.every(shares.containsKey)) {
      return ExpenseValidationError.sharesDoNotMatchMembers;
    }
    if (shares.values.any((share) => share < 0)) {
      return ExpenseValidationError.negativeShare;
    }
    final total = shares.values.fold(0, (sum, share) => sum + share);
    if (total != amount) return ExpenseValidationError.sharesDoNotAddUp;
    return null;
  }
}
