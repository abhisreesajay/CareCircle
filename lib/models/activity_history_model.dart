class ActivityHistory {
  final String id;
  final String activity;
  final String date;
  final String time;

  ActivityHistory({
    required this.id,
    required this.activity,
    required this.date,
    required this.time,
  });

  factory ActivityHistory.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ActivityHistory(
      id: id,
      activity: map['activity'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
    );
  }
}