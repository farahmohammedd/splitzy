import 'package:splitzy/features/groups/domain/entities/group.dart';

/// What the app needs from group storage.
///
/// Every method throws a `Failure` when the operation fails: a
/// `GroupFailure` or a shared failure such as `NetworkFailure`.
abstract interface class GroupRepository {
  /// The groups owned by [ownerId], newest first: the current list, then the
  /// whole list again on every change.
  Stream<List<Group>> watchGroups(String ownerId);

  /// Creates a group owned by [ownerId]. Its members are the owner (named
  /// [ownerName], with [ownerId] as member id) followed by [memberNames] in
  /// order. Inputs are already validated and trimmed.
  Future<void> createGroup({
    required String ownerId,
    required String ownerName,
    required String name,
    required List<String> memberNames,
  });
}
