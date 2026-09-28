<<<<<<< HEAD
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
=======
class CareCircle {
  final String elderId;
  final List<String> caregiverIds;

  CareCircle({
    required this.elderId,
    required this.caregiverIds,
  });

  factory CareCircle.fromMap(
    Map<String, dynamic> map,
  ) {
    return CareCircle(
      elderId:
          map['elderId']?.toString() ?? '',
      caregiverIds:
          (map['caregiverIds']
                      as List<dynamic>?)
                  ?.map(
                    (item) =>
                        item.toString(),
                  )
                  .toList() ??
              const [],
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elderId': elderId,
<<<<<<< HEAD
      'caregiverIds': caregiverIds,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
=======
      'caregiverIds':
          caregiverIds,
    };
  }
}
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
