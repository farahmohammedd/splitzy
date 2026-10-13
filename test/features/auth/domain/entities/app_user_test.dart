import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/features/auth/domain/entities/app_user.dart';

void main() {
  group('AppUser', () {
    test('users with the same values are equal', () {
      const a = AppUser(id: 'u1', email: 'sam@example.com', displayName: 'Sam');
      const b = AppUser(id: 'u1', email: 'sam@example.com', displayName: 'Sam');

      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('users with different values are not equal', () {
      const a = AppUser(id: 'u1', email: 'sam@example.com');

      expect(a, isNot(const AppUser(id: 'u2', email: 'sam@example.com')));
      expect(a, isNot(a.copyWith(displayName: 'Sam')));
    });

    test('display name is optional', () {
      const user = AppUser(id: 'u1', email: 'sam@example.com');

      expect(user.displayName, isNull);
    });
  });

  group('AppUser.nameToShow', () {
    test('is the display name when one is saved', () {
      const user = AppUser(
        id: 'u1',
        email: 'sam@example.com',
        displayName: ' Sam Lee ',
      );

      expect(user.nameToShow, 'Sam Lee');
    });

    test('falls back to the email before @ when no name is saved', () {
      const user = AppUser(id: 'u1', email: 'sam.lee@example.com');

      expect(user.nameToShow, 'sam.lee');
    });

    test('falls back to the email when the saved name is blank', () {
      const user = AppUser(
        id: 'u1',
        email: 'sam@example.com',
        displayName: '   ',
      );

      expect(user.nameToShow, 'sam');
    });

    test('is the whole email when it has no @', () {
      const user = AppUser(id: 'u1', email: 'sam');

      expect(user.nameToShow, 'sam');
    });
  });
}
