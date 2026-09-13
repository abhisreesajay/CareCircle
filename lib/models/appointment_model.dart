class Appointment {
  final String id;
  final String doctorName;
  final String hospitalName;
  final String date;
  final String time;
  final String purpose;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.hospitalName,
    required this.date,
    required this.time,
    required this.purpose,
  });

  Map<String, dynamic> toMap() {
    return {
      'doctorName': doctorName,
      'hospitalName': hospitalName,
      'date': date,
      'time': time,
      'purpose': purpose,
    };
  }

  factory Appointment.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return Appointment(
      id: id,
      doctorName: map['doctorName'] ?? '',
      hospitalName: map['hospitalName'] ?? '',
      date: map['date'] ?? '',
      time: map['time'] ?? '',
      purpose: map['purpose'] ?? '',
    );
  }
}