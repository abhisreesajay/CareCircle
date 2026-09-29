import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class MedicationNotificationService {
  MedicationNotificationService._();

  static final MedicationNotificationService instance =
      MedicationNotificationService._();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>?
      _medicineSubscription;

  static const String _channelId = 'medication_reminders';

  static const String _channelName = 'Medication Reminders';

  static const String _channelDescription =
      'Reminders for medicines scheduled by caregivers';

  static const int _notificationIdBase = 100000;

  bool _initialized = false;

  Future<void> initialize() async {
    // Notifications are only supported on Android in our project.
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );

    await _notifications.initialize(
      settings: initializationSettings,
    );

    final androidPlugin =
        _notifications.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();

    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.high,
    );

    await androidPlugin?.createNotificationChannel(channel);

    _initialized = true;
  }

  Future<void> startForElder(String elderId) async {
    // Do nothing on Windows/Web.
    if (defaultTargetPlatform != TargetPlatform.android) {
      return;
    }

    await initialize();

    await _medicineSubscription?.cancel();

    _medicineSubscription = FirebaseFirestore.instance
        .collection('elders')
        .doc(elderId)
        .collection('medicines')
        .snapshots()
        .listen(
      (snapshot) async {
        await _syncMedicineNotifications(snapshot);
      },
      onError: (error) {
        // Notification errors should not stop the Elder app.
      },
    );
  }

  Future<void> stop() async {
    await _medicineSubscription?.cancel();
    _medicineSubscription = null;
  }

  Future<void> _syncMedicineNotifications(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final pending = await _notifications.pendingNotificationRequests();

    // Remove previously scheduled CareCircle medicine reminders.
    for (final notification in pending) {
      if (notification.id >= _notificationIdBase &&
          notification.id < _notificationIdBase + 1000000) {
        await _notifications.cancel(
          id: notification.id,
        );
      }
    }

    // Schedule reminders for the medicines currently in Firestore.
    for (final document in snapshot.docs) {
      final data = document.data();

      final medicineName = data['name']?.toString() ?? '';
      final dosage = data['dosage']?.toString() ?? '';
      final medicineTime = data['time']?.toString() ?? '';
      final frequency = data['frequency']?.toString() ?? '';

      if (medicineName.isEmpty || medicineTime.isEmpty) {
        continue;
      }

      await _scheduleMedicine(
        medicineId: document.id,
        medicineName: medicineName,
        dosage: dosage,
        medicineTime: medicineTime,
        frequency: frequency,
      );
    }
  }

  Future<void> _scheduleMedicine({
    required String medicineId,
    required String medicineName,
    required String dosage,
    required String medicineTime,
    required String frequency,
  }) async {
    final parsedTime = _parseMedicineTime(medicineTime);

    if (parsedTime == null) return;

    final hour = parsedTime.hour;
    final minute = parsedTime.minute;

    final now = tz.TZDateTime.now(tz.local);

    var medicineDateTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    var reminderDateTime =
        medicineDateTime.subtract(const Duration(minutes: 5));

    // If today's reminder time has already passed,
    // schedule it for tomorrow.
    if (reminderDateTime.isBefore(now)) {
      medicineDateTime = medicineDateTime.add(
        const Duration(days: 1),
      );

      reminderDateTime =
          medicineDateTime.subtract(const Duration(minutes: 5));
    }

    final notificationId = _createNotificationId(medicineId);

    final notificationBody = dosage.isEmpty
        ? '$medicineName is due in 5 minutes.'
        : '$medicineName ($dosage) is due in 5 minutes.';

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    final isDaily = _isDailyFrequency(frequency);

    if (isDaily) {
      await _notifications.zonedSchedule(
        id: notificationId,
        title: 'Medication Reminder',
        body: notificationBody,
        scheduledDate: reminderDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode:
            AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        payload: medicineId,
      );
    } else {
      await _notifications.zonedSchedule(
        id: notificationId,
        title: 'Medication Reminder',
        body: notificationBody,
        scheduledDate: reminderDateTime,
        notificationDetails: notificationDetails,
        androidScheduleMode:
            AndroidScheduleMode.inexactAllowWhileIdle,
        payload: medicineId,
      );
    }
  }

  TimeOfDayValue? _parseMedicineTime(String medicineTime) {
    try {
      final parts = medicineTime.trim().split(RegExp(r'\s+'));

      if (parts.length != 2) return null;

      final timeParts = parts[0].split(':');

      if (timeParts.length != 2) return null;

      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);

      final period = parts[1].toUpperCase();

      if (hour < 1 || hour > 12) return null;

      if (minute < 0 || minute > 59) return null;

      if (period != 'AM' && period != 'PM') return null;

      if (period == 'PM' && hour != 12) {
        hour += 12;
      }

      if (period == 'AM' && hour == 12) {
        hour = 0;
      }

      return TimeOfDayValue(
        hour: hour,
        minute: minute,
      );
    } catch (_) {
      return null;
    }
  }

  bool _isDailyFrequency(String frequency) {
    final value = frequency.trim().toLowerCase();

    return value == 'daily' ||
        value == 'every day' ||
        value == 'everyday';
  }

  int _createNotificationId(String medicineId) {
    int hash = 2166136261;

    for (final character in medicineId.codeUnits) {
      hash ^= character;
      hash = (hash * 16777619) & 0x7fffffff;
    }

    return _notificationIdBase + (hash % 1000000);
  }
}

class TimeOfDayValue {
  final int hour;
  final int minute;

  const TimeOfDayValue({
    required this.hour,
    required this.minute,
  });
}