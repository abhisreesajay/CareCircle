import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/check_in_reminder_model.dart';

class CheckInReminderService {
<<<<<<< HEAD
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Stream<List<CheckInReminder>> getReminders(
    String elderId,
  ) {
=======
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createReminder({
    required String elderId,
    required String scheduledTime,
  }) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInReminders')
        .add({
      'elderId': elderId,
      'scheduledTime': scheduledTime,
      'status': 'PENDING',
      'firstReminderSent': false,
      'secondReminderSent': false,
      'caregiverNotified': false,
    });
  }

  Stream<List<CheckInReminder>> getReminders(String elderId) {
>>>>>>> develop
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInReminders')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => CheckInReminder.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> markFirstReminderSent(
    String elderId,
    String reminderId,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInReminders')
        .doc(reminderId)
        .update({
      'firstReminderSent': true,
    });
  }

  Future<void> markSecondReminderSent(
    String elderId,
    String reminderId,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInReminders')
        .doc(reminderId)
        .update({
      'secondReminderSent': true,
    });
  }

  Future<void> markCaregiverNotified(
    String elderId,
    String reminderId,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInReminders')
        .doc(reminderId)
        .update({
      'caregiverNotified': true,
    });
  }

  Future<void> completeReminder({
    required String elderId,
    required String reminderId,
  }) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInReminders')
        .doc(reminderId)
        .update({
      'status': 'COMPLETED',
<<<<<<< HEAD
      'completedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> getCurrentPendingReminderId(
    String elderId,
  ) async {
    final now = DateTime.now();

    String? scheduledTime;

    if (now.hour >= 10 && now.hour < 14) {
      scheduledTime = '10:00 AM';
    } else if (now.hour >= 14 && now.hour < 21) {
      scheduledTime = '2:00 PM';
    } else if (now.hour >= 21) {
      scheduledTime = '9:00 PM';
    }

    if (scheduledTime == null) {
      return null;
    }

    final today =
        '${now.year}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

=======
    });
  }

  Future<String?> getPendingReminderId(String elderId) async {
>>>>>>> develop
    final snapshot = await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInReminders')
<<<<<<< HEAD
        .where(
          'scheduledDate',
          isEqualTo: today,
        )
        .where(
          'scheduledTime',
          isEqualTo: scheduledTime,
        )
        .where(
          'status',
          isEqualTo: 'PENDING',
        )
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.id;
  }

  Future<String?> getPendingReminderId(
    String elderId,
  ) async {
    final snapshot = await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInReminders')
        .where(
          'status',
          isEqualTo: 'PENDING',
        )
=======
        .where('status', isEqualTo: 'PENDING')
>>>>>>> develop
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.id;
  }
}