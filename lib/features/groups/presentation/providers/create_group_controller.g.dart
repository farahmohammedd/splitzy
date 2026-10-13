// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_group_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs a create-group attempt and exposes its progress: data (idle or
/// done), loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: the page closes the screen when an attempt succeeds.

@ProviderFor(CreateGroupController)
final createGroupControllerProvider = CreateGroupControllerProvider._();

/// Runs a create-group attempt and exposes its progress: data (idle or
/// done), loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: the page closes the screen when an attempt succeeds.
final class CreateGroupControllerProvider
    extends $AsyncNotifierProvider<CreateGroupController, void> {
  /// Runs a create-group attempt and exposes its progress: data (idle or
  /// done), loading, or an error holding a [Failure] (see [runGuarded]).
  ///
  /// It never navigates: the page closes the screen when an attempt succeeds.
  CreateGroupControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createGroupControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createGroupControllerHash();

  @$internal
  @override
  CreateGroupController create() => CreateGroupController();
}

String _$createGroupControllerHash() =>
    r'70ba5d26f91706bc446f2c5ec44a9fc5580f19c5';

/// Runs a create-group attempt and exposes its progress: data (idle or
/// done), loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: the page closes the screen when an attempt succeeds.

abstract class _$CreateGroupController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
