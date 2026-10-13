import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:splitzy/core/firestore/timestamp_converter.dart';

final _created = DateTime.utc(2026, 10, 12, 9, 30);

void main() {
  group('TimestampConverter', () {
    const converter = TimestampConverter();

    test('converts a Timestamp to a DateTime and back', () {
      final timestamp = Timestamp.fromDate(_created);

      expect(converter.fromJson(timestamp)?.isAtSameMomentAs(_created), isTrue);
      expect(converter.toJson(_created), timestamp);
    });

    test('keeps null as null', () {
      expect(converter.fromJson(null), isNull);
      expect(converter.toJson(null), isNull);
    });
  });
}
