import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/check_in_history_model.dart';

class CheckInHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveCheckIn({
    required String elderId,
    required String status,
  }) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInHistory')
        .add({
      'date': DateTime.now().toIso8601String().split('T')[0],
      'scheduledTime': DateTime.now().toIso8601String(),
      'status': status,
    });
  }

  Stream<List<CheckInHistory>> getCheckInHistory(String elderId) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInHistory')
        .orderBy('scheduledTime', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CheckInHistory.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }
}