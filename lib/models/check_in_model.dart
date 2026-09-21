class CheckIn {
  final String id;
  final String elderId;
  final String date;
  final String scheduledTime;
  final String status;
  final String method;
  final String response;
  final int reminderStage;

  CheckIn({
    required this.id,
    required this.elderId,
    required this.date,
    required this.scheduledTime,
    required this.status,
    required this.method,
    required this.response,
    required this.reminderStage,
  });

  factory CheckIn.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return CheckIn(
      id: id,
      elderId:
          map['elderId']?.toString() ?? '',
      date:
          map['date']?.toString() ?? '',
      scheduledTime:
          map['scheduledTime']?.toString() ?? '',
      status:
          map['status']?.toString() ??
              'PENDING',
      method:
          map['method']?.toString() ?? '',
      response:
          map['response']?.toString() ?? '',
      reminderStage:
          map['reminderStage'] is int
              ? map['reminderStage']
                  as int
              : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elderId': elderId,
      'date': date,
      'scheduledTime': scheduledTime,
      'status': status,
      'method': method,
      'response': response,
      'reminderStage':
          reminderStage,
    };
  }
}