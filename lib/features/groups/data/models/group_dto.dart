import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';

part 'group_dto.freezed.dart';
part 'group_dto.g.dart';

/// A group document as stored in Firestore (`groups/{groupId}`). The document
/// id is not part of the data; it is passed to [toEntity].
@freezed
abstract class GroupDto with _$GroupDto {
  const GroupDto._();

  const factory GroupDto({
    required String ownerId,
    required String name,
    required List<MemberDto> members,

    /// `null` while a just-written server timestamp is still pending.
    @TimestampConverter() DateTime? createdAt,
  }) = _GroupDto;

  factory GroupDto.fromJson(Map<String, dynamic> json) =>
      _$GroupDtoFromJson(json);

  /// The domain [Group] with document id [id]. [createdAt] replaces this
  /// DTO's own value, which can be pending (see [GroupDto.createdAt]).
  Group toEntity({required String id, required DateTime createdAt}) {
    return Group(
      id: id,
      ownerId: ownerId,
      name: name,
      members: [for (final member in members) member.toEntity()],
      createdAt: createdAt,
    );
  }
}

/// A member inside a group document.
@freezed
abstract class MemberDto with _$MemberDto {
  const MemberDto._();

  const factory MemberDto({required String id, required String name}) =
      _MemberDto;

  factory MemberDto.fromJson(Map<String, dynamic> json) =>
      _$MemberDtoFromJson(json);

  Member toEntity() => Member(id: id, name: name);
}

/// Converts Firestore's [Timestamp] to [DateTime] and back. `null` stays
/// `null` (a pending server timestamp reads as `null`).
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) => (json as Timestamp?)?.toDate();

  @override
  Object? toJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);
}
