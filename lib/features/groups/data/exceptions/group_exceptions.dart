import 'package:splitzy/core/error/exceptions.dart';

/// Group storage errors reported by the group data source, independent of
/// the SDK that produced them. Shared errors such as `NetworkException` come
/// from `core/error/exceptions.dart`.
sealed class GroupException extends AppException {
  const GroupException();
}

/// Any group storage error without a more specific type (e.g. a request the
/// security rules rejected); [code] keeps the original error code for
/// debugging.
final class UnknownGroupException extends GroupException {
  const UnknownGroupException(this.code);

  final String code;

  @override
  String toString() => 'UnknownGroupException($code)';
}
