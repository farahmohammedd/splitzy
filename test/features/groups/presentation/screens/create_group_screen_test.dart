import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/theme/app_theme.dart';
import 'package:splitzy/features/groups/presentation/screens/create_group_screen.dart';

final _nameField = find.widgetWithText(TextField, 'e.g. Trip to Dahab');
final _memberField = find.widgetWithText(TextField, 'Enter member name');
final _addMember = find.byTooltip('Add member');

/// The Create Group button (the title has the same text).
final _create = find.widgetWithText(FilledButton, 'Create Group');

/// Records which callbacks the screen invoked.
class _Calls {
  int back = 0;
  final creates = <(String, List<String>)>[];
}

Future<_Calls> _pumpScreen(
  WidgetTester tester, {
  bool isSubmitting = false,
  String? errorMessage,
}) async {
  final calls = _Calls();
  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: CreateGroupScreen(
        ownerName: 'Farah',
        onBack: () => calls.back++,
        onCreate: (name, members) => calls.creates.add((name, members)),
        isSubmitting: isSubmitting,
        errorMessage: errorMessage,
      ),
    ),
  );
  return calls;
}

Future<void> _add(WidgetTester tester, String name) async {
  await tester.enterText(_memberField, name);
  await tester.tap(_addMember);
  await tester.pump();
}

Future<void> _tapCreate(WidgetTester tester) async {
  await tester.ensureVisible(_create);
  await tester.tap(_create);
  await tester.pump();
}

void main() {
  group('CreateGroupScreen', () {
    testWidgets('says the owner is included and starts with no members', (
      tester,
    ) async {
      await _pumpScreen(tester);

      expect(find.text("You're included automatically."), findsOneWidget);
      expect(find.text('0 added'), findsOneWidget);
    });

    testWidgets('adds a trimmed member and clears the field', (tester) async {
      await _pumpScreen(tester);

      await _add(tester, '  Sara ');

      expect(find.text('Sara'), findsOneWidget);
      expect(find.text('1 added'), findsOneWidget);
      expect(tester.widget<TextField>(_memberField).controller?.text, isEmpty);
    });

    testWidgets('adds a member from the keyboard Done action', (tester) async {
      await _pumpScreen(tester);

      await tester.enterText(_memberField, 'Mona');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(find.text('Mona'), findsOneWidget);
    });

    testWidgets('ignores an empty member name', (tester) async {
      await _pumpScreen(tester);

      await _add(tester, '   ');

      expect(find.text('0 added'), findsOneWidget);
    });

    testWidgets('rejects a duplicate name, the owner included', (tester) async {
      await _pumpScreen(tester);
      await _add(tester, 'Sara');

      await _add(tester, 'sara');
      expect(find.text('Each member needs a different name.'), findsOneWidget);
      expect(find.text('1 added'), findsOneWidget);

      await _add(tester, 'FARAH');
      expect(find.text('Each member needs a different name.'), findsOneWidget);
      expect(find.text('1 added'), findsOneWidget);
    });

    testWidgets('removes a member', (tester) async {
      await _pumpScreen(tester);
      await _add(tester, 'Sara');
      await _add(tester, 'Mona');

      await tester.tap(find.byTooltip('Remove Sara'));
      await tester.pump();

      expect(find.text('Sara'), findsNothing);
      expect(find.text('Mona'), findsOneWidget);
      expect(find.text('1 added'), findsOneWidget);
    });

    testWidgets('creates with the trimmed name and members in order', (
      tester,
    ) async {
      final calls = await _pumpScreen(tester);
      await tester.enterText(_nameField, '  Trip to Dahab ');
      await _add(tester, 'Sara');
      await _add(tester, 'Mona');

      await _tapCreate(tester);

      final (name, members) = calls.creates.single;
      expect(name, 'Trip to Dahab');
      expect(members, ['Sara', 'Mona']);
    });

    testWidgets('a name left in the member field is added on create', (
      tester,
    ) async {
      final calls = await _pumpScreen(tester);
      await tester.enterText(_nameField, 'Trip');
      await tester.enterText(_memberField, 'Sara');

      await _tapCreate(tester);

      expect(calls.creates.single.$2, ['Sara']);
    });

    testWidgets('requires a group name and another member', (tester) async {
      final calls = await _pumpScreen(tester);

      await _tapCreate(tester);

      expect(find.text('Enter a group name.'), findsOneWidget);
      expect(find.text('Add at least one other member.'), findsOneWidget);
      expect(calls.creates, isEmpty);
    });

    testWidgets('while creating, shows progress and ignores submits', (
      tester,
    ) async {
      final calls = await _pumpScreen(tester, isSubmitting: true);
      await tester.enterText(_nameField, 'Trip');
      await _add(tester, 'Sara');

      await tester.ensureVisible(_create);
      await tester.tap(_create, warnIfMissed: false);
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(calls.creates, isEmpty);
    });

    testWidgets('shows a failed attempt above the button', (tester) async {
      await _pumpScreen(
        tester,
        errorMessage:
            'No internet connection. Check your network and try '
            'again.',
      );

      expect(
        find.text('No internet connection. Check your network and try again.'),
        findsOneWidget,
      );
    });

    testWidgets('reports Back', (tester) async {
      final calls = await _pumpScreen(tester);

      await tester.tap(find.byTooltip('Back'));

      expect(calls.back, 1);
    });

    for (final (name, size, textScale) in [
      ('a small phone', const Size(320, 568), 1.0),
      ('a phone', const Size(390, 844), 1.0),
      ('a tablet landscape', const Size(1024, 768), 1.0),
      ('a small phone with 2x text scaling', const Size(320, 568), 2.0),
    ]) {
      testWidgets('lays out without overflow and keeps Create Group '
          'reachable on $name', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        tester.platformDispatcher.textScaleFactorTestValue = textScale;
        addTearDown(tester.view.reset);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

        final calls = await _pumpScreen(tester);
        await tester.enterText(_nameField, 'Trip');
        for (final member in ['Sara', 'Mona', 'Nour', 'Omar']) {
          await tester.ensureVisible(_memberField);
          await _add(tester, member);
        }
        await _tapCreate(tester);

        expect(tester.takeException(), isNull);
        expect(calls.creates.single.$2, ['Sara', 'Mona', 'Nour', 'Omar']);
      });
    }
  });
}
