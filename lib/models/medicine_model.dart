class Medicine {
  final String id;
  final String name;
  final String dosage;
  final String time;
  final String frequency;
  final bool acknowledged;

  Medicine({
    required this.id,
    required this.name,
    required this.dosage,
    required this.time,
    required this.frequency,
    this.acknowledged = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'time': time,
      'frequency': frequency,
      'acknowledged': acknowledged,
    };
  }

  factory Medicine.fromMap(String id, Map<String, dynamic> map) {
    return Medicine(
      id: id,
      name: map['name'] ?? '',
      dosage: map['dosage'] ?? '',
      time: map['time'] ?? '',
      frequency: map['frequency'] ?? '',
      acknowledged: map['acknowledged'] ?? false,
    );
  }
}