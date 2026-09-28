import 'package:cloud_firestore/cloud_firestore.dart';

class CareCircleModel {
  final String elderId;
  final List<String> caregiverIds;
  final DateTime? updatedAt;

  CareCircleModel({
    required this.elderId,
    required this.caregiverIds,
    this.updatedAt,
  });

  factory CareCircleModel.fromMap(Map<String, dynamic> map, String elderId) {
    return CareCircleModel(
      elderId: elderId,
      caregiverIds: List<String>.from(map['caregiverIds'] ?? []),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elderId': elderId,
      'caregiverIds': caregiverIds,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
