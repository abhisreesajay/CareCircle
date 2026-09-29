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

  factory CareAlert.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    DateTime? createdAt;

    final dynamic timestamp =
        map['createdAt'];

    if (timestamp is Timestamp) {
      createdAt = timestamp.toDate();
    }

    return CareAlert(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      date: map['date'] ?? '',
      type: map['type'] ?? '',
      status: map['status'] ?? 'ACTIVE',
      createdAt: createdAt,
    );
  }
}