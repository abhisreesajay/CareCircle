class CareCircle {
  final String elderId;
  final List<String> caregiverIds;

  CareCircle({
    required this.elderId,
    required this.caregiverIds,
  });

  factory CareCircle.fromMap(
    Map<String, dynamic> map,
  ) {
    return CareCircle(
      elderId:
          map['elderId']?.toString() ?? '',
      caregiverIds:
          (map['caregiverIds']
                      as List<dynamic>?)
                  ?.map(
                    (item) =>
                        item.toString(),
                  )
                  .toList() ??
              const [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'elderId': elderId,
      'caregiverIds':
          caregiverIds,
    };
  }
}