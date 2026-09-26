class CheckInReminder {
  final String id;
  final String elderId;
  final String scheduledTime;
  final String status;
  final bool firstReminderSent;
  final bool secondReminderSent;
  final bool caregiverNotified;

  CheckInReminder({
    required this.id,
    required this.elderId,
    required this.scheduledTime,
    required this.status,
    required this.firstReminderSent,
    required this.secondReminderSent,
    required this.caregiverNotified,
  });

  Map<String, dynamic> toMap() {
    return {
      'elderId': elderId,
      'scheduledTime': scheduledTime,
      'status': status,
      'firstReminderSent': firstReminderSent,
      'secondReminderSent': secondReminderSent,
      'caregiverNotified': caregiverNotified,
    };
  }

  factory CheckInReminder.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return CheckInReminder(
      id: id,
      elderId: map['elderId'] ?? '',
      scheduledTime: map['scheduledTime'] ?? '',
      status: map['status'] ?? 'PENDING',
      firstReminderSent: map['firstReminderSent'] ?? false,
      secondReminderSent: map['secondReminderSent'] ?? false,
      caregiverNotified: map['caregiverNotified'] ?? false,
    );
  }
}