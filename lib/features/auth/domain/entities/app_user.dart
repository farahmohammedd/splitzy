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

extension AppUserName on AppUser {
  /// The name to show the user: their display name, or the part of their
  /// email before `@` when no name was saved.
  String get nameToShow {
    final name = displayName?.trim();
    if (name != null && name.isNotEmpty) return name;
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }
}
