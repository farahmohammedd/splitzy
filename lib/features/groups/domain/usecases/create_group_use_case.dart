import 'package:splitzy/features/groups/domain/failures/group_failure.dart';
import 'package:splitzy/features/groups/domain/repositories/group_repository.dart';
import 'package:splitzy/features/groups/domain/validation/group_validation.dart';

/// Creates a group after checking the group rules.
class CreateGroupUseCase {
  const CreateGroupUseCase(this._repository);

  final GroupRepository _repository;

  /// Throws [InvalidGroupInput] without contacting the repository when the
  /// input breaks a rule; otherwise throws whatever failure the repository
  /// reports. All names are trimmed; [ownerName] counts as a member name.
  Future<void> call({
    required String ownerId,
    required String ownerName,
    required String name,
    required List<String> memberNames,
  }) async {
    final trimmedName = name.trim();
    final trimmedOwnerName = ownerName.trim();
    final trimmedMembers = [for (final member in memberNames) member.trim()];

    final error =
        GroupValidation.groupName(trimmedName) ??
        GroupValidation.members([trimmedOwnerName, ...trimmedMembers]);
    if (error != null) throw InvalidGroupInput(error);

    return _repository.createGroup(
      ownerId: ownerId,
      ownerName: trimmedOwnerName,
      name: trimmedName,
      memberNames: trimmedMembers,
    );
  }
}
