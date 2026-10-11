import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/error/exceptions.dart';

void main() {
  group('AppException', () {
    test('NetworkException is a project exception that can be thrown', () {
      expect(const NetworkException(), isA<AppException>());
      expect(const NetworkException(), isA<Exception>());
    });
  });
}
