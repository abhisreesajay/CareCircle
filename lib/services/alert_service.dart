import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/alert_model.dart';

class AlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CareAlert>> getAlerts(String elderId) {
    return _firestore
        .collection('sosRecords')
        .where('userId', isEqualTo: elderId)
        .where('status', isEqualTo: 'ACTIVE')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();

        final latitude = data['latitude'] ?? 'Unknown';
        final longitude = data['longitude'] ?? 'Unknown';

        String dateText = '';

        final createdAt = data['createdAt'];

        if (createdAt is Timestamp) {
          dateText = createdAt.toDate().toString();
        } else if (data['timestamp'] is Timestamp) {
          dateText = data['timestamp'].toDate().toString();
        }

        return CareAlert(
          id: doc.id,
          title: 'SOS ACTIVE',
          message:
              'Emergency SOS received.\n'
              'Location: $latitude, $longitude',
          date: dateText,
          type: 'sos',
        );
      }).toList();
    });
  }
}