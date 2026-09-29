import 'package:cloud_firestore/cloud_firestore.dart';

class SOSAlertModel {
  final String id;
  final String userId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final String status;
  final DateTime? createdAt;
  final DateTime? cancelledAt;
  final Map<String, dynamic> medicalInformation;

  const SOSAlertModel({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.status,
    this.createdAt,
    this.cancelledAt,
    this.medicalInformation = const {},
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': Timestamp.fromDate(timestamp),
      'status': status,
      'createdAt': createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(createdAt!),
      'cancelledAt': cancelledAt == null
          ? null
          : Timestamp.fromDate(cancelledAt!),
      'medicalInformation': medicalInformation,
    };
  }

  factory SOSAlertModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return SOSAlertModel(
      id: id,
      userId: map['userId']?.toString() ?? '',
      latitude:
          (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude:
          (map['longitude'] as num?)?.toDouble() ?? 0.0,
      timestamp:
          _timestampToDateTime(map['timestamp']) ??
              DateTime.now(),
      status:
          map['status']?.toString() ?? 'UNKNOWN',
      createdAt:
          _timestampToDateTime(map['createdAt']),
      cancelledAt:
          _timestampToDateTime(map['cancelledAt']),
      medicalInformation:
          map['medicalInformation']
                  is Map<String, dynamic>
              ? Map<String, dynamic>.from(
                  map['medicalInformation']
                      as Map<String, dynamic>,
                )
              : const {},
    );
  }

  static DateTime? _timestampToDateTime(
    dynamic value,
  ) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  SOSAlertModel copyWith({
    String? id,
    String? userId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    String? status,
    DateTime? createdAt,
    DateTime? cancelledAt,
    Map<String, dynamic>? medicalInformation,
  }) {
    return SOSAlertModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      cancelledAt: cancelledAt ?? this.cancelledAt,
      medicalInformation:
          medicalInformation ??
              this.medicalInformation,
    );
  }
}