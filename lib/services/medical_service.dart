import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalService {
  MedicalService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>>
      get _medicalInformation =>
          _firestore.collection('medicalInformation');

  String _validateElderId(String elderId) {
    final normalizedId = elderId.trim();

    if (normalizedId.isEmpty) {
      throw ArgumentError('Elder ID is required.');
    }

    return normalizedId;
  }

  /// Saves or updates an elder's medical information.
  Future<void> saveMedicalInformation({
    required String elderId,
    required String bloodGroup,
    required String allergies,
    required String medicalConditions,
    required String medications,
    required String emergencyNotes,
    String? doctorName,
    String? doctorPhone,
  }) async {
    final normalizedElderId = _validateElderId(elderId);

    await _medicalInformation.doc(normalizedElderId).set(
      {
        'elderId': normalizedElderId,
        'bloodGroup': bloodGroup.trim(),
        'allergies': allergies.trim(),
        'medicalConditions': medicalConditions.trim(),
        'medications': medications.trim(),
        'emergencyNotes': emergencyNotes.trim(),
        'doctorName': doctorName?.trim() ?? '',
        'doctorPhone': doctorPhone?.trim() ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  /// Retrieves an elder's medical information.
  /// Returns null if no document exists.
  Future<Map<String, dynamic>?> getMedicalInformation(
    String elderId,
  ) async {
    final normalizedElderId = _validateElderId(elderId);

    final document =
        await _medicalInformation.doc(normalizedElderId).get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }

  /// Deletes an elder's medical information.
  Future<void> deleteMedicalInformation(String elderId) async {
    final normalizedElderId = _validateElderId(elderId);

    await _medicalInformation.doc(normalizedElderId).delete();
  }
}