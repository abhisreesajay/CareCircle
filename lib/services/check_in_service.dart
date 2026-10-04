
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;

/// Records elder check-ins and updates related status/activity documents.
///
/// Firestore paths:
/// elders/{elderId}/checkInHistory/{checkInId}
/// elders/{elderId}/checkInReminders/{reminderId}
/// elders/{elderId}/status/current
/// elders/{elderId}/activityHistory/{activityId}
/// elders/{elderId}/alerts/{alertId}
class CheckInService {
  CheckInService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  static const String _timezoneName = 'Asia/Kolkata';

  static const List<_CheckInSlot> _slots = <_CheckInSlot>[
    _CheckInSlot(hour: 10, minute: 0, label: '10:00 AM'),
    _CheckInSlot(hour: 14, minute: 0, label: '2:00 PM'),
    _CheckInSlot(hour: 21, minute: 0, label: '9:00 PM'),
  ];

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

  /// Scheduler reminder IDs use this exact format:
  /// YYYY-MM-DD_10-00, YYYY-MM-DD_14-00, YYYY-MM-DD_21-00.
  String _reminderId(String date, _CheckInSlot slot) {
    return '${date}_'
        '${slot.hour.toString().padLeft(2, '0')}-'
        '${slot.minute.toString().padLeft(2, '0')}';
  }

  tz.TZDateTime _nowInIndia() {
    return tz.TZDateTime.now(tz.getLocation(_timezoneName));
  }

  /// Finds the most recent scheduled slot that is not already completed.
  ///
  /// A late check-in may complete an earlier outstanding slot.
  /// Before 10 AM, the first slot is eligible.
  ///
  /// A future slot is never selected merely because all earlier slots
  /// have been completed.
  Future<_CheckInSlot> _findSlot({
    required String elderId,
    required String date,
    required tz.TZDateTime now,
  }) async {
    final historyRef = _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInHistory');

    final remindersRef = _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInReminders');

    final historySnapshot = await historyRef
        .where('date', isEqualTo: date)
        .get();

    final completedHistoryIds = <String>{};

    for (final doc in historySnapshot.docs) {
      final status =
          (doc.data()['status'] as String? ?? '').toUpperCase();

      if (status == 'COMPLETED' || status == 'HELP_REQUESTED') {
        completedHistoryIds.add(doc.id);
      }
    }

    final reminderSnapshot = await remindersRef
        .where('scheduledDate', isEqualTo: date)
        .get();

    final completedReminderIds = <String>{};

    for (final doc in reminderSnapshot.docs) {
      final status =
          (doc.data()['status'] as String? ?? '').toUpperCase();

      if (status == 'COMPLETED') {
        completedReminderIds.add(doc.id);
      }
    }

    final eligibleSlots = _slots.where((slot) {
      final scheduledAt = tz.TZDateTime(
        now.location,
        now.year,
        now.month,
        now.day,
        slot.hour,
        slot.minute,
      );

      // A slot is eligible once its scheduled time has arrived.
      // Before the first scheduled time, allow the first slot.
      final isFirstSlotBeforeSchedule =
          slot == _slots.first && now.isBefore(scheduledAt);

      if (now.isBefore(scheduledAt) && !isFirstSlotBeforeSchedule) {
        return false;
      }

      final id = _reminderId(date, slot);

      return !completedHistoryIds.contains(id) &&
          !completedReminderIds.contains(id);
    }).toList();

    if (eligibleSlots.isEmpty) {
      throw StateError(
        'All eligible check-in slots for today are already completed. '
        'Please try again at the next scheduled check-in.',
      );
    }

    // Choose the latest eligible scheduled time, not a future slot.
    final eligiblePastSlots = eligibleSlots.where((slot) {
      final scheduledAt = tz.TZDateTime(
        now.location,
        now.year,
        now.month,
        now.day,
        slot.hour,
        slot.minute,
      );

      return !now.isBefore(scheduledAt);
    }).toList();

    if (eligiblePastSlots.isNotEmpty) {
      return eligiblePastSlots.last;
    }

    // Before 10 AM, the first slot is the only eligible slot.
    return eligibleSlots.first;
  }

  /// Completes only the reminder matching this check-in's slot ID.
  Future<void> _completeMatchingReminder({
    required String elderId,
    required String reminderId,
    required String checkInId,
  }) async {
    final reminderRef = _firestore
        .collection('elders')
        .doc(elderId)
        .collection('checkInReminders')
        .doc(reminderId);

    final reminder = await reminderRef.get();

    // A reminder may not exist yet if the scheduler has not created it.
    if (!reminder.exists) {
      return;
    }

    final data = reminder.data() ?? <String, dynamic>{};
    final status =
        (data['status'] as String? ?? 'PENDING').toUpperCase();

    if (status == 'COMPLETED') {
      return;
    }

    await reminderRef.set(
      <String, dynamic>{
        'status': 'COMPLETED',
        'completedAt': FieldValue.serverTimestamp(),
        'checkInId': checkInId,
      },
      SetOptions(merge: true),
    );
  }

  
  /// Records one check-in per scheduled slot for the signed-in elder.
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

    if (!<String>{'COMPLETED', 'HELP_REQUESTED'}
        .contains(normalizedStatus)) {
      throw ArgumentError(
        'Check-in status must be COMPLETED or HELP_REQUESTED.',
      );
    }

    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw StateError('You are signed out. Please log in again.');
    }

    if (currentUser.uid != normalizedElderId) {
      throw StateError(
        'The signed-in user does not match the elder for this check-in.',
      );
    }

    final now = _nowInIndia();
    final date = _formatDate(now);
    final actualTime = _formatTime(now);

    final elderRef =
        _firestore.collection('elders').doc(normalizedElderId);

    final historyRef = elderRef.collection('checkInHistory');
    final remindersRef = elderRef.collection('checkInReminders');
    final statusRef = elderRef.collection('status').doc('current');

    // Select a candidate slot. The transaction below validates it again.
    final slot = await _findSlot(
      elderId: normalizedElderId,
      date: date,
      now: now,
    );

    final checkInId = _reminderId(date, slot);
    final checkInRef = historyRef.doc(checkInId);
    final reminderRef = remindersRef.doc(checkInId);
    final activityRef = elderRef.collection('activityHistory').doc();

    await _firestore.runTransaction((transaction) async {
      // Read every document before making transaction writes.
      final existingCheckIn = await transaction.get(checkInRef);
      final existingReminder = await transaction.get(reminderRef);

      if (existingCheckIn.exists) {
        throw StateError(
          'This scheduled check-in has already been recorded.',
        );
      }

      final reminderData =
          existingReminder.data() ?? <String, dynamic>{};
      final reminderStatus =
          (reminderData['status'] as String? ?? 'PENDING')
              .toUpperCase();

      if (reminderStatus == 'COMPLETED') {
        throw StateError(
          'This scheduled check-in is already completed.',
        );
      }

      transaction.set(checkInRef, <String, dynamic>{
        'elderId': normalizedElderId,
        'date': date,
        'scheduledTime': slot.label,
        'checkInTime': actualTime,
        'completedAt': FieldValue.serverTimestamp(),
        'status': normalizedStatus,
        'method': normalizedMethod,
        'response': normalizedResponse,
        'reminderStage': 0,
        'reminderId': checkInId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.set(
        statusRef,
        <String, dynamic>{
          'elderId': normalizedElderId,
          'checkInStatus': normalizedStatus,
          'lastCheckInAt': FieldValue.serverTimestamp(),
          'lastCheckInMethod': normalizedMethod,
        },
        SetOptions(merge: true),
      );

      transaction.set(activityRef, <String, dynamic>{
        'elderId': normalizedElderId,
        'type': 'checkin',
        'description': normalizedStatus == 'HELP_REQUESTED'
            ? 'Elder requested help during check-in.'
            : 'Elder completed a check-in.',
        'method': normalizedMethod,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Complete only this slot's reminder, if it already exists.
      if (existingReminder.exists) {
        transaction.set(
          reminderRef,
          <String, dynamic>{
            'status': 'COMPLETED',
            'completedAt': FieldValue.serverTimestamp(),
            'checkInId': checkInId,
          },
          SetOptions(merge: true),
        );
      }

      if (normalizedStatus == 'HELP_REQUESTED') {
        final alertRef = elderRef.collection('alerts').doc();

        transaction.set(alertRef, <String, dynamic>{
          'title': 'Elder Needs Help',
          'message': 'The elder requested help during check-in.',
          'date': _formatAlertDate(now),
          'type': 'help_request',
          'elderId': normalizedElderId,
          'status': 'active',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
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

    final elderRef =
        _firestore.collection('elders').doc(normalizedElderId);

    final checkInRef = elderRef
        .collection('checkInHistory')
        .doc(normalizedCheckInId);

    final statusRef = elderRef.collection('status').doc('current');
    final activityRef = elderRef.collection('activityHistory').doc();

    await _firestore.runTransaction((transaction) async {
      // Read the history record before writing anything.
      final existingCheckIn = await transaction.get(checkInRef);

      if (!existingCheckIn.exists) {
        throw StateError('The check-in record could not be found.');
      }

      final existingData = existingCheckIn.data()!;
      final date = existingData['date'] as String?;

      if (date == null || date.isEmpty) {
        throw StateError(
          'The check-in record has no date; it cannot be matched safely.',
        );
      }

      final reminderId = _reminderIdForHistory(
        checkInId: normalizedCheckInId,
        date: date,
        scheduledTime: existingData['scheduledTime'] as String?,
      );

      final DocumentReference<Map<String, dynamic>>? reminderRef =
          reminderId == null
              ? null
              : elderRef.collection('checkInReminders').doc(reminderId);

      // All transaction reads must happen before transaction writes.
      DocumentSnapshot<Map<String, dynamic>>? reminderSnapshot;

      if (reminderRef != null) {
        reminderSnapshot = await transaction.get(reminderRef);
      }

      transaction.update(checkInRef, <String, dynamic>{
        'status': 'COMPLETED',
        'completedBy': 'caregiver',
        'completedAt': FieldValue.serverTimestamp(),
      });

      transaction.set(
        statusRef,
        <String, dynamic>{
          'elderId': normalizedElderId,
          'checkInStatus': 'COMPLETED',
          'lastCheckInAt': FieldValue.serverTimestamp(),
          'lastCheckInMethod': 'caregiver',
        },
        SetOptions(merge: true),
      );

      transaction.set(activityRef, <String, dynamic>{
        'elderId': normalizedElderId,
        'type': 'checkin',
        'description': 'Caregiver manually completed the check-in.',
        'method': 'caregiver',
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (reminderRef != null &&
          reminderSnapshot != null &&
          reminderSnapshot.exists) {
        transaction.set(
          reminderRef,
          <String, dynamic>{
            'status': 'COMPLETED',
            'completedAt': FieldValue.serverTimestamp(),
            'checkInId': normalizedCheckInId,
          },
          SetOptions(merge: true),
        );
      }
    });
  }

  String? _reminderIdForHistory({
    required String checkInId,
    required String date,
    required String? scheduledTime,
  }) {
    // New-format history IDs already match reminder IDs.
    if (_slots.any((slot) => _reminderId(date, slot) == checkInId)) {
      return checkInId;
    }

    // Support legacy date-only history records where possible.
    final normalizedTime = (scheduledTime ?? '').trim().toUpperCase();

    for (final slot in _slots) {
      if (slot.label == normalizedTime) {
        return _reminderId(date, slot);
      }
    }

    return null;
  }
}

class _CheckInSlot {
  const _CheckInSlot({
    required this.hour,
    required this.minute,
    required this.label,
  });

  final int hour;
  final int minute;
  final String label;
}