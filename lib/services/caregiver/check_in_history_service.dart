import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/check_in_history_model.dart';

class CheckInHistoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CheckInHistory>> getCheckInHistory(String elderId) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInHistory')
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
