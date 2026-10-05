
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

    try {
      await initialize();

      await _medicineSubscription?.cancel();

      _medicineSubscription = FirebaseFirestore.instance
          .collection('elders')
          .doc(elderId)
          .collection('medicines')
          .snapshots()
          .listen(
        (snapshot) async {
          try {
            await _syncMedicineNotifications(snapshot);
          } catch (error, stackTrace) {
            debugPrint(
              'CareCircle medicine scheduling error: $error',
            );
            debugPrintStack(stackTrace: stackTrace);
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint(
            'CareCircle medicine listener error: $error',
          );
          debugPrintStack(stackTrace: stackTrace);
        },
      );
    } catch (error, stackTrace) {
      debugPrint(
        'CareCircle notification initialization error: $error',
      );
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> stop() async {
    await _medicineSubscription?.cancel();
    _medicineSubscription = null;
  }

  Future<void> _syncMedicineNotifications(
    QuerySnapshot<Map<String, dynamic>> snapshot,
  ) async {
    final pending =
        await _notifications.pendingNotificationRequests();

    // Cancel existing CareCircle medicine reminders before rebuilding them.
    for (final notification in pending) {
      if (notification.id >= _notificationIdBase &&
          notification.id < _notificationIdBase + 1000000) {
        await _notifications.cancel(id: notification.id);
      }
    }

    // Schedule reminders for all medicines currently in Firestore.
    for (final document in snapshot.docs) {
      final data = document.data();

      final medicineName = data['name']?.toString().trim() ?? '';
      final dosage = data['dosage']?.toString().trim() ?? '';

      if (medicineName.isEmpty) continue;

      // Current medicine records use doseTimes.
      // Older records may still use time.
      final rawDoseTimes = data['doseTimes'];
      List<String> doseTimes = [];

      if (rawDoseTimes is List) {
        doseTimes = rawDoseTimes
            .map((value) => value.toString().trim())
            .where((value) => value.isNotEmpty)
            .toList();
      }

      if (doseTimes.isEmpty) {
        final oldTime = data['time']?.toString().trim() ?? '';

        if (oldTime.isNotEmpty) {
          doseTimes = [oldTime];
        }
      }

      // Create a separate reminder for every configured dose time.
      for (var doseIndex = 0;
          doseIndex < doseTimes.length;
          doseIndex++) {
        await _scheduleMedicine(
          medicineId: '${document.id}-dose-$doseIndex',
          medicineName: medicineName,
          dosage: dosage,
          medicineTime: doseTimes[doseIndex],
        );
      }
    }
  }

  Future<void> _scheduleMedicine({
    required String medicineId,
    required String medicineName,
    required String dosage,
    required String medicineTime,
  }) async {
    final parsedTime = _parseMedicineTime(medicineTime);

    if (parsedTime == null) {
      debugPrint(
        'CareCircle: Could not parse medicine time: $medicineTime',
      );
      return;
    }

    final now = tz.TZDateTime.now(tz.local);

    var medicineDateTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      parsedTime.hour,
      parsedTime.minute,
    );

    var reminderDateTime =
        medicineDateTime.subtract(const Duration(minutes: 5));

    // If today's reminder time has passed, schedule it for tomorrow.
    if (!reminderDateTime.isAfter(now)) {
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

    try {
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

      debugPrint(
        'CareCircle: Scheduled $medicineName ($medicineTime) '
        'for $reminderDateTime',
      );
    } catch (error, stackTrace) {
      debugPrint(
        'CareCircle: Failed to schedule $medicineName '
        '($medicineTime): $error',
      );
      debugPrintStack(stackTrace: stackTrace);
      rethrow;
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