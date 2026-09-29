import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/medicine_model.dart';

class MedicineService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  CollectionReference<
      Map<String, dynamic>> _medicineCollection(
    String elderId,
  ) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicines');
  }

  Future<void> addMedicine(
    String elderId,
    Medicine medicine,
  ) async {
    await _medicineCollection(elderId)
        .doc(medicine.id)
        .set(
      medicine.toMap(),
    );
  }

  Future<void> updateMedicine(
    String elderId,
    Medicine medicine,
  ) async {
    await _medicineCollection(elderId)
        .doc(medicine.id)
        .update(
      medicine.toMap(),
    );
  }

  Future<void> deleteMedicine(
    String elderId,
    String medicineId,
  ) async {
    await _medicineCollection(elderId)
        .doc(medicineId)
        .delete();
  }

  Stream<List<Medicine>> getMedicines(
    String elderId,
  ) {
    return _medicineCollection(elderId)
        .snapshots()
        .map(
      (snapshot) {
        final medicines = snapshot.docs
            .map(
              (doc) => Medicine.fromMap(
                doc.id,
                doc.data(),
              ),
            )
            .toList();

        medicines.sort(
          (a, b) {
            final aTime =
                a.doseTimes.isNotEmpty
                    ? a.doseTimes.first
                    : '';

            final bTime =
                b.doseTimes.isNotEmpty
                    ? b.doseTimes.first
                    : '';

            return aTime.compareTo(
              bTime,
            );
          },
        );

        return medicines;
      },
    );
  }

  Future<void> acknowledgeMedicineDose(
    String elderId,
    String medicineId,
    int doseIndex,
  ) async {
    final medicineRef =
        _medicineCollection(elderId)
            .doc(medicineId);

    final snapshot =
        await medicineRef.get();

    if (!snapshot.exists) {
      throw Exception(
        'Medicine no longer exists.',
      );
    }

    final data =
        snapshot.data() ??
            <String, dynamic>{};

    final medicine =
        Medicine.fromMap(
      medicineId,
      data,
    );

    final now = DateTime.now();

    final today =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final updatedTakenDoses =
        <String, List<int>>{};

    medicine.takenDoses.forEach(
      (date, doses) {
        updatedTakenDoses[date] =
            List<int>.from(doses);
      },
    );

    final todayDoses =
        List<int>.from(
      updatedTakenDoses[today] ??
          <int>[],
    );

    if (!todayDoses.contains(
      doseIndex,
    )) {
      todayDoses.add(
        doseIndex,
      );
    }

    updatedTakenDoses[today] =
        todayDoses;

    await medicineRef.update({
      'takenDoses': updatedTakenDoses,
    });
  }

  Future<void> undoMedicineDose(
    String elderId,
    String medicineId,
    int doseIndex,
  ) async {
    final medicineRef =
        _medicineCollection(elderId)
            .doc(medicineId);

    final snapshot =
        await medicineRef.get();

    if (!snapshot.exists) {
      throw Exception(
        'Medicine no longer exists.',
      );
    }

    final data =
        snapshot.data() ??
            <String, dynamic>{};

    final medicine =
        Medicine.fromMap(
      medicineId,
      data,
    );

    final now = DateTime.now();

    final today =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final updatedTakenDoses =
        <String, List<int>>{};

    medicine.takenDoses.forEach(
      (date, doses) {
        updatedTakenDoses[date] =
            List<int>.from(doses);
      },
    );

    final todayDoses =
        List<int>.from(
      updatedTakenDoses[today] ??
          <int>[],
    );

    todayDoses.remove(
      doseIndex,
    );

    if (todayDoses.isEmpty) {
      updatedTakenDoses.remove(
        today,
      );
    } else {
      updatedTakenDoses[today] =
          todayDoses;
    }

    await medicineRef.update({
      'takenDoses': updatedTakenDoses,
    });
  }

  /*
   * Kept for compatibility with any existing
   * code that still calls acknowledgeMedicine().
   *
   * It marks the first dose as taken.
   */
  Future<void> acknowledgeMedicine(
    String elderId,
    String medicineId,
  ) async {
    await acknowledgeMedicineDose(
      elderId,
      medicineId,
      0,
    );
  }
}