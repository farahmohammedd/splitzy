// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(groupRepository)
final groupRepositoryProvider = GroupRepositoryProvider._();

final class GroupRepositoryProvider
    extends
        $FunctionalProvider<GroupRepository, GroupRepository, GroupRepository>
    with $Provider<GroupRepository> {
  GroupRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'groupRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$groupRepositoryHash();

  @$internal
  @override
  $ProviderElement<GroupRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GroupRepository create(Ref ref) {
    return groupRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GroupRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GroupRepository>(value),
    );
  }
}

String _$groupRepositoryHash() => r'3278da034046070fb518c85d90825a2f43d2b313';

@ProviderFor(createGroupUseCase)
final createGroupUseCaseProvider = CreateGroupUseCaseProvider._();

final class CreateGroupUseCaseProvider
    extends
        $FunctionalProvider<
          CreateGroupUseCase,
          CreateGroupUseCase,
          CreateGroupUseCase
        >
    with $Provider<CreateGroupUseCase> {
  CreateGroupUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createGroupUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createGroupUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateGroupUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateGroupUseCase create(Ref ref) {
    return createGroupUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateGroupUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateGroupUseCase>(value),
    );
  }
}

String _$createGroupUseCaseHash() =>
    r'a09e5f137f02112440e6d2e9591fb6c02a121f23';

/// The groups owned by [ownerId], newest first, updated on every change.
///
/// Watching groups has no business rules, so it reads the repository
/// directly. The owner id comes from the caller, so this feature does not
/// depend on the auth feature.

@ProviderFor(groups)
final groupsProvider = GroupsFamily._();

/// The groups owned by [ownerId], newest first, updated on every change.
///
/// Watching groups has no business rules, so it reads the repository
/// directly. The owner id comes from the caller, so this feature does not
/// depend on the auth feature.

final class GroupsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Group>>,
          List<Group>,
          Stream<List<Group>>
        >
    with $FutureModifier<List<Group>>, $StreamProvider<List<Group>> {
  /// The groups owned by [ownerId], newest first, updated on every change.
  ///
  /// Watching groups has no business rules, so it reads the repository
  /// directly. The owner id comes from the caller, so this feature does not
  /// depend on the auth feature.
  GroupsProvider._({
    required GroupsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupsHash();

  @override
  String toString() {
    return r'groupsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Group>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Group>> create(Ref ref) {
    final argument = this.argument as String;
    return groups(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupsHash() => r'ccc7b7907c3350a6b9a7b77f3e272c4f3aa12a1e';

/// The groups owned by [ownerId], newest first, updated on every change.
///
/// Watching groups has no business rules, so it reads the repository
/// directly. The owner id comes from the caller, so this feature does not
/// depend on the auth feature.

final class GroupsFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Group>>, String> {
  GroupsFamily._()
    : super(
        retry: null,
        name: r'groupsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The groups owned by [ownerId], newest first, updated on every change.
  ///
  /// Watching groups has no business rules, so it reads the repository
  /// directly. The owner id comes from the caller, so this feature does not
  /// depend on the auth feature.

  GroupsProvider call(String ownerId) =>
      GroupsProvider._(argument: ownerId, from: this);

  @override
  String toString() => r'groupsProvider';
}
