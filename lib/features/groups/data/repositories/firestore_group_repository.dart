import 'dart:async';

import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/groups/data/datasources/firestore_group_data_source.dart';
import 'package:splitzy/features/groups/data/exceptions/group_exceptions.dart';
import 'package:splitzy/features/groups/data/models/group_dto.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/failures/group_failure.dart';
import 'package:splitzy/features/groups/domain/repositories/group_repository.dart';

/// [GroupRepository] backed by Cloud Firestore.
///
/// Maps group documents to [Group]s and the data source's project
/// exceptions ([AppException]) to [Failure]s, keeping the original stack
/// trace, so no Firestore type leaves the data layer.
class FirestoreGroupRepository implements GroupRepository {
  FirestoreGroupRepository(this._dataSource, {DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  final FirestoreGroupDataSource _dataSource;

  /// Stands in for a group's creation time while the server timestamp is
  /// still pending (the group was just created on this device).
  final DateTime Function() _clock;

  @override
  Stream<List<Group>> watchGroups(String ownerId) {
    return _dataSource
        .watchGroups(ownerId)
        .map(_toGroups)
        .transform(
          StreamTransformer<List<Group>, List<Group>>.fromHandlers(
            handleError: (error, stackTrace, sink) => sink.addError(
              error is AppException ? _toFailure(error) : error,
              stackTrace,
            ),
          ),
        );
  }

  @override
  Future<void> createGroup({
    required String ownerId,
    required String ownerName,
    required String name,
    required List<String> memberNames,
  }) {
    return _guard(() {
      return _dataSource.createGroup(
        GroupDto(
          ownerId: ownerId,
          name: name,
          members: [
            // The owner's member id is their user id, so "you" can be found.
            MemberDto(id: ownerId, name: ownerName),
            for (final memberName in memberNames)
              MemberDto(id: _dataSource.newId(), name: memberName),
          ],
        ),
      );
    });
  }

  /// Newest first; groups created at the same time are ordered by id so the
  /// order is stable.
  List<Group> _toGroups(List<GroupDocument> documents) {
    final now = _clock();
    final groups = [
      for (final (:id, :data) in documents)
        data.toEntity(id: id, createdAt: data.createdAt ?? now),
    ];
    return groups..sort((a, b) {
      final byTime = b.createdAt.compareTo(a.createdAt);
      return byTime != 0 ? byTime : a.id.compareTo(b.id);
    });
  }

  /// Runs [action], rethrowing a project exception as the matching [Failure]
  /// with the original stack trace. Other errors pass through unchanged.
  static Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on AppException catch (error, stackTrace) {
      Error.throwWithStackTrace(_toFailure(error), stackTrace);
    }
  }

  static Failure _toFailure(AppException exception) {
    return switch (exception) {
      NetworkException() => const NetworkFailure(),
      UnknownGroupException(:final code) => UnknownGroupFailure(code),
      // A project exception this repository does not know about.
      _ => const UnexpectedFailure(),
    };
  }
}
