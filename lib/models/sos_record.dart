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
    return SosRecord(
      id: id,
      userId: map['userId'] ?? '',
      latitude: (map['latitude'] ?? 0).toDouble(),
      longitude: (map['longitude'] ?? 0).toDouble(),
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      status: map['status'] ?? 'UNKNOWN',
    );
  }
}