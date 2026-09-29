import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/activity_history_model.dart';

class ActivityHistoryService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<List<ActivityHistory>> getActivityHistory(
    String elderId,
  ) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('activityHistory')
        .orderBy(
          'timestamp',
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) {
            return snapshot.docs
                .map(
                  (doc) => ActivityHistory.fromMap(
                    doc.id,
                    doc.data(),
                  ),
                )
                .toList();
          },
        );
  }
}