import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/groups/data/mappers/firestore_exception_mapper.dart';
import 'package:splitzy/features/groups/data/models/group_dto.dart';

/// A group document read from Firestore: its id and its data.
typedef GroupDocument = ({String id, GroupDto data});

/// Thin wrapper over the `groups` collection: one method per Firestore call,
/// no business rules. Firestore errors are translated into project
/// exceptions ([AppException]) with their original stack trace; any other
/// error passes through unchanged.
class FirestoreGroupDataSource {
  const FirestoreGroupDataSource(this._firestore);

  static const String _collection = 'groups';

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _groups =>
      _firestore.collection(_collection);

  /// The groups owned by [ownerId], unordered, then again on every change.
  ///
  /// Filtering on `ownerId` is required: the security rules reject any
  /// query that could return another user's group.
  Stream<List<GroupDocument>> watchGroups(String ownerId) {
    return _groups
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map(
          (snapshot) => [
            for (final doc in snapshot.docs)
              (id: doc.id, data: GroupDto.fromJson(doc.data())),
          ],
        )
        .transform(
          StreamTransformer<
            List<GroupDocument>,
            List<GroupDocument>
          >.fromHandlers(
            handleError: (error, stackTrace, sink) =>
                sink.addError(_translate(error), stackTrace),
          ),
        );
  }

  /// Adds [group] as a new document, stamped with the server's time
  /// (its own `createdAt` is ignored).
  Future<void> createGroup(GroupDto group) {
    return _guard(() async {
      await _groups.add({
        ...group.toJson(),
        // Firestore needs plain maps, not MemberDto objects.
        'members': [for (final member in group.members) member.toJson()],
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  /// A new random id, generated locally without contacting Firestore. Used
  /// for member ids.
  String newId() => _groups.doc().id;

  static Future<T> _guard<T>(Future<T> Function() call) async {
    try {
      return await call();
    } on FirebaseException catch (error, stackTrace) {
      Error.throwWithStackTrace(mapFirestoreGroupException(error), stackTrace);
    }
  }

  static Object _translate(Object error) =>
      error is FirebaseException ? mapFirestoreGroupException(error) : error;
}
