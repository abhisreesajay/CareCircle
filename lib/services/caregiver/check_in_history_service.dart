
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
        .map((snapshot) {
      final history = snapshot.docs
          .map((doc) => CheckInHistory.fromMap(doc.id, doc.data()))
          .toList();

      // Sort by date, then scheduled slot, newest first.
      // This works with both legacy date-only IDs and new slot IDs.
      history.sort((a, b) {
        final dateComparison = b.date.compareTo(a.date);

        if (dateComparison != 0) {
          return dateComparison;
        }

        int slotOrder(String value) {
          final normalized = value.trim().toUpperCase();

          switch (normalized) {
            case '9:00 PM':
              return 21;
            case '2:00 PM':
              return 14;
            case '10:00 AM':
              return 10;
            default:
              return -1;
          }
        }

        return slotOrder(b.scheduledTime)
            .compareTo(slotOrder(a.scheduledTime));
      });

      return history;
    });
  }
}