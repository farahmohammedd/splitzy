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
import 'package:splitzy/features/expenses/presentation/screens/add_expense_screen.dart';
import 'package:splitzy/features/expenses/presentation/screens/group_details_screen.dart';
import 'package:splitzy/features/groups/domain/entities/group.dart';
import 'package:splitzy/features/groups/domain/entities/member.dart';
import 'package:splitzy/features/groups/presentation/screens/create_group_screen.dart';
import 'package:splitzy/features/groups/presentation/screens/groups_screen.dart';
import 'package:splitzy/features/auth/presentation/widgets/auth_error_text.dart';
import 'package:splitzy/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:splitzy/features/home/presentation/screens/home_screen.dart';
import 'package:splitzy/features/home/presentation/widgets/balance_card.dart';
import 'package:splitzy/features/splash/presentation/screens/launch_screen.dart';
import 'package:splitzy/features/splash/presentation/screens/splash_screen.dart';
import 'package:splitzy/injection_container.dart';

import '../../helpers/fake_auth_repository.dart';
import '../../helpers/fake_expense_repository.dart';
import '../../helpers/fake_group_repository.dart';
import '../../helpers/fake_error_reporter.dart';

/// Pumps the app with [repository] (signed out by default) as its auth
/// backend, [groups] (empty by default) as its group storage and [expenses]
/// as its expense storage, and returns the auth backend.
Future<FakeAuthRepository> _pumpApp(
  WidgetTester tester, {
  FakeAuthRepository? repository,
  FakeGroupRepository? groups,
  FakeExpenseRepository? expenses,
}) async {
  // Screens scroll on small surfaces; a phone size keeps taps on-screen.
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final auth = repository ?? FakeAuthRepository();
  addTearDown(auth.dispose);
  final groupRepository = groups ?? FakeGroupRepository();
  addTearDown(groupRepository.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: InjectionContainer(
        authRepository: auth,
        groupRepository: groupRepository,
        expenseRepository: expenses ?? FakeExpenseRepository(),
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

/// A group named [name], owned by the default signed-in user unless
/// [ownerId] says otherwise.
Group _group(String name, {String? ownerId}) {
  final owner = ownerId ?? FakeAuthRepository.defaultUser.id;
  return Group(
    id: name,
    ownerId: owner,
    name: name,
    members: [
      Member(id: owner, name: 'Owner'),
      const Member(id: 'sara', name: 'Sara'),
    ],
    createdAt: DateTime(2026, 10, 12),
  );
}

/// Taps Save Expense.
Future<void> _tapSave(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Save Expense');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

/// Taps the Create Group button (the title has the same text).
Future<void> _tapCreateGroup(WidgetTester tester) async {
  final button = find.widgetWithText(FilledButton, 'Create Group');
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}

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
          AppRoutes.newGroup,
          AppRoutes.addExpense,
          AppRoutes.groupDetails('g1'),
        ]) {
          _router(tester).go(location);
          await tester.pumpAndSettle();

          expect(_location(tester), AppRoutes.splash, reason: location);
        }
      });
    });

    group('signed-in tabs', () {
      /// Pumps the app signed in and waits until it reaches Home.
      Future<void> pumpSignedIn(
        WidgetTester tester, {
        FakeGroupRepository? groups,
        FakeExpenseRepository? expenses,
      }) async {
        await _pumpApp(
          tester,
          repository: FakeAuthRepository(
            signedInUser: FakeAuthRepository.defaultUser,
          ),
          groups: groups,
          expenses: expenses,
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

        await tester.tap(tab('Activity'));
        await tester.pumpAndSettle();

        expect(find.text('Coming soon'), findsOneWidget);
      });

      testWidgets("the Groups tab lists the signed-in user's groups", (
        tester,
      ) async {
        await pumpSignedIn(
          tester,
          groups: FakeGroupRepository(
            groups: [
              _group('Trip to Dahab'),
              _group('Apartment'),
              _group('Not mine', ownerId: 'someone-else'),
            ],
          ),
        );

        await tester.tap(tab('Groups'));
        await tester.pumpAndSettle();

        expect(find.byType(GroupsScreen), findsOneWidget);
        expect(find.text('2 groups'), findsOneWidget);
        expect(find.text('Trip to Dahab'), findsOneWidget);
        expect(find.text('Apartment'), findsOneWidget);
        expect(find.text('Not mine'), findsNothing);
      });

      testWidgets('New Group on the Groups tab creates a group and returns '
          'to the tab, which shows it', (tester) async {
        await pumpSignedIn(tester);
        await tester.tap(tab('Groups'));
        await tester.pumpAndSettle();
        expect(find.text('No groups yet'), findsOneWidget);

        await tester.tap(find.text('New Group'));
        await tester.pumpAndSettle();
        expect(_location(tester), AppRoutes.newGroup);
        await tester.enterText(_field('e.g. Trip to Dahab'), 'Trip to Dahab');
        await tester.enterText(_field('Enter member name'), 'Sara');
        await _tapCreateGroup(tester);

        expect(_location(tester), AppRoutes.groups);
        expect(find.text('1 group'), findsOneWidget);
        expect(find.text('Trip to Dahab'), findsOneWidget);
      });

      testWidgets("Home shows the user's groups; See all opens the Groups "
          'tab', (tester) async {
        await pumpSignedIn(
          tester,
          groups: FakeGroupRepository(groups: [_group('Trip to Dahab')]),
        );

        expect(
          find.descendant(
            of: find.byType(HomeScreen),
            matching: find.text('Trip to Dahab'),
          ),
          findsOneWidget,
        );
        expect(find.text('No groups yet'), findsNothing);

        await _tapText(tester, 'See all');

        expect(_location(tester), AppRoutes.groups);
        expect(find.byType(GroupsScreen), findsOneWidget);
      });

      testWidgets('Home without groups shows its empty state and no See all', (
        tester,
      ) async {
        await pumpSignedIn(tester);

        expect(find.text('No groups yet'), findsOneWidget);
        expect(find.text('See all'), findsNothing);
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

      testWidgets("Home's Add Expense opens Add Expense over the tabs", (
        tester,
      ) async {
        await pumpSignedIn(tester);

        await tester.tap(find.text('Add Expense'));
        await tester.pumpAndSettle();

        expect(_location(tester), AppRoutes.addExpense);
        expect(find.byType(AddExpenseScreen), findsOneWidget);
        // The bottom bar is hidden while adding an expense.
        expect(find.byType(HomeShell), findsNothing);
      });

      testWidgets('Back on Add Expense returns to the tab it was opened '
          'from', (tester) async {
        await pumpSignedIn(tester);
        await tester.tap(tab('Groups'));
        await tester.pumpAndSettle();
        await tester.tap(find.byTooltip('Add expense'));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();

        expect(_location(tester), AppRoutes.groups);
      });

      testWidgets('saving an expense stores it in the chosen group and '
          'returns', (tester) async {
        final expenses = FakeExpenseRepository();
        await pumpSignedIn(
          tester,
          groups: FakeGroupRepository(groups: [_group('Trip to Dahab')]),
          expenses: expenses,
        );
        await tester.tap(find.byTooltip('Add expense'));
        await tester.pumpAndSettle();

        await tester.enterText(_field('e.g. Dinner'), 'Dinner');
        await tester.enterText(_field('0.00'), '600');
        await _tapSave(tester);

        final call = expenses.addCalls.single;
        expect(call.groupId, 'Trip to Dahab');
        expect(call.description, 'Dinner');
        expect(call.amount, 60000);
        expect(call.paidBy, FakeAuthRepository.defaultUser.id);
        expect(call.shares, {
          FakeAuthRepository.defaultUser.id: 30000,
          'sara': 30000,
        });
        expect(_location(tester), AppRoutes.home);
      });

      testWidgets('a failed save stays on Add Expense with its message', (
        tester,
      ) async {
        final expenses = FakeExpenseRepository()
          ..failNextWith(const NetworkFailure());
        await pumpSignedIn(
          tester,
          groups: FakeGroupRepository(groups: [_group('Trip')]),
          expenses: expenses,
        );
        await tester.tap(find.byTooltip('Add expense'));
        await tester.pumpAndSettle();

        await tester.enterText(_field('e.g. Dinner'), 'Dinner');
        await tester.enterText(_field('0.00'), '600');
        await _tapSave(tester);

        expect(_location(tester), AppRoutes.addExpense);
        expect(find.text(const NetworkFailure().message), findsOneWidget);
      });

      testWidgets('without groups, Add Expense leads to New Group; the new '
          'group is then ready to use', (tester) async {
        await pumpSignedIn(tester);
        await tester.tap(find.byTooltip('Add expense'));
        await tester.pumpAndSettle();
        expect(find.text('Create a group first'), findsOneWidget);

        await tester.tap(find.text('New Group'));
        await tester.pumpAndSettle();
        await tester.enterText(_field('e.g. Trip to Dahab'), 'Trip to Dahab');
        await tester.enterText(_field('Enter member name'), 'Sara');
        await _tapCreateGroup(tester);

        expect(_location(tester), AppRoutes.addExpense);
        expect(find.text('Trip to Dahab'), findsOneWidget);
        expect(find.widgetWithText(ChoiceChip, 'Sara'), findsOneWidget);
      });

      testWidgets("Home's New Group opens Create Group over the tabs", (
        tester,
      ) async {
        await pumpSignedIn(tester);

        await tester.tap(find.text('New Group'));
        await tester.pumpAndSettle();

        expect(_location(tester), AppRoutes.newGroup);
        expect(find.byType(CreateGroupScreen), findsOneWidget);
        // The bottom bar is hidden while creating a group.
        expect(find.byType(HomeShell), findsNothing);
      });

      testWidgets('Back on Create Group returns to Home', (tester) async {
        await pumpSignedIn(tester);
        await tester.tap(find.text('New Group'));
        await tester.pumpAndSettle();

        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();

        expect(_location(tester), AppRoutes.home);
      });

      testWidgets('creating a group stores it for the signed-in user and '
          'returns to Home', (tester) async {
        final groups = FakeGroupRepository();
        await pumpSignedIn(tester, groups: groups);
        await tester.tap(find.text('New Group'));
        await tester.pumpAndSettle();

        await tester.enterText(_field('e.g. Trip to Dahab'), 'Trip to Dahab');
        await tester.enterText(_field('Enter member name'), 'Sara');
        await tester.tap(find.byTooltip('Add member'));
        await tester.pump();
        await _tapCreateGroup(tester);

        final call = groups.createCalls.single;
        expect(call.ownerId, FakeAuthRepository.defaultUser.id);
        expect(call.ownerName, FakeAuthRepository.defaultUser.nameToShow);
        expect(call.name, 'Trip to Dahab');
        expect(call.memberNames, ['Sara']);
        expect(_location(tester), AppRoutes.home);
      });

      testWidgets('a failed create stays on Create Group with its message', (
        tester,
      ) async {
        final groups = FakeGroupRepository()
          ..failNextWith(const NetworkFailure());
        await pumpSignedIn(tester, groups: groups);
        await tester.tap(find.text('New Group'));
        await tester.pumpAndSettle();

        await tester.enterText(_field('e.g. Trip to Dahab'), 'Trip');
        await tester.enterText(_field('Enter member name'), 'Sara');
        await _tapCreateGroup(tester);

        expect(_location(tester), AppRoutes.newGroup);
        expect(find.text(const NetworkFailure().message), findsOneWidget);
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

      testWidgets("a group card on the Groups tab opens the group's page", (
        tester,
      ) async {
        await pumpSignedIn(
          tester,
          groups: FakeGroupRepository(groups: [_group('Trip to Dahab')]),
        );
        await tester.tap(tab('Groups'));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Trip to Dahab'));
        await tester.pumpAndSettle();

        expect(_location(tester), AppRoutes.groupDetails('Trip to Dahab'));
        expect(find.byType(GroupDetailsScreen), findsOneWidget);
        expect(find.byType(HomeShell), findsNothing);

        await tester.tap(find.byTooltip('Back'));
        await tester.pumpAndSettle();
        expect(_location(tester), AppRoutes.groups);
      });

      testWidgets("a group card on Home opens the group's page", (
        tester,
      ) async {
        await pumpSignedIn(
          tester,
          groups: FakeGroupRepository(groups: [_group('Trip to Dahab')]),
        );

        await _tapText(tester, 'Trip to Dahab');

        expect(_location(tester), AppRoutes.groupDetails('Trip to Dahab'));
        expect(find.byType(GroupDetailsScreen), findsOneWidget);
      });

      testWidgets("Add Expense on a group's page adds to that group and "
          'returns to the page, which shows the expense', (tester) async {
        final expenses = FakeExpenseRepository();
        addTearDown(expenses.dispose);
        await pumpSignedIn(
          tester,
          groups: FakeGroupRepository(
            groups: [_group('Apartment'), _group('Trip to Dahab')],
          ),
          expenses: expenses,
        );
        _router(tester).push(AppRoutes.groupDetails('Trip to Dahab'));
        await tester.pumpAndSettle();
        expect(find.text('No expenses yet'), findsOneWidget);

        await _tapText(tester, 'Add Expense');
        // The page's group is chosen, not the newest one.
        expect(find.text('Trip to Dahab'), findsOneWidget);
        expect(find.text('Apartment'), findsNothing);
        await tester.enterText(_field('e.g. Dinner'), 'Dinner');
        await tester.enterText(_field('0.00'), '600');
        await _tapSave(tester);

        expect(expenses.addCalls.single.groupId, 'Trip to Dahab');
        expect(_location(tester), AppRoutes.groupDetails('Trip to Dahab'));
        expect(find.text('Dinner'), findsOneWidget);
        expect(find.text('EGP 600'), findsWidgets);
      });

      testWidgets("Home's balance card adds up the user's balance across "
          'groups and updates after an expense', (tester) async {
        final expenses = FakeExpenseRepository();
        addTearDown(expenses.dispose);
        await pumpSignedIn(
          tester,
          groups: FakeGroupRepository(
            groups: [_group('Trip to Dahab'), _group('Apartment')],
          ),
          expenses: expenses,
        );
        Finder inCard(String text) => find.descendant(
          of: find.byType(BalanceCard),
          matching: find.text(text),
        );
        expect(inCard('No expenses yet'), findsOneWidget);

        await tester.tap(find.byTooltip('Add expense'));
        await tester.pumpAndSettle();
        await tester.enterText(_field('e.g. Dinner'), 'Dinner');
        await tester.enterText(_field('0.00'), '600');
        await _tapSave(tester);

        // Paid 600, share 300 (two members): owed 300.
        expect(_location(tester), AppRoutes.home);
        expect(inCard('+ EGP 300'), findsOneWidget);
        expect(inCard('No expenses yet'), findsNothing);
      });

      testWidgets("group cards show the user's balance in each group", (
        tester,
      ) async {
        final expenses = FakeExpenseRepository();
        addTearDown(expenses.dispose);
        await pumpSignedIn(
          tester,
          groups: FakeGroupRepository(
            groups: [_group('Trip to Dahab'), _group('Apartment')],
          ),
          expenses: expenses,
        );
        await tester.tap(find.byTooltip('Add expense'));
        await tester.pumpAndSettle();
        await tester.enterText(_field('e.g. Dinner'), 'Dinner');
        await tester.enterText(_field('0.00'), '600');
        await _tapSave(tester);

        // On Home: Trip to Dahab has the expense, Apartment has none.
        expect(find.text('You get EGP 300'), findsOneWidget);
        expect(find.text('No expenses yet'), findsOneWidget);

        await tester.tap(tab('Groups'));
        await tester.pumpAndSettle();

        expect(find.text('You get EGP 300'), findsOneWidget);
        expect(find.text('No expenses yet'), findsOneWidget);
      });

      testWidgets("a group that is not the user's shows a message", (
        tester,
      ) async {
        await pumpSignedIn(
          tester,
          groups: FakeGroupRepository(
            groups: [_group('Not mine', ownerId: 'someone-else')],
          ),
        );

        _router(tester).push(AppRoutes.groupDetails('Not mine'));
        await tester.pumpAndSettle();

        expect(find.text('This group is not available.'), findsOneWidget);
        expect(find.byType(GroupDetailsScreen), findsNothing);
      });

      testWidgets('the Add button opens Add Expense', (tester) async {
        await pumpSignedIn(tester);

        await tester.tap(find.byTooltip('Add expense'));
        await tester.pumpAndSettle();

        expect(_location(tester), AppRoutes.addExpense);
        expect(find.byType(AddExpenseScreen), findsOneWidget);
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
    final signedInTabs = [
      AppRoutes.home,
      AppRoutes.groups,
      AppRoutes.activity,
      AppRoutes.profile,
      AppRoutes.newGroup,
      AppRoutes.addExpense,
      AppRoutes.groupDetails('g1'),
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
