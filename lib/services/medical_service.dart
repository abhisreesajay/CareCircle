import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ------------------------------------------------------------
  // SAVE MEDICAL INFORMATION
  // ------------------------------------------------------------
  //
  // Saves or updates medical information for one user.
  //
  // Document path:
  // medicalInformation/{elderId}
  //
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
    if (elderId.trim().isEmpty) {
      throw Exception(
        'Elder ID is required.',
      );
    }

    await _firestore
        .collection('medicalInformation')
        .doc(elderId)
        .set(
      {
        'elderId': elderId,
        'bloodGroup': bloodGroup.trim(),
        'allergies': allergies.trim(),
        'medicalConditions':
            medicalConditions.trim(),
        'medications': medications.trim(),
        'emergencyNotes':
            emergencyNotes.trim(),
        'doctorName':
            doctorName?.trim() ?? '',
        'doctorPhone':
            doctorPhone?.trim() ?? '',
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ------------------------------------------------------------
  // GET MEDICAL INFORMATION
  // ------------------------------------------------------------
  //
  // Retrieves medical information for one user.
  //
  Future<Map<String, dynamic>?> getMedicalInformation(
    String elderId,
  ) async {
    if (elderId.trim().isEmpty) {
      throw Exception(
        'Elder ID is required.',
      );
    }

    final DocumentSnapshot<
        Map<String, dynamic>> document =
        await _firestore
            .collection('medicalInformation')
            .doc(elderId)
            .get();

    if (!document.exists) {
      return null;
    }

    return document.data();
  }

  // ------------------------------------------------------------
  // DELETE MEDICAL INFORMATION
  // ------------------------------------------------------------
  //
  // Deletes medical information for one user.
  //
  Future<void> deleteMedicalInformation(
    String elderId,
  ) async {
    if (elderId.trim().isEmpty) {
      throw Exception(
        'Elder ID is required.',
      );
    }

    await _firestore
        .collection('medicalInformation')
        .doc(elderId)
        .delete();
  }
}