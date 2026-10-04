import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/alert_model.dart';

class AlertService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // GET ALERTS
  // ============================================================

  Stream<List<CareAlert>> getAlerts(String elderId) {
    final String normalizedElderId = elderId.trim();

    if (normalizedElderId.isEmpty) {
      return Stream.value(<CareAlert>[]);
    }

    return _firestore
        .collection('elders')
        .doc(normalizedElderId)
        .collection('alerts')
        .snapshots()
        .map((snapshot) {
      final documents = snapshot.docs.toList();

      // Sort newest alerts first.
      documents.sort((a, b) {
        final DateTime? aDate =
            _timestampToDateTime(a.data()['createdAt']);

        final DateTime? bDate =
            _timestampToDateTime(b.data()['createdAt']);

        if (aDate == null && bDate == null) {
          return 0;
        }

        if (aDate == null) {
          return 1;
        }

        if (bDate == null) {
          return -1;
        }

        return bDate.compareTo(aDate);
      });

      return documents
          .map(
            (doc) => CareAlert.fromMap(
              doc.id,
              doc.data(),
            ),
          )
          .toList();
    });
  }

  // ============================================================
  // CREATE ALERT
  // ============================================================

  Future<void> createAlert({
    required String elderId,
    required String title,
    required String message,
    required String type,
  }) async {
    final String normalizedElderId = elderId.trim();
    final String normalizedTitle = title.trim();
    final String normalizedMessage = message.trim();
    final String normalizedType = type.trim();

    if (normalizedElderId.isEmpty) {
      throw Exception(
        'Elder ID is required to create an alert.',
      );
    }

    if (normalizedTitle.isEmpty) {
      throw Exception(
        'Alert title is required.',
      );
    }

    if (normalizedMessage.isEmpty) {
      throw Exception(
        'Alert message is required.',
      );
    }

    if (normalizedType.isEmpty) {
      throw Exception(
        'Alert type is required.',
      );
    }

    final DateTime now = DateTime.now();

    final String formattedDate =
        '${now.day.toString().padLeft(2, '0')} '
        '${_monthName(now.month)} '
        '${now.year}, '
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    final DocumentReference<Map<String, dynamic>>
        alertDocument = _firestore
            .collection('elders')
            .doc(normalizedElderId)
            .collection('alerts')
            .doc();

    await alertDocument.set({
      'title': normalizedTitle,
      'message': normalizedMessage,
      'date': formattedDate,
      'type': normalizedType,
      'elderId': normalizedElderId,

      // Must match the Admin query:
      // where('status', isEqualTo: 'active')
      'status': 'active',

      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // DELETE ALERT
  // ============================================================

  Future<void> deleteAlert({
    required String elderId,
    required String alertId,
  }) async {
    final String normalizedElderId = elderId.trim();
    final String normalizedAlertId = alertId.trim();

    if (normalizedElderId.isEmpty) {
      throw Exception(
        'Elder ID is required.',
      );
    }

    if (normalizedAlertId.isEmpty) {
      throw Exception(
        'Alert ID is required.',
      );
    }

    await _firestore
        .collection('elders')
        .doc(normalizedElderId)
        .collection('alerts')
        .doc(normalizedAlertId)
        .delete();
  }

  // ============================================================
  // TIMESTAMP CONVERSION
  // ============================================================

  DateTime? _timestampToDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is DateTime) {
      return value;
    }

    return null;
  }

  // ============================================================
  // MONTH NAME
  // ============================================================

  String _monthName(int month) {
    const List<String> months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return months[month - 1];
  }
}