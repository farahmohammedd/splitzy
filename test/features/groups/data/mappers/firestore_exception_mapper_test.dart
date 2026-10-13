import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/exceptions.dart';
import 'package:splitzy/features/groups/data/exceptions/group_exceptions.dart';
import 'package:splitzy/features/groups/data/mappers/firestore_exception_mapper.dart';

FirebaseException _firestoreError(String code) =>
    FirebaseException(plugin: 'cloud_firestore', code: code);

void main() {
  group('mapFirestoreGroupException', () {
    test('an unreachable backend is a network error', () {
      expect(
        mapFirestoreGroupException(_firestoreError('unavailable')),
        isA<NetworkException>(),
      );
    });

    test('any other code is an unknown group error keeping the code', () {
      for (final code in ['permission-denied', 'not-found', 'internal']) {
        expect(
          mapFirestoreGroupException(_firestoreError(code)),
          isA<UnknownGroupException>().having((e) => e.code, 'code', code),
          reason: code,
        );
      }
    });
  });

  group('UnknownGroupException', () {
    test('is a project exception that shows its code when printed', () {
      const exception = UnknownGroupException('permission-denied');

      expect(exception, isA<AppException>());
      expect(exception.toString(), contains('permission-denied'));
    });
  });
}
