import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/auth/presentation/screens/profile_screen.dart';

final _logOut = find.text('Log out');

Future<void> _pumpProfile(
  WidgetTester tester, {
  VoidCallback? onLogOut,
  bool isLoggingOut = false,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: ProfileScreen(
        name: 'Sam Lee',
        email: 'sam@example.com',
        onLogOut: onLogOut ?? () {},
        isLoggingOut: isLoggingOut,
      ),
    ),
  );
}

void main() {
  group('ProfileScreen', () {
    testWidgets('shows the name and email', (tester) async {
      await _pumpProfile(tester);

      expect(find.text('Profile'), findsOneWidget);
      expect(find.text('Sam Lee'), findsOneWidget);
      expect(find.text('sam@example.com'), findsOneWidget);
    });

    testWidgets('reports the Log out action', (tester) async {
      var logOuts = 0;
      await _pumpProfile(tester, onLogOut: () => logOuts++);

      await tester.tap(_logOut);

      expect(logOuts, 1);
    });

    testWidgets('while logging out, shows progress and ignores taps', (
      tester,
    ) async {
      var logOuts = 0;
      await _pumpProfile(tester, onLogOut: () => logOuts++, isLoggingOut: true);

      await tester.tap(_logOut, warnIfMissed: false);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(logOuts, 0);
      // The label stays, so the button keeps its accessible name.
      expect(_logOut, findsOneWidget);
    });

    for (final (name, size, textScale) in [
      ('a small phone', const Size(320, 568), 1.0),
      ('a phone', const Size(390, 844), 1.0),
      ('a tablet landscape', const Size(1024, 768), 1.0),
      ('a small phone with 2x text scaling', const Size(320, 568), 2.0),
    ]) {
      testWidgets('lays out without overflow and keeps Log out reachable on '
          '$name', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        var logOuts = 0;

        await _pumpProfile(tester, onLogOut: () => logOuts++);
        await tester.ensureVisible(_logOut);
        await tester.tap(_logOut);

        expect(tester.takeException(), isNull);
        expect(logOuts, 1);
      });
    }
  });
}
