import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/medical_summary_model.dart';

class MedicalSummaryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // MEDICAL SUMMARY REFERENCE
  // ============================================================

  DocumentReference<Map<String, dynamic>> _summaryReference(
    String elderId,
  ) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicalSummary')
        .doc('summary');
  }

  // ============================================================
  // REAL-TIME MEDICAL SUMMARY
  // ============================================================

  Stream<MedicalSummary?> getMedicalSummaryStream(
    String elderId,
  ) {
    return _summaryReference(elderId)
        .snapshots()
        .map((doc) {
      if (!doc.exists || doc.data() == null) {
        return null;
      }

      return MedicalSummary.fromMap(
        doc.data()!,
      );
    });
  }

  // ============================================================
  // GET MEDICAL SUMMARY ONCE
  // ============================================================

  Future<MedicalSummary?> getMedicalSummary(
    String elderId,
  ) async {
    final doc = await _summaryReference(elderId).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return MedicalSummary.fromMap(
      doc.data()!,
    );
  }

  // ============================================================
  // SAVE / UPDATE MEDICAL SUMMARY
  // ============================================================
  //
  // This method is intended to be called by the CAREGIVER.
  //
  // Firestore rules will enforce that the elder cannot write.
  //
  Future<void> saveMedicalSummary({
    required String elderId,
    required String bloodGroup,
    required String allergies,
    required String conditions,
    required String notes,
  }) async {
    if (elderId.trim().isEmpty) {
      throw Exception('Elder ID is required.');
    }

    await _summaryReference(elderId).set(
      {
        'bloodGroup': bloodGroup.trim(),
        'allergies': allergies.trim(),
        'conditions': conditions.trim(),
        'notes': notes.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // ============================================================
  // UPDATE MEDICAL SUMMARY
  // ============================================================

  Future<void> updateMedicalSummary({
    required String elderId,
    required String bloodGroup,
    required String allergies,
    required String conditions,
    required String notes,
  }) async {
    if (elderId.trim().isEmpty) {
      throw Exception('Elder ID is required.');
    }

    await _summaryReference(elderId).set(
      {
        'bloodGroup': bloodGroup.trim(),
        'allergies': allergies.trim(),
        'conditions': conditions.trim(),
        'notes': notes.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}