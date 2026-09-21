```dart
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/alert_model.dart';

class AlertService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<List<CareAlert>> getAlerts(String elderId) {
    if (elderId.trim().isEmpty) {
      return Stream.value(<CareAlert>[]);
    }

    return _firestore
        .collection('sosAlerts')
        .where('userId', isEqualTo: elderId)
        .where('status', isEqualTo: 'ACTIVE')
        .snapshots()
        .map((snapshot) {
      final List<CareAlert> alerts = [];

      for (final doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data();

        final dynamic latitude = data['latitude'];
        final dynamic longitude = data['longitude'];

        String locationText = 'Location unavailable';

        if (latitude != null && longitude != null) {
          locationText =
              '${latitude.toString()}, ${longitude.toString()}';
        }

        String dateText = 'Time unavailable';

        final dynamic createdAt = data['createdAt'];
        final dynamic timestamp = data['timestamp'];

        if (createdAt is Timestamp) {
          dateText = createdAt.toDate().toString();
        } else if (timestamp is Timestamp) {
          dateText = timestamp.toDate().toString();
        } else if (timestamp is DateTime) {
          dateText = timestamp.toString();
        }

        alerts.add(
          CareAlert(
            id: doc.id,
            title: 'SOS ACTIVE',
            message:
                'Emergency SOS received.\n'
                'Location: $locationText',
            date: dateText,
            type: 'sos',
          ),
        );
      }

      return alerts;
    });
  }
}
```
