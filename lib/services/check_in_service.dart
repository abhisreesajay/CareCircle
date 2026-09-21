import 'package:cloud_firestore/cloud_firestore.dart';

class CheckInService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // RECORD CHECK-IN
  // ============================================================

  Future<void> recordCheckIn({
    required String elderId,
    required String method,
    required String response,
    required String status,
  }) async {
    if (elderId.trim().isEmpty) {
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

    final doc = _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInHistory')
        .doc();

    await doc.set({
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

    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('status')
        .doc('current')
        .set({
      'checkInStatus': status,
      'lastCheckInAt':
          FieldValue.serverTimestamp(),
      'lastCheckInMethod': method,
    }, SetOptions(merge: true));

    await _firestore
        .collection('elders')
        .doc(elderId)
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
  }

  // ============================================================
  // CAREGIVER MANUAL CHECK-IN
  // ============================================================

  Future<void> markCheckedIn({
    required String elderId,
    required String checkInId,
  }) async {
    if (elderId.trim().isEmpty ||
        checkInId.trim().isEmpty) {
      throw Exception(
        'Elder ID and check-in ID are required.',
      );
    }

    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInHistory')
        .doc(checkInId)
        .update({
      'status': 'COMPLETED',
      'completedBy':
          'caregiver',
      'completedAt':
          FieldValue.serverTimestamp(),
    });

    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('status')
        .doc('current')
        .set({
      'checkInStatus': 'COMPLETED',
      'lastCheckInAt':
          FieldValue.serverTimestamp(),
      'lastCheckInMethod':
          'caregiver',
    }, SetOptions(merge: true));
  }
}