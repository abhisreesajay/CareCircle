class CareAlert {
  final String id;
  final String title;
  final String message;
  final String date;
  final String type;

  CareAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.date,
    required this.type,
  });

  factory CareAlert.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return CareAlert(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      date: map['date'] ?? '',
      type: map['type'] ?? '',
    );
  }
}