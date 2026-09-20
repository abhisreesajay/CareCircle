class MedicalSummary {
  final String bloodGroup;
  final String allergies;
  final String conditions;
  final String notes;

  MedicalSummary({
    required this.bloodGroup,
    required this.allergies,
    required this.conditions,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'bloodGroup': bloodGroup,
      'allergies': allergies,
      'conditions': conditions,
      'notes': notes,
    };
  }

  factory MedicalSummary.fromMap(
    Map<String, dynamic> map,
  ) {
    return MedicalSummary(
      bloodGroup: map['bloodGroup'] ?? '',
      allergies: map['allergies'] ?? '',
      conditions: map['conditions'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}