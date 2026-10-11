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
}
