// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'expense_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(expenseRepository)
final expenseRepositoryProvider = ExpenseRepositoryProvider._();

final class ExpenseRepositoryProvider
    extends
        $FunctionalProvider<
          ExpenseRepository,
          ExpenseRepository,
          ExpenseRepository
        >
    with $Provider<ExpenseRepository> {
  ExpenseRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'expenseRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$expenseRepositoryHash();

  @$internal
  @override
  $ProviderElement<ExpenseRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ExpenseRepository create(Ref ref) {
    return expenseRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExpenseRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExpenseRepository>(value),
    );
  }
}

String _$expenseRepositoryHash() => r'50a2c7f2be15e7c91a3ac405e78a03c03ed8cdba';

@ProviderFor(addExpenseUseCase)
final addExpenseUseCaseProvider = AddExpenseUseCaseProvider._();

final class AddExpenseUseCaseProvider
    extends
        $FunctionalProvider<
          AddExpenseUseCase,
          AddExpenseUseCase,
          AddExpenseUseCase
        >
    with $Provider<AddExpenseUseCase> {
  AddExpenseUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'addExpenseUseCaseProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$addExpenseUseCaseHash();

  @$internal
  @override
  $ProviderElement<AddExpenseUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AddExpenseUseCase create(Ref ref) {
    return addExpenseUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AddExpenseUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AddExpenseUseCase>(value),
    );
  }
}

String _$addExpenseUseCaseHash() => r'226de571ad60f54d12715692544de131b8c2aaa2';

/// The expenses of the group [groupId], newest first, updated on every
/// change.
///
/// Watching expenses has no business rules, so it reads the repository
/// directly.

@ProviderFor(groupExpenses)
final groupExpensesProvider = GroupExpensesFamily._();

/// The expenses of the group [groupId], newest first, updated on every
/// change.
///
/// Watching expenses has no business rules, so it reads the repository
/// directly.

final class GroupExpensesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Expense>>,
          List<Expense>,
          Stream<List<Expense>>
        >
    with $FutureModifier<List<Expense>>, $StreamProvider<List<Expense>> {
  /// The expenses of the group [groupId], newest first, updated on every
  /// change.
  ///
  /// Watching expenses has no business rules, so it reads the repository
  /// directly.
  GroupExpensesProvider._({
    required GroupExpensesFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'groupExpensesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$groupExpensesHash();

  @override
  String toString() {
    return r'groupExpensesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Expense>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Expense>> create(Ref ref) {
    final argument = this.argument as String;
    return groupExpenses(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GroupExpensesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$groupExpensesHash() => r'dcb751f9b8ce12ac2de755fa791bdc2234162027';

/// The expenses of the group [groupId], newest first, updated on every
/// change.
///
/// Watching expenses has no business rules, so it reads the repository
/// directly.

final class GroupExpensesFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Expense>>, String> {
  GroupExpensesFamily._()
    : super(
        retry: null,
        name: r'groupExpensesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// The expenses of the group [groupId], newest first, updated on every
  /// change.
  ///
  /// Watching expenses has no business rules, so it reads the repository
  /// directly.

  GroupExpensesProvider call(String groupId) =>
      GroupExpensesProvider._(argument: groupId, from: this);

  @override
  String toString() => r'groupExpensesProvider';
}
