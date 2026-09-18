import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'alert_service.dart';
import 'check_in_reminder_service.dart';

class CheckInReminderScheduler {
  final CheckInReminderService _reminderService =
      CheckInReminderService();

  final AlertService _alertService = AlertService();

  Timer? _firstReminderTimer;
  Timer? _secondReminderTimer;
  Timer? _caregiverTimer;

  void scheduleReminder({
    required String elderId,
    required String reminderId,
    required Duration delay,
  }) {
    _cancelTimers();

    _firstReminderTimer = Timer(delay, () async {
      await _reminderService.markFirstReminderSent(
        elderId,
        reminderId,
      );
    });

    _secondReminderTimer = Timer(
      delay + const Duration(minutes: 15),
      () async {
        final completed = await _isCheckInCompleted(
          elderId,
          reminderId,
        );

        if (!completed) {
          await _reminderService.markSecondReminderSent(
            elderId,
            reminderId,
          );
        }
      },
    );

    _caregiverTimer = Timer(
      delay + const Duration(minutes: 30),
      () async {
        final completed = await _isCheckInCompleted(
          elderId,
          reminderId,
        );

        if (!completed) {
          await _alertService.createCaregiverAlert(
            elderId: elderId,
            title: 'Missed Check-in',
            message:
                'The elder has not completed the scheduled check-in.',
            type: 'CHECK_IN_MISSED',
          );

          await _reminderService.markCaregiverNotified(
            elderId,
            reminderId,
          );
        }
      },
    );
  }

  Future<bool> _isCheckInCompleted(
    String elderId,
    String reminderId,
  ) async {
    final reminder = await FirebaseFirestore.instance
        .collection('elders')
        .doc(elderId)
        .collection('checkInReminders')
        .doc(reminderId)
        .get();

    if (!reminder.exists) {
      return false;
    }

    final data = reminder.data();

    return data?['status'] == 'COMPLETED';
  }

  void cancelReminder() {
    _cancelTimers();
  }

  void _cancelTimers() {
    _firstReminderTimer?.cancel();
    _secondReminderTimer?.cancel();
    _caregiverTimer?.cancel();

    _firstReminderTimer = null;
    _secondReminderTimer = null;
    _caregiverTimer = null;
  }

  void dispose() {
    _cancelTimers();
  }
}