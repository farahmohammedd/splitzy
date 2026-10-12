import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:splitzy/app.dart';
import 'package:splitzy/core/error/failures.dart';
import 'package:splitzy/core/router/app_router.dart';
import 'package:splitzy/core/router/app_routes.dart';
import 'package:splitzy/core/router/home_shell.dart';
import 'package:splitzy/features/auth/domain/entities/app_user.dart';
import 'package:splitzy/features/auth/domain/failures/auth_failure.dart';
import 'package:splitzy/features/auth/presentation/screens/login_screen.dart';
import 'package:splitzy/features/auth/presentation/widgets/auth_error_text.dart';
import 'package:splitzy/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:splitzy/features/home/presentation/screens/home_screen.dart';
import 'package:splitzy/features/splash/presentation/screens/launch_screen.dart';
import 'package:splitzy/features/splash/presentation/screens/splash_screen.dart';
import 'package:splitzy/injection_container.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_error_reporter.dart';

/// Pumps the app with [repository] (signed out by default) as its auth
/// backend and returns it.
Future<FakeAuthRepository> _pumpApp(
  WidgetTester tester, {
  FakeAuthRepository? repository,
}) async {
  // Screens scroll on small surfaces; a phone size keeps taps on-screen.
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = repository ?? FakeAuthRepository();
  addTearDown(auth.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: InjectionContainer(
        authRepository: auth,
        errorReporter: FakeErrorReporter(),
      ).overrides,
      child: const SplitzyApp(),
    ),
  );
  return auth;
}

GoRouter _router(WidgetTester tester) {
  final container = ProviderScope.containerOf(
    tester.element(find.byType(SplitzyApp)),
  );
  return container.read(appRouterProvider);
}

String _location(WidgetTester tester) => _router(tester).state.matchedLocation;

/// Waits for the launch screen's minimum duration, ending on Splash.
Future<void> _finishLoading(WidgetTester tester) async {
  await tester.pump(LaunchScreen.defaultMinimumDuration);
  await tester.pumpAndSettle();
}

/// Taps the screen's own Back button, scrolling it into view first (scrolling
/// a form, e.g. to reach "Sign Up", can move it off-screen).
Future<void> _tapBack(WidgetTester tester) async {
  final back = find.byTooltip('Back');
  await tester.ensureVisible(back);
  await tester.tap(back);
  await tester.pumpAndSettle();
}

Future<void> _tapText(WidgetTester tester, String text) async {
  await tester.ensureVisible(find.text(text));
  await tester.tap(find.text(text));
  await tester.pumpAndSettle();
}

Finder _field(String hint) => find.widgetWithText(TextField, hint);

/// Opens the Profile tab, where Log out lives.
Future<void> _openProfile(WidgetTester tester) async {
  await tester.tap(
    find.descendant(of: find.byType(HomeShell), matching: find.text('Profile')),
  );
  await tester.pumpAndSettle();
}

final _logOut = find.text('Log out');

/// Fills in and submits the Login form.
Future<void> _logIn(
  WidgetTester tester, {
  required String email,
  required String password,
}) async {
  await tester.enterText(_field('Email address'), email);
  await tester.enterText(_field('Password'), password);
  await _tapText(tester, 'Log In');
}

/// Fills in and submits the Sign Up form with valid details.
Future<void> _signUp(WidgetTester tester) async {
  await tester.enterText(_field('Full name'), ' Sam Lee ');
  await tester.enterText(_field('Email address'), 'sam@example.com');
  await tester.enterText(_field('Password'), 'secret12');
  await tester.enterText(_field('Confirm password'), 'secret12');
  await _tapText(tester, 'Create Account');
}

void main() {
  group('appRouter', () {
    testWidgets('starts on the launch screen', (tester) async {
      await _pumpApp(tester);

      expect(_location(tester), AppRoutes.launch);
      expect(find.byType(LaunchScreen), findsOneWidget);
    });

    testWidgets('replaces Launch with Splash after loading', (tester) async {
      await _pumpApp(tester);
      await _finishLoading(tester);

      expect(_location(tester), AppRoutes.splash);
      expect(find.byType(SplashScreen), findsOneWidget);
      expect(find.byType(LaunchScreen), findsNothing);
      // Launch was replaced, so there is nothing to go back to.
      expect(_router(tester).canPop(), isFalse);
    });

    testWidgets('Get Started opens Login; Back returns to Splash', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _finishLoading(tester);

      await _tapText(tester, 'Get Started');
      expect(_location(tester), AppRoutes.login);
      expect(find.byType(LoginScreen), findsOneWidget);

      await _tapBack(tester);
      expect(_location(tester), AppRoutes.splash);
      expect(find.byType(SplashScreen), findsOneWidget);
    });

    testWidgets('Sign Up opens Sign Up; Back returns to Login', (tester) async {
      await _pumpApp(tester);
      await _finishLoading(tester);
      await _tapText(tester, 'Get Started');

      await _tapText(tester, 'Sign Up');
      expect(_location(tester), AppRoutes.signUp);
      expect(find.byType(SignUpScreen), findsOneWidget);

      await _tapBack(tester);
      expect(_location(tester), AppRoutes.login);
      expect(find.byType(SignUpScreen), findsNothing);
    });

    testWidgets('Sign In returns to the existing Login instead of stacking', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _finishLoading(tester);
      await _tapText(tester, 'Get Started');
      await _tapText(tester, 'Sign Up');

      await _tapText(tester, 'Sign In');
      expect(_location(tester), AppRoutes.login);
      expect(find.byType(SignUpScreen), findsNothing);

      // Back from Login still reaches Splash: Login was not pushed again.
      await _tapBack(tester);
      expect(_location(tester), AppRoutes.splash);
    });

    testWidgets('Sign In goes to Login when Sign Up has nothing beneath it', (
      tester,
    ) async {
      await _pumpApp(tester);
      await _finishLoading(tester);
      // E.g. a deep link straight to Sign Up.
      _router(tester).go(AppRoutes.signUp);
      await tester.pumpAndSettle();
      expect(_router(tester).canPop(), isFalse);

      await _tapText(tester, 'Sign In');
      expect(_location(tester), AppRoutes.login);
      expect(find.byType(LoginScreen), findsOneWidget);
    });

    testWidgets('Forgot Password does not navigate yet', (tester) async {
      await _pumpApp(tester);
      await _finishLoading(tester);
      await _tapText(tester, 'Get Started');

      await _tapText(tester, 'Forgot Password?');

      expect(_location(tester), AppRoutes.login);
    });

    group('Google sign-in', () {
      testWidgets('from Login reaches Home', (tester) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');

        await _tapText(tester, 'Continue with Google');

        expect(auth.googleSignInCalls, 1);
        expect(_location(tester), AppRoutes.home);
        expect(_router(tester).canPop(), isFalse);
      });

      testWidgets('from Sign Up reaches Home', (tester) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');
        await _tapText(tester, 'Sign Up');

        await _tapText(tester, 'Continue with Google');

        expect(auth.googleSignInCalls, 1);
        expect(_location(tester), AppRoutes.home);
      });

      testWidgets('a cancelled picker stays on Login with no message', (
        tester,
      ) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');
        auth.cancelNextGoogleSignIn();

        await _tapText(tester, 'Continue with Google');

        expect(_location(tester), AppRoutes.login);
        expect(find.byType(AuthErrorText), findsNothing);
        // The button is usable again.
        await _tapText(tester, 'Continue with Google');
        expect(_location(tester), AppRoutes.home);
      });

      testWidgets('an expected failure shows its message on Sign Up', (
        tester,
      ) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');
        await _tapText(tester, 'Sign Up');
        auth.failNextWith(const AccountExistsWithDifferentCredential());

        await _tapText(tester, 'Continue with Google');

        expect(_location(tester), AppRoutes.signUp);
        expect(
          find.text(
            'An account with this email already exists. '
            'Log in with the method you used before.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('an unexpected error shows the generic message', (
        tester,
      ) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');
        auth.throwNextWith(StateError('secret detail'), StackTrace.empty);

        await _tapText(tester, 'Continue with Google');

        expect(_location(tester), AppRoutes.login);
        expect(
          find.text('Something went wrong. Please try again.'),
          findsOneWidget,
        );
        expect(find.textContaining('secret detail'), findsNothing);
      });

      testWidgets('a failure on Login is not shown on Sign Up', (tester) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');
        auth.failNextWith(const NetworkFailure());
        await _tapText(tester, 'Continue with Google');
        expect(find.text(const NetworkFailure().message), findsOneWidget);

        await _tapText(tester, 'Sign Up');

        expect(_location(tester), AppRoutes.signUp);
        expect(find.byType(AuthErrorText), findsNothing);
      });

      testWidgets('a later log-in failure replaces an earlier Google failure', (
        tester,
      ) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');
        auth.failNextWith(const NetworkFailure());
        await _tapText(tester, 'Continue with Google');

        auth.failNextWith(const InvalidCredentials());
        await _logIn(tester, email: 'sam@example.com', password: 'wrong');

        expect(find.text('Incorrect email or password.'), findsOneWidget);
        expect(find.text(const NetworkFailure().message), findsNothing);
      });

      testWidgets('then Log out returns to Splash', (tester) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');
        await _tapText(tester, 'Continue with Google');
        expect(_location(tester), AppRoutes.home);

        await _openProfile(tester);
        await tester.tap(_logOut);
        await tester.pumpAndSettle();

        expect(auth.signOutCalls, 1);
        expect(_location(tester), AppRoutes.splash);
      });
    });

    group('authentication', () {
      testWidgets('a signed-in user goes from Launch to Home', (tester) async {
        await _pumpApp(
          tester,
          repository: FakeAuthRepository(
            signedInUser: FakeAuthRepository.defaultUser,
          ),
        );
        expect(find.byType(LaunchScreen), findsOneWidget);

        await _finishLoading(tester);

        expect(_location(tester), AppRoutes.home);
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(find.byType(SplashScreen), findsNothing);
        expect(_router(tester).canPop(), isFalse);
      });

      testWidgets('signing in while on Login moves to Home', (tester) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');

        auth.emit(FakeAuthRepository.defaultUser);
        await tester.pumpAndSettle();

        expect(_location(tester), AppRoutes.home);
        // Home replaced the signed-out stack: Back cannot return to Login.
        expect(_router(tester).canPop(), isFalse);
      });

      testWidgets('signing out on Home returns to Splash', (tester) async {
        final auth = await _pumpApp(
          tester,
          repository: FakeAuthRepository(
            signedInUser: FakeAuthRepository.defaultUser,
          ),
        );
        await _finishLoading(tester);
        expect(_location(tester), AppRoutes.home);

        auth.emit(null);
        await tester.pumpAndSettle();

        expect(_location(tester), AppRoutes.splash);
        expect(find.byType(SplashScreen), findsOneWidget);
      });

      testWidgets('logging in with valid credentials reaches Home', (
        tester,
      ) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');

        await _logIn(tester, email: ' sam@example.com ', password: 'secret');

        expect(auth.signInCalls.single, (
          email: 'sam@example.com',
          password: 'secret',
        ));
        expect(_location(tester), AppRoutes.home);
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('a failed log-in shows a message and stays on Login', (
        tester,
      ) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');
        auth.failNextWith(const InvalidCredentials());

        await _logIn(tester, email: 'sam@example.com', password: 'wrong');

        expect(_location(tester), AppRoutes.login);
        expect(find.text('Incorrect email or password.'), findsOneWidget);
      });

      testWidgets('an unexpected log-in error shows the generic message', (
        tester,
      ) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');
        auth.throwNextWith(StateError('secret detail'), StackTrace.empty);

        await _logIn(tester, email: 'sam@example.com', password: 'secret');

        expect(_location(tester), AppRoutes.login);
        expect(
          find.text('Something went wrong. Please try again.'),
          findsOneWidget,
        );
        expect(find.textContaining('secret detail'), findsNothing);
      });

      testWidgets('Log In shows loading until the attempt finishes', (
        tester,
      ) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');
        final gate = auth.gate = Completer<void>();

        await tester.enterText(_field('Email address'), 'sam@example.com');
        await tester.enterText(_field('Password'), 'secret');
        await tester.tap(find.text('Log In'));
        await tester.pump();
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        gate.complete();
        await tester.pumpAndSettle();
        expect(_location(tester), AppRoutes.home);
      });

      testWidgets('Log out on Profile returns to Splash', (tester) async {
        final auth = await _pumpApp(
          tester,
          repository: FakeAuthRepository(
            signedInUser: FakeAuthRepository.defaultUser,
          ),
        );
        await _finishLoading(tester);
        await _openProfile(tester);

        await tester.tap(_logOut);
        await tester.pumpAndSettle();

        expect(auth.signOutCalls, 1);
        expect(_location(tester), AppRoutes.splash);
        expect(find.byType(SplashScreen), findsOneWidget);
      });

      testWidgets(
        "a failed log-out shows the failure's message and stays on Profile",
        (tester) async {
          final auth = await _pumpApp(
            tester,
            repository: FakeAuthRepository(
              signedInUser: FakeAuthRepository.defaultUser,
            ),
          );
          await _finishLoading(tester);
          await _openProfile(tester);
          auth.failNextWith(const NetworkFailure());

          await tester.tap(_logOut);
          await tester.pump();

          expect(
            find.widgetWithText(
              SnackBar,
              'No internet connection. Check your network and try again.',
            ),
            findsOneWidget,
          );
          expect(_location(tester), AppRoutes.profile);
        },
      );

      testWidgets('an unknown log-out failure shows the generic message', (
        tester,
      ) async {
        final auth = await _pumpApp(
          tester,
          repository: FakeAuthRepository(
            signedInUser: FakeAuthRepository.defaultUser,
          ),
        );
        await _finishLoading(tester);
        await _openProfile(tester);
        auth.failNextWith(const UnknownAuthFailure('internal-error'));

        await tester.tap(_logOut);
        await tester.pump();

        expect(
          find.widgetWithText(
            SnackBar,
            'Something went wrong. Please try again.',
          ),
          findsOneWidget,
        );
        // The technical code is never shown.
        expect(find.textContaining('internal-error'), findsNothing);
        expect(_location(tester), AppRoutes.profile);
      });

      testWidgets('an unexpected log-out error shows the generic message', (
        tester,
      ) async {
        final auth = await _pumpApp(
          tester,
          repository: FakeAuthRepository(
            signedInUser: FakeAuthRepository.defaultUser,
          ),
        );
        await _finishLoading(tester);
        await _openProfile(tester);
        auth.throwNextWith(StateError('secret detail'), StackTrace.empty);

        await tester.tap(_logOut);
        await tester.pump();

        expect(
          find.widgetWithText(
            SnackBar,
            'Something went wrong. Please try again.',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('secret detail'), findsNothing);
        expect(_location(tester), AppRoutes.profile);
      });

      testWidgets('creating an account reaches Home', (tester) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');
        await _tapText(tester, 'Sign Up');

        await _signUp(tester);

        expect(auth.registerCalls.single, (
          fullName: 'Sam Lee',
          email: 'sam@example.com',
          password: 'secret12',
        ));
        expect(_location(tester), AppRoutes.home);
        expect(find.byType(HomeScreen), findsOneWidget);
        expect(_router(tester).canPop(), isFalse);
      });

      testWidgets('a failed registration shows a message on Sign Up', (
        tester,
      ) async {
        final auth = await _pumpApp(tester);
        await _finishLoading(tester);
        await _tapText(tester, 'Get Started');
        await _tapText(tester, 'Sign Up');
        auth.failNextWith(const EmailAlreadyInUse());

        await _signUp(tester);

        expect(_location(tester), AppRoutes.signUp);
        expect(
          find.text('An account with this email already exists.'),
          findsOneWidget,
        );
      });

      testWidgets('a signed-out user cannot open Home', (tester) async {
        await _pumpApp(tester);
        await _finishLoading(tester);

        _router(tester).go(AppRoutes.home);
        await tester.pumpAndSettle();

        expect(_location(tester), AppRoutes.splash);
      });

      testWidgets('a signed-out user cannot open any signed-in tab', (
        tester,
      ) async {
        await _pumpApp(tester);
        await _finishLoading(tester);

        for (final location in [
          AppRoutes.groups,
          AppRoutes.activity,
          AppRoutes.profile,
        ]) {
          _router(tester).go(location);
          await tester.pumpAndSettle();

          expect(_location(tester), AppRoutes.splash, reason: location);
        }
      });
    });

    group('signed-in tabs', () {
      /// Pumps the app signed in and waits until it reaches Home.
      Future<void> pumpSignedIn(WidgetTester tester) async {
        await _pumpApp(
          tester,
          repository: FakeAuthRepository(
            signedInUser: FakeAuthRepository.defaultUser,
          ),
        );
        await _finishLoading(tester);
      }

      Finder tab(String label) => find.descendant(
        of: find.byType(HomeShell),
        matching: find.text(label),
      );

      testWidgets('start on Home', (tester) async {
        await pumpSignedIn(tester);

        expect(_location(tester), AppRoutes.home);
        expect(find.byType(HomeScreen), findsOneWidget);
        for (final label in ['Home', 'Groups', 'Activity', 'Profile']) {
          expect(tab(label), findsOneWidget, reason: label);
        }
      });

      testWidgets('each tab opens its page', (tester) async {
        await pumpSignedIn(tester);

        for (final (label, location) in [
          ('Groups', AppRoutes.groups),
          ('Activity', AppRoutes.activity),
          ('Profile', AppRoutes.profile),
          ('Home', AppRoutes.home),
        ]) {
          await tester.tap(tab(label));
          await tester.pumpAndSettle();

          expect(_location(tester), location, reason: label);
        }
        expect(find.byType(HomeScreen), findsOneWidget);
      });

      testWidgets('tabs that are not built yet say Coming soon', (
        tester,
      ) async {
        await pumpSignedIn(tester);

        await tester.tap(tab('Groups'));
        await tester.pumpAndSettle();

        expect(find.text('Coming soon'), findsOneWidget);
      });

      testWidgets('Home greets the signed-in user by name', (tester) async {
        await pumpSignedIn(tester);

        expect(
          find.descendant(
            of: find.byType(HomeScreen),
            matching: find.text(FakeAuthRepository.defaultUser.nameToShow),
          ),
          findsOneWidget,
        );
      });

      testWidgets("Home's quick actions say Coming soon", (tester) async {
        await pumpSignedIn(tester);

        for (final action in ['Add Expense', 'New Group']) {
          await tester.tap(find.text(action));
          await tester.pump();

          expect(
            find.descendant(
              of: find.byType(SnackBar),
              matching: find.text('Coming soon'),
            ),
            findsOneWidget,
            reason: action,
          );
          expect(_location(tester), AppRoutes.home, reason: action);
        }
      });

      testWidgets('the bottom bar fits a small phone with 2x text scaling', (
        tester,
      ) async {
        await pumpSignedIn(tester);
        tester.view.physicalSize = const Size(320, 568);
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpAndSettle();

        await tester.tap(tab('Profile'));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(_location(tester), AppRoutes.profile);
      });

      testWidgets('the Add button says Coming soon', (tester) async {
        await pumpSignedIn(tester);

        await tester.tap(find.byTooltip('Add expense'));
        await tester.pump();

        expect(
          find.descendant(
            of: find.byType(SnackBar),
            matching: find.text('Coming soon'),
          ),
          findsOneWidget,
        );
        expect(_location(tester), AppRoutes.home);
      });
    });

    group('Splash page transition', () {
      Future<Duration> splashTransitionDuration(WidgetTester tester) async {
        await _pumpApp(tester);
        await _finishLoading(tester);
        final page = tester
            .widget<Navigator>(find.byType(Navigator))
            .pages
            .last;
        return (page as CustomTransitionPage<void>).transitionDuration;
      }

      testWidgets('cross-fades in 400 ms by default', (tester) async {
        expect(
          await splashTransitionDuration(tester),
          const Duration(milliseconds: 400),
        );
      });

      testWidgets('has no transition when reduced motion is requested', (
        tester,
      ) async {
        tester.platformDispatcher.accessibilityFeaturesTestValue =
            const FakeAccessibilityFeatures(disableAnimations: true);
        addTearDown(
          tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
        );

        expect(await splashTransitionDuration(tester), Duration.zero);
      });
    });
  });

  group('authRedirect', () {
    const signedIn = AsyncData<AppUser?>(FakeAuthRepository.defaultUser);
    const signedOut = AsyncData<AppUser?>(null);
    const loading = AsyncLoading<AppUser?>();
    const signedInTabs = [
      AppRoutes.home,
      AppRoutes.groups,
      AppRoutes.activity,
      AppRoutes.profile,
    ];

    test('never redirects away from Launch', () {
      for (final state in [signedIn, signedOut, loading]) {
        expect(authRedirect(state, AppRoutes.launch), isNull);
      }
    });

    test('does not move anyone while the auth state is unknown', () {
      final failed = AsyncError<AppUser?>(Exception('boom'), StackTrace.empty);
      for (final location in [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.signUp,
        ...signedInTabs,
      ]) {
        expect(authRedirect(loading, location), isNull, reason: location);
        expect(authRedirect(failed, location), isNull, reason: location);
      }
    });

    test('sends signed-in users from signed-out screens to Home', () {
      for (final location in [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.signUp,
      ]) {
        expect(authRedirect(signedIn, location), AppRoutes.home);
      }
      for (final location in signedInTabs) {
        expect(authRedirect(signedIn, location), isNull, reason: location);
      }
    });

    test('sends signed-out users from every signed-in tab to Splash', () {
      for (final location in signedInTabs) {
        expect(
          authRedirect(signedOut, location),
          AppRoutes.splash,
          reason: location,
        );
      }
      for (final location in [
        AppRoutes.splash,
        AppRoutes.login,
        AppRoutes.signUp,
      ]) {
        expect(authRedirect(signedOut, location), isNull);
      }
    });

    test('every redirect target is a place the user may stay', () {
      for (final state in [signedIn, signedOut]) {
        for (final location in [
          AppRoutes.splash,
          AppRoutes.login,
          AppRoutes.signUp,
          ...signedInTabs,
        ]) {
          final target = authRedirect(state, location);
          if (target != null) {
            expect(authRedirect(state, target), isNull, reason: target);
          }
        }
      }
    });
  });
}
