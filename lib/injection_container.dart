import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:splitzy/core/error/crashlytics_error_reporter.dart';
import 'package:splitzy/core/error/error_reporter.dart';
import 'package:splitzy/core/error/error_reporter_provider.dart';
import 'package:splitzy/features/auth/data/datasources/firebase_auth_data_source.dart';
import 'package:splitzy/features/auth/data/datasources/google_sign_in_data_source.dart';
import 'package:splitzy/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:splitzy/features/auth/domain/repositories/auth_repository.dart';
import 'package:splitzy/features/auth/domain/usecases/register_use_case.dart';
import 'package:splitzy/features/auth/domain/usecases/sign_in_use_case.dart';
import 'package:splitzy/features/auth/presentation/providers/auth_providers.dart';
import 'package:splitzy/features/expenses/data/datasources/firestore_expense_data_source.dart';
import 'package:splitzy/features/expenses/data/repositories/firestore_expense_repository.dart';
import 'package:splitzy/features/expenses/domain/repositories/expense_repository.dart';
import 'package:splitzy/features/expenses/domain/usecases/add_expense_use_case.dart';
import 'package:splitzy/features/expenses/presentation/providers/expense_providers.dart';
import 'package:splitzy/features/groups/data/datasources/firestore_group_data_source.dart';
import 'package:splitzy/features/groups/data/repositories/firestore_group_repository.dart';
import 'package:splitzy/features/groups/domain/repositories/group_repository.dart';
import 'package:splitzy/features/groups/domain/usecases/create_group_use_case.dart';
import 'package:splitzy/features/groups/presentation/providers/group_providers.dart';

/// Creates the app's dependency instances once and supplies them to Riverpod
/// through [overrides].
///
/// This is the only place data implementations are bound to domain
/// interfaces. It is immutable and passed explicitly — never stored in a
/// global.
class InjectionContainer {
  /// Builds everything above the repositories. Tests use this with fake
  /// repositories and a fake [errorReporter].
  InjectionContainer({
    required this.authRepository,
    required this.groupRepository,
    required this.expenseRepository,
    required this.errorReporter,
  }) : signInUseCase = SignInUseCase(authRepository),
       registerUseCase = RegisterUseCase(authRepository),
       createGroupUseCase = CreateGroupUseCase(groupRepository),
       addExpenseUseCase = AddExpenseUseCase(expenseRepository);

  /// Production wiring: Crashlytics → error reporter; FirebaseAuth and
  /// GoogleSignIn → auth data sources → auth repository; Firestore → group
  /// and expense data sources → their repositories; repositories → use
  /// cases.
  ///
  /// Call only after `Firebase.initializeApp` has completed.
  factory InjectionContainer.create({
    FirebaseAuth? firebaseAuth,
    FirebaseCrashlytics? crashlytics,
    GoogleSignIn? googleSignIn,
    FirebaseFirestore? firestore,
  }) {
    final errorReporter = CrashlyticsErrorReporter(
      crashlytics ?? FirebaseCrashlytics.instance,
    );
    final dataSource = FirebaseAuthDataSource(
      firebaseAuth ?? FirebaseAuth.instance,
    );
    final googleDataSource = GoogleSignInDataSource(
      googleSignIn ?? GoogleSignIn.instance,
    );
    final db = firestore ?? FirebaseFirestore.instance;
    return InjectionContainer(
      authRepository: FirebaseAuthRepository(
        dataSource,
        googleDataSource,
        errorReporter,
      ),
      groupRepository: FirestoreGroupRepository(FirestoreGroupDataSource(db)),
      expenseRepository: FirestoreExpenseRepository(
        FirestoreExpenseDataSource(db),
      ),
      errorReporter: errorReporter,
    );
  }

  final AuthRepository authRepository;
  final GroupRepository groupRepository;
  final ExpenseRepository expenseRepository;
  final ErrorReporter errorReporter;
  final SignInUseCase signInUseCase;
  final RegisterUseCase registerUseCase;
  final CreateGroupUseCase createGroupUseCase;
  final AddExpenseUseCase addExpenseUseCase;

  /// Supplies the prepared instances to the providers that expose them.
  List<Override> get overrides => [
    authRepositoryProvider.overrideWithValue(authRepository),
    signInUseCaseProvider.overrideWithValue(signInUseCase),
    registerUseCaseProvider.overrideWithValue(registerUseCase),
    groupRepositoryProvider.overrideWithValue(groupRepository),
    createGroupUseCaseProvider.overrideWithValue(createGroupUseCase),
    expenseRepositoryProvider.overrideWithValue(expenseRepository),
    addExpenseUseCaseProvider.overrideWithValue(addExpenseUseCase),
    errorReporterProvider.overrideWithValue(errorReporter),
  ];
}
