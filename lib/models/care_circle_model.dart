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

  factory CareCircleModel.fromMap(
    Map<String, dynamic> map,
    String elderId,
  ) {
    return CareCircleModel(
      elderId: elderId.isNotEmpty
          ? elderId
          : map['elderId']?.toString() ?? '',
      caregiverIds: (map['caregiverIds'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],
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