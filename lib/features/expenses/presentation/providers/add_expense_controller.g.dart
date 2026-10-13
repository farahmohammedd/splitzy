// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'add_expense_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Runs an add-expense attempt and exposes its progress: data (idle or
/// done), loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: the page closes the screen when an attempt succeeds.

@ProviderFor(AddExpenseController)
final addExpenseControllerProvider = AddExpenseControllerProvider._();

/// Runs an add-expense attempt and exposes its progress: data (idle or
/// done), loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: the page closes the screen when an attempt succeeds.
final class AddExpenseControllerProvider
    extends $AsyncNotifierProvider<AddExpenseController, void> {
  /// Runs an add-expense attempt and exposes its progress: data (idle or
  /// done), loading, or an error holding a [Failure] (see [runGuarded]).
  ///
  /// It never navigates: the page closes the screen when an attempt succeeds.
  AddExpenseControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addExpenseControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addExpenseControllerHash();

  @$internal
  @override
  AddExpenseController create() => AddExpenseController();
}

String _$addExpenseControllerHash() =>
    r'4d6feeffb22c8a33d7ed8a4df610e3b13061baf1';

/// Runs an add-expense attempt and exposes its progress: data (idle or
/// done), loading, or an error holding a [Failure] (see [runGuarded]).
///
/// It never navigates: the page closes the screen when an attempt succeeds.

abstract class _$AddExpenseController extends $AsyncNotifier<void> {
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
