import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/failures.dart';

void main() {
  group('shared failures', () {
    test('NetworkFailure explains the connection problem', () {
      expect(
        const NetworkFailure().message,
        'No internet connection. Check your network and try again.',
      );
    });

    test('UnexpectedFailure has the generic message', () {
      expect(
        const UnexpectedFailure().message,
        'Something went wrong. Please try again.',
      );
    });

    test('failures can be thrown and caught as exceptions', () {
      expect(const NetworkFailure(), isA<Exception>());
      expect(const UnexpectedFailure(), isA<Exception>());
    });
  });

  group('messageFor', () {
    test("returns a Failure's own message", () {
      expect(
        messageFor(const NetworkFailure()),
        const NetworkFailure().message,
      );
    });

    test('returns the generic message for anything that is not a Failure', () {
      const generic = 'Something went wrong. Please try again.';

      expect(messageFor(Exception('socket closed')), generic);
      expect(messageFor(StateError('bad state')), generic);
      expect(messageFor('a plain string'), generic);
      expect(messageFor(null), generic);
    });

    test('never exposes the technical details of an unknown error', () {
      final message = messageFor(Exception('SQL timeout at host 10.0.0.1'));

      expect(message, isNot(contains('SQL')));
      expect(message, isNot(contains('10.0.0.1')));
    });
  });
}
