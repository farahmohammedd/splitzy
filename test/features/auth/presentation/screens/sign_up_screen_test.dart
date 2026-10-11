import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:splitzy/features/auth/presentation/widgets/google_mark.dart';
import 'package:splitzy/features/auth/presentation/widgets/login_background.dart';

const _duration = SignUpScreen.entranceDuration;

final _illustration = find.bySemanticsLabel('Three friends splitting a bill');

/// The illustration is the only image on the screen. Used for opacity checks,
/// where the semantics finder cannot work: a fully transparent
/// `FadeTransition` removes its child from the semantics tree.
final _illustrationImage = find.byType(Image);
final _nameField = find.widgetWithText(TextField, 'Full name');
final _emailField = find.widgetWithText(TextField, 'Email address');
final _passwordField = find.widgetWithText(TextField, 'Password');
final _confirmField = find.widgetWithText(TextField, 'Confirm password');
final _createAccount = find.text('Create Account');
final _google = find.text('Continue with Google');
final _signIn = find.text('Sign In');

/// Records which callbacks the screen invoked.
class _Calls {
  int back = 0;
  int google = 0;
  int signIn = 0;
  final created = <SignUpDetails>[];
}

Future<_Calls> _pumpSignUp(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  bool isSubmitting = false,
  bool isGoogleSubmitting = false,
  String? errorMessage,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final calls = _Calls();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: SignUpScreen(
        onBack: () => calls.back++,
        onCreateAccount: calls.created.add,
        onContinueWithGoogle: () => calls.google++,
        onSignIn: () => calls.signIn++,
        isSubmitting: isSubmitting,
        isGoogleSubmitting: isGoogleSubmitting,
        errorMessage: errorMessage,
      ),
    ),
  );
  return calls;
}

TextField _textField(WidgetTester tester, Finder finder) =>
    tester.widget<TextField>(finder);

double _opacityAbove(WidgetTester tester, Finder target) {
  final fade = find.ancestor(of: target, matching: find.byType(FadeTransition));
  return tester.widget<FadeTransition>(fade.first).opacity.value;
}

Future<void> _fillForm(WidgetTester tester) async {
  await tester.enterText(_nameField, '  Sam Lee ');
  await tester.enterText(_emailField, ' sam@example.com ');
  await tester.enterText(_passwordField, ' secret ');
  await tester.enterText(_confirmField, ' secret ');
}

void main() {
  group('SignUpScreen', () {
    testWidgets('renders every element of the design', (tester) async {
      await _pumpSignUp(tester);
      await tester.pump(_duration);

      expect(find.byType(LoginBackground), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(_illustration, findsOneWidget);
      expect(find.text('Create Your Account'), findsOneWidget);
      expect(find.text('Sign up to start using Splitzy'), findsOneWidget);
      expect(_nameField, findsOneWidget);
      expect(_emailField, findsOneWidget);
      expect(_passwordField, findsOneWidget);
      expect(_confirmField, findsOneWidget);
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsNWidgets(2));
      expect(_createAccount, findsOneWidget);
      expect(find.text('or continue with'), findsOneWidget);
      expect(_google, findsOneWidget);
      expect(find.byType(GoogleMark), findsOneWidget);
      expect(find.text('Already have an account?'), findsOneWidget);
      expect(_signIn, findsOneWidget);
    });

    testWidgets('has no Forgot Password link', (tester) async {
      await _pumpSignUp(tester);

      expect(find.text('Forgot Password?'), findsNothing);
    });

    testWidgets('configures the fields for account creation', (tester) async {
      await _pumpSignUp(tester);

      final name = _textField(tester, _nameField);
      expect(name.keyboardType, TextInputType.name);
      expect(name.textCapitalization, TextCapitalization.words);
      expect(name.autofillHints, [AutofillHints.name]);
      expect(name.textInputAction, TextInputAction.next);

      expect(_textField(tester, _emailField).autofillHints, [
        AutofillHints.email,
      ]);

      final password = _textField(tester, _passwordField);
      expect(password.autofillHints, [AutofillHints.newPassword]);
      expect(password.textInputAction, TextInputAction.next);

      final confirm = _textField(tester, _confirmField);
      expect(confirm.autofillHints, [AutofillHints.newPassword]);
      expect(confirm.textInputAction, TextInputAction.done);
    });

    testWidgets('toggles each password field independently', (tester) async {
      await _pumpSignUp(tester);
      await tester.pump(_duration);

      expect(_textField(tester, _passwordField).obscureText, isTrue);
      expect(_textField(tester, _confirmField).obscureText, isTrue);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(_textField(tester, _passwordField).obscureText, isFalse);
      expect(_textField(tester, _confirmField).obscureText, isTrue);
      expect(find.byTooltip('Hide password'), findsOneWidget);

      await tester.ensureVisible(find.byTooltip('Show confirm password'));
      await tester.tap(find.byTooltip('Show confirm password'));
      await tester.pump();
      expect(_textField(tester, _confirmField).obscureText, isFalse);

      await tester.tap(find.byTooltip('Hide confirm password'));
      await tester.pump();
      expect(_textField(tester, _confirmField).obscureText, isTrue);
      expect(_textField(tester, _passwordField).obscureText, isFalse);
    });

    testWidgets('Create Account reports trimmed name/email and raw passwords', (
      tester,
    ) async {
      final calls = await _pumpSignUp(tester);
      await tester.pump(_duration);

      await _fillForm(tester);
      await tester.ensureVisible(_createAccount);
      await tester.tap(_createAccount);

      expect(calls.created, [
        (
          fullName: 'Sam Lee',
          email: 'sam@example.com',
          password: ' secret ',
          confirmPassword: ' secret ',
        ),
      ]);
    });

    testWidgets('submitting the confirm password field also creates', (
      tester,
    ) async {
      final calls = await _pumpSignUp(tester);
      await tester.pump(_duration);

      await _fillForm(tester);
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(calls.created, hasLength(1));
    });

    testWidgets('reports Back, Google and Sign In taps', (tester) async {
      final calls = await _pumpSignUp(tester);
      await tester.pump(_duration);

      await tester.tap(find.byTooltip('Back'));
      await tester.ensureVisible(_google);
      await tester.tap(_google);
      await tester.ensureVisible(_signIn);
      await tester.tap(_signIn);

      expect(calls.back, 1);
      expect(calls.google, 1);
      expect(calls.signIn, 1);
      expect(calls.created, isEmpty);
    });

    group('validation', () {
      Future<void> submit(WidgetTester tester) async {
        await tester.ensureVisible(_createAccount);
        await tester.tap(_createAccount);
        await tester.pump();
      }

      testWidgets('empty fields show messages and do not create', (
        tester,
      ) async {
        final calls = await _pumpSignUp(tester);
        await tester.pump(_duration);

        await submit(tester);

        expect(find.text('Enter your full name.'), findsOneWidget);
        expect(find.text('Enter your email.'), findsOneWidget);
        expect(find.text('Enter your password.'), findsOneWidget);
        expect(calls.created, isEmpty);
      });

      testWidgets('rejects a name over 50 characters', (tester) async {
        final calls = await _pumpSignUp(tester);
        await tester.pump(_duration);
        await _fillForm(tester);
        await tester.enterText(_nameField, 'a' * 51);

        await submit(tester);

        expect(
          find.text('Name must be 50 characters or fewer.'),
          findsOneWidget,
        );
        expect(calls.created, isEmpty);
      });

      testWidgets('rejects an invalid email', (tester) async {
        final calls = await _pumpSignUp(tester);
        await tester.pump(_duration);
        await _fillForm(tester);
        await tester.enterText(_emailField, 'sam example.com');

        await submit(tester);

        expect(find.text('Enter a valid email address.'), findsOneWidget);
        expect(calls.created, isEmpty);
      });

      testWidgets('rejects a password shorter than 8 characters', (
        tester,
      ) async {
        final calls = await _pumpSignUp(tester);
        await tester.pump(_duration);
        await _fillForm(tester);
        await tester.enterText(_passwordField, 'short12');
        await tester.enterText(_confirmField, 'short12');

        await submit(tester);

        expect(find.text('Use at least 8 characters.'), findsOneWidget);
        expect(calls.created, isEmpty);
      });

      testWidgets('rejects a confirmation that does not match', (tester) async {
        final calls = await _pumpSignUp(tester);
        await tester.pump(_duration);
        await _fillForm(tester);
        await tester.enterText(_confirmField, 'different');

        await submit(tester);

        expect(find.text("Passwords don't match."), findsOneWidget);
        expect(calls.created, isEmpty);
      });
    });

    testWidgets('while submitting shows loading and ignores submits', (
      tester,
    ) async {
      final calls = await _pumpSignUp(tester, isSubmitting: true);
      await tester.pump(_duration);
      await _fillForm(tester);

      await tester.ensureVisible(_createAccount);
      await tester.tap(_createAccount);
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(calls.created, isEmpty);
    });

    testWidgets('while signing in with Google shows progress there and '
        'ignores both actions', (tester) async {
      final calls = await _pumpSignUp(tester, isGoogleSubmitting: true);
      await tester.pump(_duration);
      await _fillForm(tester);

      expect(
        find.descendant(
          of: find.byType(OutlinedButton),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(find.byType(GoogleMark), findsNothing);
      await tester.ensureVisible(_google);
      await tester.tap(_google);
      await tester.ensureVisible(_createAccount);
      await tester.tap(_createAccount);

      expect(calls.google, 0);
      expect(calls.created, isEmpty);
    });

    testWidgets('shows the error message above Create Account', (tester) async {
      await _pumpSignUp(
        tester,
        errorMessage: 'An account with this email already exists.',
      );
      await tester.pump(_duration);

      final error = find.text('An account with this email already exists.');
      expect(error, findsOneWidget);
      expect(
        tester.getBottomLeft(error).dy,
        lessThanOrEqualTo(tester.getTopLeft(_createAccount).dy),
      );
    });

    testWidgets('fits validation and error messages on a small phone', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pumpSignUp(
        tester,
        size: const Size(320, 568),
        errorMessage:
            'No internet connection. Check your network and try '
            'again.',
      );
      await tester.pump(_duration);

      await tester.ensureVisible(_createAccount);
      await tester.tap(_createAccount);
      await tester.pump();

      expect(tester.takeException(), isNull);
      await tester.ensureVisible(_createAccount);
      expect(_createAccount.hitTestable(), findsOneWidget);
    });

    testWidgets('fades the content in after the illustration', (tester) async {
      await _pumpSignUp(tester);

      expect(_opacityAbove(tester, _illustrationImage), 0);
      expect(_opacityAbove(tester, _createAccount), 0);

      await tester.pump(_duration * 0.5);
      expect(_opacityAbove(tester, _illustrationImage), 1);
      expect(_opacityAbove(tester, _createAccount), lessThan(1));

      await tester.pump(_duration * 0.5);
      expect(_opacityAbove(tester, _createAccount), 1);
      expect(_opacityAbove(tester, _signIn), 1);
    });

    testWidgets('shows everything immediately when animations are disabled', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      final calls = await _pumpSignUp(tester);

      for (final target in [_illustration, _createAccount, _google, _signIn]) {
        expect(_opacityAbove(tester, target), 1);
      }
      await _fillForm(tester);
      await tester.ensureVisible(_createAccount);
      await tester.tap(_createAccount);
      expect(calls.created, hasLength(1));
    });

    group('lays out without overflow and keeps Create Account reachable', () {
      const sizes = {
        'small phone': Size(320, 568),
        'phone': Size(390, 844),
        'tablet landscape': Size(1024, 768),
      };

      Future<void> expectReachable(WidgetTester tester, Size size) async {
        final calls = await _pumpSignUp(tester, size: size);
        await tester.pump(_duration);

        expect(tester.takeException(), isNull);
        await _fillForm(tester);
        await tester.ensureVisible(_createAccount);
        await tester.tap(_createAccount);
        expect(calls.created, hasLength(1));

        await tester.ensureVisible(_signIn);
        await tester.tap(_signIn);
        expect(calls.signIn, 1);
      }

      for (final MapEntry(key: name, value: size) in sizes.entries) {
        testWidgets(
          'on a $name (${size.width.toInt()}x${size.height.toInt()})',
          (tester) => expectReachable(tester, size),
        );
      }

      testWidgets('on a small phone with 2x text scaling', (tester) async {
        tester.platformDispatcher.textScaleFactorTestValue = 2;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        await expectReachable(tester, const Size(320, 568));
      });
    });
  });
}
