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

/// Creates the app's dependency instances once and supplies them to Riverpod
/// through [overrides].
///
/// This is the only place data implementations are bound to domain
/// interfaces. It is immutable and passed explicitly — never stored in a
/// global.
class InjectionContainer {
  /// Builds everything above the repository from [authRepository]. Tests use
  /// this with a fake repository and a fake [errorReporter].
  InjectionContainer({
    required this.authRepository,
    required this.errorReporter,
  }) : signInUseCase = SignInUseCase(authRepository),
       registerUseCase = RegisterUseCase(authRepository);

  /// Production wiring: Crashlytics → error reporter; FirebaseAuth and
  /// GoogleSignIn → data sources → repository → use cases.
  ///
  /// Call only after `Firebase.initializeApp` has completed.
  factory InjectionContainer.create({
    FirebaseAuth? firebaseAuth,
    FirebaseCrashlytics? crashlytics,
    GoogleSignIn? googleSignIn,
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
    return InjectionContainer(
      authRepository: FirebaseAuthRepository(
        dataSource,
        googleDataSource,
        errorReporter,
      ),
      errorReporter: errorReporter,
    );
  }

  final AuthRepository authRepository;
  final ErrorReporter errorReporter;
  final SignInUseCase signInUseCase;
  final RegisterUseCase registerUseCase;

  /// Supplies the prepared instances to the providers that expose them.
  List<Override> get overrides => [
    authRepositoryProvider.overrideWithValue(authRepository),
    signInUseCaseProvider.overrideWithValue(signInUseCase),
    registerUseCaseProvider.overrideWithValue(registerUseCase),
    errorReporterProvider.overrideWithValue(errorReporter),
  ];
}
