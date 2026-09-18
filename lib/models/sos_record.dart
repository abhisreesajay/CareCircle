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

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
    };
  }

  factory SosRecord.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final timestampValue = map['timestamp'];

    DateTime timestamp;

    if (timestampValue is Timestamp) {
      timestamp = timestampValue.toDate();
    } else if (timestampValue is DateTime) {
      timestamp = timestampValue;
    } else {
      timestamp = DateTime.now();
    }

    return SosRecord(
      id: id,
      userId: map['userId']?.toString() ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp: timestamp,
      status: map['status']?.toString() ?? 'UNKNOWN',
    );
  }
}