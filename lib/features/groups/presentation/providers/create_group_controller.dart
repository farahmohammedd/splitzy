import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/core/error/error_reporter_provider.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/core/error/run_guarded.dart';
import 'package:splitzy/features/groups/presentation/providers/group_providers.dart';

part 'create_group_controller.g.dart';

/// Runs a create-group attempt and exposes its progress: data (idle or
/// done), loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: the page closes the screen when an attempt succeeds.
@riverpod
class CreateGroupController extends _$CreateGroupController {
  @override
  FutureOr<void> build() {}

  Future<void> create({
    required String ownerId,
    required String ownerName,
    required String name,
    required List<String> memberNames,
  }) async {
    if (state.isLoading) return;
    state = const AsyncLoading();
    final result = await runGuarded(
      () => ref.read(createGroupUseCaseProvider)(
        ownerId: ownerId,
        ownerName: ownerName,
        name: name,
        memberNames: memberNames,
      ),
      reporter: ref.read(errorReporterProvider),
      reason: 'Creating a group',
    );
    if (ref.mounted) state = result;
  }
}
