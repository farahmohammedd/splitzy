import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_user.freezed.dart';

/// A signed-in Splitzy user, in domain terms (no Firebase types).
@freezed
abstract class AppUser with _$AppUser {
  const factory AppUser({
    required String id,
    required String email,

    /// The user's full name; `null` when it was never saved (e.g. the name
    /// update failed after registration).
    String? displayName,
  }) = _AppUser;
}
