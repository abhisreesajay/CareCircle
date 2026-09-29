import 'package:cloud_firestore/cloud_firestore.dart';

class MedicationReminderService {
  static const int reminderMinutesBefore = 5;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getMedicineReminders(
    String elderId,
  ) async {
    final snapshot = await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('medicines')
        .get();

    final reminders = <Map<String, dynamic>>[];

    for (final doc in snapshot.docs) {
      final data = doc.data();

      final medicineTime = data['time']?.toString() ?? '';

      final reminderTime = getReminderTime(medicineTime);

      if (reminderTime != null) {
        reminders.add({
          'id': doc.id,
          'name': data['name'] ?? '',
          'dosage': data['dosage'] ?? '',
          'time': medicineTime,
          'frequency': data['frequency'] ?? '',
          'reminderTime': reminderTime,
        });
      }
    }

    return reminders;
  }

  static DateTime? getReminderTime(String medicineTime) {
    try {
      final parts = medicineTime.trim().split(' ');

      if (parts.length != 2) {
        return null;
      }

      final timeParts = parts[0].split(':');

      if (timeParts.length != 2) {
        return null;
      }

      int hour = int.parse(timeParts[0]);
      final int minute = int.parse(timeParts[1]);

      final period = parts[1].toUpperCase();

      if (period == 'PM' && hour != 12) {
        hour += 12;
      }

      if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      final now = DateTime.now();

      final medicineDateTime = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      return medicineDateTime.subtract(
        const Duration(minutes: reminderMinutesBefore),
      );
    } catch (e) {
      return null;
    }
  }
}