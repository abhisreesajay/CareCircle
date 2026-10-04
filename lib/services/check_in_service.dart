import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Writes an elder check-in and the related status/activity documents.
///
/// Firestore paths used by this service:
/// elders/{elderId}/checkInHistory/{checkInId}
/// elders/{elderId}/status/current
/// elders/{elderId}/activityHistory/{activityId}
/// elders/{elderId}/alerts/{alertId} (only for HELP_REQUESTED or MISSED)
class CheckInService {
  CheckInService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}-'
        '${dateTime.month.toString().padLeft(2, '0')}-'
        '${dateTime.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatAlertDate(DateTime dateTime) {
    const months = <String>[
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dateTime.day.toString().padLeft(2, '0')} '
        '${months[dateTime.month - 1]} ${dateTime.year}, '
        '${_formatTime(dateTime)}';
  }

  Future<void> recordCheckIn({
    required String elderId,
    required String method,
    required String response,
    required String status,
  }) async {
    final normalizedElderId = elderId.trim();
    final normalizedMethod = method.trim();
    final normalizedResponse = response.trim();
    final normalizedStatus = status.trim().toUpperCase();

    if (normalizedElderId.isEmpty) {
      throw ArgumentError('Elder ID is required.');
    }
    if (normalizedMethod.isEmpty) {
      throw ArgumentError('Check-in method is required.');
    }
    if (normalizedStatus.isEmpty) {
      throw ArgumentError('Check-in status is required.');
    }

    // An elder may only submit a check-in for their own account.
    // Caregivers should use markCheckedIn() for an elder they are linked to.
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      throw StateError('You are signed out. Please log in again.');
    }
    if (currentUser.uid != normalizedElderId) {
      throw StateError(
        'The signed-in user does not match the elder for this check-in.',
      );
    }

    final now = DateTime.now();
    final elderRef = _firestore.collection('elders').doc(normalizedElderId);
    final checkInRef = elderRef.collection('checkInHistory').doc();
    final statusRef = elderRef.collection('status').doc('current');
    final activityRef = elderRef.collection('activityHistory').doc();

    final batch = _firestore.batch();

    batch.set(checkInRef, <String, dynamic>{
      'elderId': normalizedElderId,
      'date': _formatDate(now),
      'scheduledTime': _formatTime(now),
      'completedAt': FieldValue.serverTimestamp(),
      'status': normalizedStatus,
      'method': normalizedMethod,
      'response': normalizedResponse,
      'reminderStage': 0,
      'createdAt': FieldValue.serverTimestamp(),
    });

    batch.set(
      statusRef,
      <String, dynamic>{
        'elderId': normalizedElderId,
        'checkInStatus': normalizedStatus,
        'lastCheckInAt': FieldValue.serverTimestamp(),
        'lastCheckInMethod': normalizedMethod,
      },
      SetOptions(merge: true),
    );

    batch.set(activityRef, <String, dynamic>{
      'elderId': normalizedElderId,
      'type': 'checkin',
      'description': normalizedStatus == 'HELP_REQUESTED'
          ? 'Elder requested help during check-in.'
          : 'Elder completed a check-in.',
      'method': normalizedMethod,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Both missed check-ins and explicit help requests create caregiver alerts.
    // This alert is part of the same batch, so the user won't see a successful
    // check-in if its required alert write is rejected by Firestore rules.
    if (normalizedStatus == 'MISSED' ||
        normalizedStatus == 'HELP_REQUESTED') {
      final alertRef = elderRef.collection('alerts').doc();
      final isHelpRequest = normalizedStatus == 'HELP_REQUESTED';
      batch.set(alertRef, <String, dynamic>{
        'title': isHelpRequest ? 'Elder Needs Help' : 'Missed Check-in',
        'message': isHelpRequest
            ? 'The elder requested help during check-in.'
            : 'The elder missed the scheduled check-in.',
        'date': _formatAlertDate(now),
        'type': isHelpRequest ? 'help_request' : 'checkin',
        'elderId': normalizedElderId,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  /// Allows a linked caregiver to mark an existing history item complete.
  Future<void> markCheckedIn({
    required String elderId,
    required String checkInId,
  }) async {
    final normalizedElderId = elderId.trim();
    final normalizedCheckInId = checkInId.trim();

    if (normalizedElderId.isEmpty || normalizedCheckInId.isEmpty) {
      throw ArgumentError('Elder ID and check-in ID are required.');
    }

    final elderRef = _firestore.collection('elders').doc(normalizedElderId);
    final checkInRef =
        elderRef.collection('checkInHistory').doc(normalizedCheckInId);
    final statusRef = elderRef.collection('status').doc('current');
    final activityRef = elderRef.collection('activityHistory').doc();

    final batch = _firestore.batch();
    batch.update(checkInRef, <String, dynamic>{
      'status': 'COMPLETED',
      'completedBy': 'caregiver',
      'completedAt': FieldValue.serverTimestamp(),
    });
    batch.set(
      statusRef,
      <String, dynamic>{
        'elderId': normalizedElderId,
        'checkInStatus': 'COMPLETED',
        'lastCheckInAt': FieldValue.serverTimestamp(),
        'lastCheckInMethod': 'caregiver',
      },
      SetOptions(merge: true),
    );
    batch.set(activityRef, <String, dynamic>{
      'elderId': normalizedElderId,
      'type': 'checkin',
      'description': 'Caregiver manually completed the check-in.',
      'method': 'caregiver',
      'timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}
