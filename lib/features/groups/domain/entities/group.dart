import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';

part 'group.freezed.dart';

/// A group of people who share expenses, owned by the user who created it.
@freezed
abstract class Group with _$Group {
  const factory Group({
    required String id,

    /// The user id of the group's owner (its creator).
    required String ownerId,
    required String name,

    /// In the order they were added; the owner is first. The equal-split
    /// remainder rule depends on this order.
    required List<Member> members,
    required DateTime createdAt,
  }) = _Group;
}
