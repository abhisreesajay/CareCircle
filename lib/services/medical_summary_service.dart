import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/medical_summary_model.dart';

class MedicalSummaryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<MedicalSummary?> getMedicalSummary(String elderId) async {
    final doc = await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicalSummary')
        .doc('summary')
        .get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    return MedicalSummary.fromMap(doc.data()!);
  }

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