import 'package:cloud_firestore/cloud_firestore.dart';

import 'caregiver/alert_service.dart';

class CheckInService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final AlertService _alertService =
      AlertService();

  // ============================================================
  // RECORD CHECK-IN
  // ============================================================

  Future<void> recordCheckIn({
    required String elderId,
    required String method,
    required String response,
    required String status,
  }) async {
    final String normalizedElderId =
        elderId.trim();

    if (normalizedElderId.isEmpty) {
      throw Exception(
        'Elder ID is required.',
      );
    }

    final DateTime now =
        DateTime.now();

    final String date =
        '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final String time =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    // ==========================================================
    // CREATE CHECK-IN RECORD
    // ==========================================================

    final DocumentReference<
        Map<String, dynamic>> checkInDocument =
        _firestore
            .collection('elders')
            .doc(normalizedElderId)
            .collection('checkInHistory')
            .doc();

    await checkInDocument.set({
      'date': date,
      'scheduledTime': time,
      'completedAt':
          FieldValue.serverTimestamp(),
      'status': status,
      'method': method,
      'response': response,
      'reminderStage': 0,
      'createdAt':
          FieldValue.serverTimestamp(),
    });

    // ==========================================================
    // UPDATE CURRENT ELDER STATUS
    // ==========================================================

    await _firestore
        .collection('elders')
        .doc(normalizedElderId)
        .collection('status')
        .doc('current')
        .set(
      {
        'checkInStatus': status,
        'lastCheckInAt':
            FieldValue.serverTimestamp(),
        'lastCheckInMethod': method,
      },
      SetOptions(
        merge: true,
      ),
    );

    // ==========================================================
    // ADD ACTIVITY HISTORY
    // ==========================================================

    await _firestore
        .collection('elders')
        .doc(normalizedElderId)
        .collection('activityHistory')
        .doc()
        .set({
      'type': 'checkin',
      'description':
          'Elder completed a check-in.',
      'method': method,
      'timestamp':
          FieldValue.serverTimestamp(),
    });

    // ==========================================================
    // CREATE MISSED CHECK-IN ALERT
    // ==========================================================

    if (status.trim().toUpperCase() ==
        'MISSED') {
      await _alertService.createAlert(
        elderId: normalizedElderId,
        title: 'Missed Check-in',
        message:
            'The elder missed the scheduled check-in.',
        type: 'checkin',
      );
    }
  }

  // ============================================================
  // CAREGIVER MANUAL CHECK-IN
  // ============================================================

  Future<void> markCheckedIn({
    required String elderId,
    required String checkInId,
  }) async {
    final String normalizedElderId =
        elderId.trim();

    final String normalizedCheckInId =
        checkInId.trim();

    if (normalizedElderId.isEmpty ||
        normalizedCheckInId.isEmpty) {
      throw Exception(
        'Elder ID and check-in ID are required.',
      );
    }

    // ==========================================================
    // UPDATE CHECK-IN
    // ==========================================================

    await _firestore
        .collection('elders')
        .doc(normalizedElderId)
        .collection('checkInHistory')
        .doc(normalizedCheckInId)
        .update({
      'status': 'COMPLETED',
      'completedBy': 'caregiver',
      'completedAt':
          FieldValue.serverTimestamp(),
    });

    // ==========================================================
    // UPDATE CURRENT ELDER STATUS
    // ==========================================================

    await _firestore
        .collection('elders')
        .doc(normalizedElderId)
        .collection('status')
        .doc('current')
        .set(
      {
        'checkInStatus': 'COMPLETED',
        'lastCheckInAt':
            FieldValue.serverTimestamp(),
        'lastCheckInMethod':
            'caregiver',
      },
      SetOptions(
        merge: true,
      ),
    );

    // ==========================================================
    // ADD ACTIVITY HISTORY
    // ==========================================================

    await _firestore
        .collection('elders')
        .doc(normalizedElderId)
        .collection('activityHistory')
        .doc()
        .set({
      'type': 'checkin',
      'description':
          'Caregiver manually completed the check-in.',
      'method': 'caregiver',
      'timestamp':
          FieldValue.serverTimestamp(),
    });
  }
}