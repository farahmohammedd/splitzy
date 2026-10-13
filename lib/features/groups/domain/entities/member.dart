import 'package:freezed_annotation/freezed_annotation.dart';

part 'member.freezed.dart';

/// A person in a group. Members are names only for now; the group owner's
/// member [id] is their user id (see the Firestore data model).
@freezed
abstract class Member with _$Member {
  const factory Member({required String id, required String name}) = _Member;
}
