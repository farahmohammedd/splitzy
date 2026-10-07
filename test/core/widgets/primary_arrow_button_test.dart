import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/core/widgets/primary_arrow_button.dart';

void main() {
  group('PrimaryArrowButton', () {
    Future<void> pumpButton(
      WidgetTester tester, {
      required VoidCallback onPressed,
      double width = 320,
    }) {
      return tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                child: PrimaryArrowButton(label: 'Go', onPressed: onPressed),
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
  });
}
