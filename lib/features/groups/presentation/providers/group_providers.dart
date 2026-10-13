import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/repositories/group_repository.dart';
import 'package:splitzy/features/groups/domain/usecases/create_group_use_case.dart';

part 'group_providers.g.dart';

// The instances below are created by `InjectionContainer`
// (lib/injection_container.dart) and supplied through its `ProviderScope`
// overrides. Without those overrides, reading them fails fast. They are kept
// alive because each override is a single app-lifetime instance.

@Riverpod(keepAlive: true)
GroupRepository groupRepository(Ref ref) => throw UnimplementedError(
  'groupRepositoryProvider is supplied by InjectionContainer.overrides',
);

@Riverpod(keepAlive: true)
CreateGroupUseCase createGroupUseCase(Ref ref) => throw UnimplementedError(
  'createGroupUseCaseProvider is supplied by InjectionContainer.overrides',
);

/// The groups owned by [ownerId], newest first, updated on every change.
///
/// Watching groups has no business rules, so it reads the repository
/// directly. The owner id comes from the caller, so this feature does not
/// depend on the auth feature.
@riverpod
Stream<List<Group>> groups(Ref ref, String ownerId) {
  return ref.watch(groupRepositoryProvider).watchGroups(ownerId);
}
