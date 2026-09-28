import 'package:cloud_firestore/cloud_firestore.dart';

class ActivityHistory {
  final String id;
  final String activity;
  final String date;
  final String time;
  final String type;
  final String method;

  ActivityHistory({
    required this.id,
    required this.activity,
    required this.date,
    required this.time,
    required this.type,
    required this.method,
  });

  factory ActivityHistory.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    // ------------------------------------------------------------
    // ACTIVITY NAME
    // ------------------------------------------------------------
    //
    // New activity documents use:
    // description: "Elder completed a check-in."
    //
    // Older documents may use:
    // activity: "Check-in"
    //
    // So support both.
    // ------------------------------------------------------------

    String activityName =
        map['activity']?.toString().trim() ?? '';

    if (activityName.isEmpty) {
      activityName =
          map['description']?.toString().trim() ?? '';
    }

    if (activityName.isEmpty) {
      final String type =
          map['type']?.toString().trim().toLowerCase() ?? '';

      switch (type) {
        case 'checkin':
        case 'check_in':
          activityName = 'Daily Check-in';
          break;

        case 'medicine':
        case 'medication':
          activityName = 'Medicine Activity';
          break;

        case 'appointment':
          activityName = 'Appointment';
          break;

        case 'sos':
          activityName = 'SOS Alert';
          break;

        case 'safe_zone':
        case 'safezone':
          activityName = 'Safe Zone Activity';
          break;

        default:
          activityName = 'Activity';
      }
    }

    // ------------------------------------------------------------
    // DATE + TIME
    // ------------------------------------------------------------

    String date = map['date']?.toString() ?? '';
    String time = map['time']?.toString() ?? '';

    final dynamic timestamp = map['timestamp'];

    if (timestamp is Timestamp) {
      final DateTime dateTime =
          timestamp.toDate().toLocal();

      if (date.isEmpty) {
        date =
            '${dateTime.day.toString().padLeft(2, '0')}/'
            '${dateTime.month.toString().padLeft(2, '0')}/'
            '${dateTime.year}';
      }

      if (time.isEmpty) {
        final String hour =
            dateTime.hour.toString().padLeft(2, '0');

        final String minute =
            dateTime.minute.toString().padLeft(2, '0');

        time = '$hour:$minute';
      }
    }

    return ActivityHistory(
      id: id,
      activity: activityName,
      date: date.isEmpty ? 'Date unavailable' : date,
      time: time.isEmpty ? 'Time unavailable' : time,
      type: map['type']?.toString() ?? '',
      method: map['method']?.toString() ?? '',
    );
  }
}