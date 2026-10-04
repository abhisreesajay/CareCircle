class CheckInHistory {
  final String id;
  final String date;
  final String scheduledTime;
  final String status;

  const CheckInHistory({
    required this.id,
    required this.date,
    required this.scheduledTime,
    required this.status,
  });

  factory CheckInHistory.fromMap(String id, Map<String, dynamic> map) {
    return CheckInHistory(
      id: id,
      date: map['date']?.toString() ?? '',
      scheduledTime: map['scheduledTime']?.toString() ?? '',
      status: map['status']?.toString() ?? 'PENDING',
    );
  }
}
