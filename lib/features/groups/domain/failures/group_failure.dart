import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/groups/domain/validation/group_validation.dart';

/// Why a group operation failed, in domain terms, with the text to show the
/// user.
///
/// Thrown by the group repository and use cases; controllers turn it into an
/// `AsyncError` through `runGuarded`. Shared failures such as
/// `NetworkFailure` come from `core/error/failures.dart`.
sealed class GroupFailure extends Failure {
  const GroupFailure();
}

/// The input broke a validation rule; nothing was sent to the backend.
final class InvalidGroupInput extends GroupFailure {
  const InvalidGroupInput(this.error);

  final GroupValidationError error;

  @override
  String get message => error.message;

  @override
  String toString() => 'InvalidGroupInput($error)';
}

/// Any other failure; [code] keeps the original error code for debugging and
/// is never shown to the user.
final class UnknownGroupFailure extends GroupFailure {
  const UnknownGroupFailure(this.code);

  final String code;

  @override
  String get message => const UnexpectedFailure().message;

  @override
  String toString() => 'UnknownGroupFailure($code)';
}
