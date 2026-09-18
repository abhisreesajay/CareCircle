import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/check_in_reminder_model.dart';

class CheckInReminderService {
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
    });
  }

  Future<String?> getPendingReminderId(String elderId) async {
    final snapshot = await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInReminders')
        .where('status', isEqualTo: 'PENDING')
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.id;
  }
}