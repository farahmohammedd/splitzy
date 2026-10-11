import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/core/widgets/primary_arrow_button.dart';

void main() {
  group('PrimaryArrowButton', () {
    Future<void> pumpButton(
      WidgetTester tester, {
      required VoidCallback onPressed,
      bool isLoading = false,
      double width = 320,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: PrimaryArrowButton(
                  label: 'Go',
                  onPressed: onPressed,
                  isLoading: isLoading,
                ),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('shows the label with a trailing arrow', (tester) async {
      await pumpButton(tester, onPressed: () {});

      expect(find.text('Go'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_forward_rounded), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(
        tester.getCenter(find.byIcon(Icons.arrow_forward_rounded)).dx,
        greaterThan(tester.getCenter(find.text('Go')).dx),
      );
    });

    testWidgets('calls onPressed when tapped', (tester) async {
      var taps = 0;
      await pumpButton(tester, onPressed: () => taps++);

      await tester.tap(find.byType(PrimaryArrowButton));
      expect(taps, 1);
    });

    group('while loading', () {
      testWidgets('replaces the arrow with a progress indicator', (
        tester,
      ) async {
        await pumpButton(tester, onPressed: () {}, isLoading: true);

        expect(find.text('Go'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.byIcon(Icons.arrow_forward_rounded), findsNothing);
      });

      testWidgets('ignores taps', (tester) async {
        var taps = 0;
        await pumpButton(tester, onPressed: () => taps++, isLoading: true);

        await tester.tap(find.byType(PrimaryArrowButton));
        expect(taps, 0);
      });

      testWidgets('keeps its size', (tester) async {
        await pumpButton(tester, onPressed: () {});
        final idle = tester.getSize(find.byType(FilledButton));

        await pumpButton(tester, onPressed: () {}, isLoading: true);
        expect(tester.getSize(find.byType(FilledButton)), idle);
      });

      testWidgets('is announced as a disabled button with its label', (
        tester,
      ) async {
        final handle = tester.ensureSemantics();
        await pumpButton(tester, onPressed: () {}, isLoading: true);

        expect(
          tester.getSemantics(find.byType(FilledButton)),
          // Has an enabled state that is off, i.e. disabled.
          matchesSemantics(label: 'Go', isButton: true, hasEnabledState: true),
        );
        handle.dispose();
      });
    });
  });
}
