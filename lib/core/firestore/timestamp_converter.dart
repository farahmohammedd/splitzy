import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

/// Converts Firestore's [Timestamp] to [DateTime] and back, for data-layer
/// DTOs. `null` stays `null` (a pending server timestamp reads as `null`).
///
/// Shared by every feature that stores dates in Firestore.
class TimestampConverter implements JsonConverter<DateTime?, Object?> {
  const TimestampConverter();

  @override
  DateTime? fromJson(Object? json) => (json as Timestamp?)?.toDate();

  @override
  Object? toJson(DateTime? date) =>
      date == null ? null : Timestamp.fromDate(date);
}
