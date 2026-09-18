import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/alert_model.dart';

class AlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<CareAlert>> getAlerts(String elderId) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('alerts')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => CareAlert.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<void> createCaregiverAlert({
    required String elderId,
    required String title,
    required String message,
    required String type,
  }) async {
    final now = DateTime.now();

    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('alerts')
        .add({
      'title': title,
      'message': message,
      'date': now.toIso8601String(),
      'type': type,
    });
  }
}