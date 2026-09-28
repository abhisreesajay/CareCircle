import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/medical_summary_model.dart';

class MedicalSummaryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ------------------------------------------------------------
  // REAL-TIME MEDICAL SUMMARY
  // ------------------------------------------------------------

  Stream<MedicalSummary?> getMedicalSummaryStream(
    String elderId,
  ) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicalSummary')
        .doc('summary')
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

  // ------------------------------------------------------------
  // SAVE MEDICAL SUMMARY
  // ------------------------------------------------------------

  Future<void> saveMedicalSummary(
    String elderId,
    MedicalSummary summary,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicalSummary')
        .doc('summary')
        .set(summary.toMap());
  }

  // ------------------------------------------------------------
  // UPDATE MEDICAL SUMMARY
  // ------------------------------------------------------------

  Future<void> updateMedicalSummary(
    String elderId,
    MedicalSummary summary,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicalSummary')
        .doc('summary')
        .update(summary.toMap());
  }
}