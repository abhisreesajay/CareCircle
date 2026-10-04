import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/check_in_history_model.dart';

class CheckInHistoryService {
  CheckInHistoryService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<CheckInHistory>> getCheckInHistory(String elderId) {
    final normalizedElderId = elderId.trim();
    if (normalizedElderId.isEmpty) {
      return Stream.value(const <CheckInHistory>[]);
    }

    return _firestore
        .collection('elders')
        .doc(normalizedElderId)
        .collection('checkInHistory')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CheckInHistory.fromMap(doc.id, doc.data()))
            .toList());
  }
}
