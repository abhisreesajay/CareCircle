import 'package:cloud_firestore/cloud_firestore.dart';

class CareAlert {
  final String id;
  final String title;
  final String message;
  final String date;
  final String type;
  final String status;
  final DateTime? createdAt;

  CareAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
    required this.status,
    this.createdAt,
  });

  /// Converts a Firestore document into a CareAlert.
  factory CareAlert.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    final dynamic timestamp = map['createdAt'];

    DateTime? createdAt;
    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    } else if (timestamp is DateTime) {
      createdAt = timestamp;
    }

    return CareAlert(
      id: id,
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      date: map['date']?.toString() ?? '',
      type: (map['type']?.toString() ?? '').trim().toLowerCase(),
      status: (map['status']?.toString() ?? 'unknown')
          .trim()
          .toLowerCase(),
      createdAt: createdAt,
    );
  }

  /// Normalized status for consistent comparisons.
  String get normalizedStatus => status.trim().toLowerCase();

  bool get isActive => normalizedStatus == 'active';

  bool get isResolved =>
      normalizedStatus == 'resolved' ||
      normalizedStatus == 'resolved_by_admin';

  bool get isCancelled =>
      normalizedStatus == 'cancelled' ||
      normalizedStatus == 'canceled';

  /// Only active alerts require attention.
  bool get needsAttention => isActive;
}