import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/groups/data/exceptions/group_exceptions.dart';

/// Translates a Firestore error from the groups data source into a project
/// exception, by error code.
///
/// `unavailable` is Firestore's "the backend could not be reached" (e.g. no
/// connection); every other code keeps its code for debugging.
AppException mapFirestoreGroupException(FirebaseException exception) {
  return switch (exception.code) {
    'unavailable' => const NetworkException(),
    final code => UnknownGroupException(code),
  };
}
