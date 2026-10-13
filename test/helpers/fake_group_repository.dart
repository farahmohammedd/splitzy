import 'dart:async';

import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';
import 'package:splitzy/features/groups/domain/repositories/group_repository.dart';

/// In-memory [GroupRepository] for app, router and controller tests.
///
/// - [groups] holds every stored group, newest first; [watchGroups] emits
///   the owner's groups now and after every change.
/// - [failNextWith] makes the next [createGroup] throw the given (expected)
///   failure; [throwNextWith] makes it throw an unexpected error.
/// - [gate], when set, holds [createGroup] until it completes, so tests can
///   observe the loading state.
/// - Every [createGroup] call's arguments are recorded in [createCalls].
class FakeGroupRepository implements GroupRepository {
  FakeGroupRepository({List<Group> groups = const []}) : _groups = [...groups];

  final _changes = StreamController<void>.broadcast();
  final List<Group> _groups;
  Object? _nextError;
  StackTrace? _nextStackTrace;
  int _nextId = 0;

  /// Holds [createGroup] until completed; `null` lets it finish at once.
  Completer<void>? gate;

  final createCalls =
      <
        ({
          String ownerId,
          String ownerName,
          String name,
          List<String> memberNames,
        })
      >[];

  List<Group> get groups => List.unmodifiable(_groups);

  void failNextWith(Failure failure) {
    _nextError = failure;
    _nextStackTrace = null;
  }

  void throwNextWith(Object error, StackTrace stackTrace) {
    _nextError = error;
    _nextStackTrace = stackTrace;
  }

  @override
  Stream<List<Group>> watchGroups(String ownerId) {
    List<Group> owned() => [
      for (final group in _groups)
        if (group.ownerId == ownerId) group,
    ];

    StreamSubscription<void>? subscription;
    late final StreamController<List<Group>> controller;
    controller = StreamController<List<Group>>(
      onListen: () {
        controller.add(owned());
        subscription = _changes.stream.listen((_) => controller.add(owned()));
      },
      onCancel: () => subscription?.cancel(),
    );
    return controller.stream;
  }

  @override
  Future<void> createGroup({
    required String ownerId,
    required String ownerName,
    required String name,
    required List<String> memberNames,
  }) async {
    createCalls.add((
      ownerId: ownerId,
      ownerName: ownerName,
      name: name,
      memberNames: memberNames,
    ));
    final pending = gate;
    if (pending != null) await pending.future;
    final error = _nextError;
    if (error != null) {
      final stackTrace = _nextStackTrace;
      _nextError = null;
      _nextStackTrace = null;
      if (stackTrace == null) throw error;
      Error.throwWithStackTrace(error, stackTrace);
    }
    _groups.insert(
      0,
      Group(
        id: 'group-${++_nextId}',
        ownerId: ownerId,
        name: name,
        members: [
          Member(id: ownerId, name: ownerName),
          for (final (i, memberName) in memberNames.indexed)
            Member(id: 'member-$_nextId-$i', name: memberName),
        ],
        createdAt: DateTime.utc(2026, 1, 1).add(Duration(minutes: _nextId)),
      ),
    );
    _changes.add(null);
  }

  Future<void> dispose() => _changes.close();
}
