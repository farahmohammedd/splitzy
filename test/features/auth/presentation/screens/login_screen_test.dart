import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/assets/app_images.dart';
import 'package:splitzy/core/theme/app_colors.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/auth/presentation/screens/login_screen.dart';
import 'package:splitzy/features/auth/presentation/widgets/google_mark.dart';
import 'package:splitzy/features/auth/presentation/widgets/login_background.dart';

const _duration = LoginScreen.entranceDuration;

final _illustration = find.byWidgetPredicate(
  (widget) =>
      widget is Image &&
      switch (widget.image) {
        ResizeImage(imageProvider: AssetImage(:final assetName)) =>
          assetName == AppImages.loginFriends,
        _ => false,
      },
);
final _emailField = find.widgetWithText(TextField, 'Email address');
final _passwordField = find.widgetWithText(TextField, 'Password');
final _logIn = find.text('Log In');
final _google = find.text('Continue with Google');
final _signUp = find.text('Sign Up');
final _forgot = find.text('Forgot Password?');

/// Records which callbacks the screen invoked.
class _Calls {
  int back = 0;
  int forgot = 0;
  int google = 0;
  int signUp = 0;
  final logIns = <(String, String)>[];
}

Future<void> _enterValidCredentials(WidgetTester tester) async {
  await tester.enterText(_emailField, 'sam@example.com');
  await tester.enterText(_passwordField, 'secret');
}

Future<_Calls> _pumpLogin(
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
      home: LoginScreen(
        onBack: () => calls.back++,
        onLogIn: (email, password) => calls.logIns.add((email, password)),
        onForgotPassword: () => calls.forgot++,
        onContinueWithGoogle: () => calls.google++,
        onSignUp: () => calls.signUp++,
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

void main() {
  group('LoginScreen', () {
    testWidgets('renders every element of the design', (tester) async {
      await _pumpLogin(tester);
      await tester.pump(_duration);

      expect(find.byType(LoginBackground), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(_illustration, findsOneWidget);
      expect(find.text('Welcome Back'), findsOneWidget);
      expect(find.text('Log in to continue to Splitzy'), findsOneWidget);
      expect(_emailField, findsOneWidget);
      expect(_passwordField, findsOneWidget);
      expect(find.byIcon(Icons.mail_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.lock_outline_rounded), findsOneWidget);
      expect(_forgot, findsOneWidget);
      expect(_logIn, findsOneWidget);
      expect(find.text('or continue with'), findsOneWidget);
      expect(_google, findsOneWidget);
      expect(find.byType(GoogleMark), findsOneWidget);
      expect(find.text('Don’t have an account?'), findsOneWidget);
      expect(_signUp, findsOneWidget);
    });

    testWidgets('configures the fields for email and password entry', (
      tester,
    ) async {
      await _pumpLogin(tester);

      final email = _textField(tester, _emailField);
      expect(email.keyboardType, TextInputType.emailAddress);
      expect(email.textInputAction, TextInputAction.next);
      expect(email.autofillHints, [AutofillHints.email]);

      final password = _textField(tester, _passwordField);
      expect(password.textInputAction, TextInputAction.done);
      expect(password.autofillHints, [AutofillHints.password]);
    });

    testWidgets('hides the password until visibility is toggled', (
      tester,
    ) async {
      await _pumpLogin(tester);
      await tester.pump(_duration);

      expect(_textField(tester, _passwordField).obscureText, isTrue);
      expect(find.byTooltip('Show password'), findsOneWidget);

      await tester.tap(find.byTooltip('Show password'));
      await tester.pump();
      expect(_textField(tester, _passwordField).obscureText, isFalse);
      expect(find.byTooltip('Hide password'), findsOneWidget);

      await tester.tap(find.byTooltip('Hide password'));
      await tester.pump();
      expect(_textField(tester, _passwordField).obscureText, isTrue);
    });

    testWidgets('Log In reports the trimmed email and the password', (
      tester,
    ) async {
      final calls = await _pumpLogin(tester);
      await tester.pump(_duration);

      await tester.enterText(_emailField, '  sam@example.com ');
      await tester.enterText(_passwordField, ' secret ');
      await tester.tap(_logIn);

      expect(calls.logIns, [('sam@example.com', ' secret ')]);
    });

    testWidgets('submitting the password field also logs in', (tester) async {
      final calls = await _pumpLogin(tester);
      await tester.pump(_duration);

      await tester.enterText(_emailField, 'sam@example.com');
      await tester.enterText(_passwordField, 'secret');
      await tester.testTextInput.receiveAction(TextInputAction.done);

      expect(calls.logIns, [('sam@example.com', 'secret')]);
    });

    testWidgets('reports Back, Forgot Password, Google and Sign Up taps', (
      tester,
    ) async {
      final calls = await _pumpLogin(tester);
      await tester.pump(_duration);

      await tester.tap(find.byTooltip('Back'));
      await tester.tap(_forgot);
      await tester.tap(_google);
      await tester.ensureVisible(_signUp);
      await tester.tap(_signUp);

      expect(calls.back, 1);
      expect(calls.forgot, 1);
      expect(calls.google, 1);
      expect(calls.signUp, 1);
      expect(calls.logIns, isEmpty);
    });

    group('validation', () {
      testWidgets('empty fields show messages and do not log in', (
        tester,
      ) async {
        final calls = await _pumpLogin(tester);
        await tester.pump(_duration);

        await tester.tap(_logIn);
        await tester.pump();

        expect(find.text('Enter your email.'), findsOneWidget);
        expect(find.text('Enter your password.'), findsOneWidget);
        expect(calls.logIns, isEmpty);
      });

      testWidgets('an invalid email is rejected', (tester) async {
        final calls = await _pumpLogin(tester);
        await tester.pump(_duration);

        await tester.enterText(_emailField, 'sam@example');
        await tester.enterText(_passwordField, 'secret');
        await tester.tap(_logIn);
        await tester.pump();

        expect(find.text('Enter a valid email address.'), findsOneWidget);
        expect(calls.logIns, isEmpty);
      });

      testWidgets('messages clear as the user fixes the fields', (
        tester,
      ) async {
        await _pumpLogin(tester);
        await tester.pump(_duration);
        await tester.tap(_logIn);
        await tester.pump();

        await _enterValidCredentials(tester);
        await tester.pump();

        expect(find.text('Enter your email.'), findsNothing);
        expect(find.text('Enter your password.'), findsNothing);
      });
    });

    group('while submitting', () {
      testWidgets('shows the loading button and ignores submits', (
        tester,
      ) async {
        final calls = await _pumpLogin(tester, isSubmitting: true);
        await tester.pump(_duration);
        await _enterValidCredentials(tester);

        await tester.tap(_logIn);
        await tester.testTextInput.receiveAction(TextInputAction.done);

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(calls.logIns, isEmpty);
      });

      testWidgets('ignores Google while an email log-in runs', (tester) async {
        final calls = await _pumpLogin(tester, isSubmitting: true);
        await tester.pump(_duration);

        await tester.tap(_google);

        expect(calls.google, 0);
      });
    });

    group('while signing in with Google', () {
      testWidgets('shows progress in the Google button and ignores taps', (
        tester,
      ) async {
        final calls = await _pumpLogin(tester, isGoogleSubmitting: true);
        await tester.pump(_duration);

        expect(
          find.descendant(
            of: find.byType(OutlinedButton),
            matching: find.byType(CircularProgressIndicator),
          ),
          findsOneWidget,
        );
        expect(find.byType(GoogleMark), findsNothing);
        await tester.tap(_google);
        expect(calls.google, 0);
      });

      testWidgets('ignores an email log-in', (tester) async {
        final calls = await _pumpLogin(tester, isGoogleSubmitting: true);
        await tester.pump(_duration);
        await _enterValidCredentials(tester);

        await tester.tap(_logIn);
        await tester.testTextInput.receiveAction(TextInputAction.done);

        expect(calls.logIns, isEmpty);
      });
    });

    testWidgets('shows the error message above Log In', (tester) async {
      await _pumpLogin(tester, errorMessage: 'Incorrect email or password.');
      await tester.pump(_duration);

      final error = find.text('Incorrect email or password.');
      expect(error, findsOneWidget);
      expect(
        tester.getBottomLeft(error).dy,
        lessThanOrEqualTo(tester.getTopLeft(_logIn).dy),
      );
    });

    testWidgets('fits validation and error messages on a small phone', (
      tester,
    ) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pumpLogin(
        tester,
        size: const Size(320, 568),
        errorMessage:
            'No internet connection. Check your network and try '
            'again.',
      );
      await tester.pump(_duration);

      await tester.ensureVisible(_logIn);
      await tester.tap(_logIn);
      await tester.pump();

      expect(tester.takeException(), isNull);
      await tester.ensureVisible(_logIn);
      expect(_logIn.hitTestable(), findsOneWidget);
    });

    testWidgets('fades the content in after the illustration', (tester) async {
      await _pumpLogin(tester);

      expect(_opacityAbove(tester, _illustration), 0);
      expect(_opacityAbove(tester, _logIn), 0);

      await tester.pump(_duration * 0.5);
      expect(_opacityAbove(tester, _illustration), 1);
      expect(_opacityAbove(tester, _logIn), lessThan(1));

      await tester.pump(_duration * 0.5);
      expect(_opacityAbove(tester, _logIn), 1);
      expect(_opacityAbove(tester, _signUp), 1);
    });

    testWidgets('shows everything immediately when animations are disabled', (
      tester,
    ) async {
      tester.platformDispatcher.accessibilityFeaturesTestValue =
          const FakeAccessibilityFeatures(disableAnimations: true);
      addTearDown(
        tester.platformDispatcher.clearAccessibilityFeaturesTestValue,
      );

      final calls = await _pumpLogin(tester);

      for (final target in [_illustration, _logIn, _google, _signUp]) {
        expect(_opacityAbove(tester, target), 1);
      }
      await _enterValidCredentials(tester);
      await tester.tap(_logIn);
      expect(calls.logIns, hasLength(1));
    });

    group('lays out without overflow and keeps Log In reachable', () {
      const sizes = {
        'small phone': Size(320, 568),
        'phone': Size(390, 844),
        'tablet landscape': Size(1024, 768),
      };

      Future<void> expectReachable(WidgetTester tester, Size size) async {
        final calls = await _pumpLogin(tester, size: size);
        await tester.pump(_duration);

        expect(tester.takeException(), isNull);
        await _enterValidCredentials(tester);
        await tester.ensureVisible(_logIn);
        await tester.tap(_logIn);
        expect(calls.logIns, hasLength(1));
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

  group('LoginBackgroundPainter', () {
    testWidgets('paints with theme sage colors', (tester) async {
      await _pumpLogin(tester);

      final painter = tester
          .widgetList<CustomPaint>(find.byType(CustomPaint))
          .map((paint) => paint.painter)
          .whereType<LoginBackgroundPainter>()
          .single;
      expect(painter.softShape, AppColors.secondary);
      expect(
        painter.paleShape,
        AppColors.secondary.withValues(alpha: LoginBackground.paleShapeOpacity),
      );
    });
  });
}
