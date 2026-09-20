import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/medicine_model.dart';

class MedicineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addMedicine(String elderId, Medicine medicine) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicines')
        .doc(medicine.id)
        .set(medicine.toMap());
  }

  Future<void> updateMedicine(String elderId, Medicine medicine) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicines')
        .doc(medicine.id)
        .update(medicine.toMap());
  }

  Future<void> deleteMedicine(String elderId, String medicineId) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicines')
        .doc(medicineId)
        .delete();
  }

  Stream<List<Medicine>> getMedicines(String elderId) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicines')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => Medicine.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> acknowledgeMedicine(
    String elderId,
    String medicineId,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicines')
        .doc(medicineId)
        .update({
      'acknowledged': true,
    });
  }
}
