/// Why the input for a new group was rejected.
enum GroupValidationError {
  nameRequired,
  nameTooLong,
  memberNameRequired,
  memberNameTooLong,
  duplicateMemberName,
  tooFewMembers,
  tooManyMembers;

  /// The text shown to the user.
  String get message {
    return switch (this) {
      nameRequired => 'Enter a group name.',
      nameTooLong =>
        'Group name must be ${GroupValidation.maxNameLength} characters '
            'or fewer.',
      memberNameRequired => 'Enter a name for every member.',
      memberNameTooLong =>
        'Member names must be ${GroupValidation.maxNameLength} characters '
            'or fewer.',
      duplicateMemberName => 'Each member needs a different name.',
      tooFewMembers => 'Add at least one other member.',
      tooManyMembers =>
        'A group can have at most ${GroupValidation.maxMembers} members.',
    };
  }
}

/// Input rules for creating a group. Each check returns the first problem
/// found, or `null` when the input is valid. Names are checked ignoring
/// surrounding whitespace.
abstract final class GroupValidation {
  static const int maxNameLength = 50;

  /// The owner plus at least one other member.
  static const int minMembers = 2;
  static const int maxMembers = 50;

  static GroupValidationError? groupName(String name) {
    final value = name.trim();
    if (value.isEmpty) return GroupValidationError.nameRequired;
    if (value.length > maxNameLength) return GroupValidationError.nameTooLong;
    return null;
  }

  static GroupValidationError? memberName(String name) {
    final value = name.trim();
    if (value.isEmpty) return GroupValidationError.memberNameRequired;
    if (value.length > maxNameLength) {
      return GroupValidationError.memberNameTooLong;
    }
    return null;
  }

  /// Checks every member name, the owner's included: each must be valid and
  /// unique within the group, ignoring case.
  static GroupValidationError? members(List<String> names) {
    if (names.length < minMembers) return GroupValidationError.tooFewMembers;
    if (names.length > maxMembers) return GroupValidationError.tooManyMembers;

    final seen = <String>{};
    for (final name in names) {
      final error = memberName(name);
      if (error != null) return error;
      if (!seen.add(name.trim().toLowerCase())) {
        return GroupValidationError.duplicateMemberName;
      }
    }
    return null;
  }
}
