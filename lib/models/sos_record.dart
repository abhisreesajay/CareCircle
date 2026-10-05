import 'package:cloud_firestore/cloud_firestore.dart';

class SosRecord {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String status;

  SosRecord({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
  });

  // Convert the record into Firestore-compatible data.
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }

  // Create a record from Firestore data.
  factory SosRecord.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return SosRecord(
      id: id,
      userId: map['userId']?.toString() ?? '',
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
      timestamp: _toDateTime(map['timestamp']) ?? DateTime.now(),
      status: map['status']?.toString() ?? 'UNKNOWN',
    );
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return 0.0;
  }

  static DateTime? _toDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }
}