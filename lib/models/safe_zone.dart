class SafeZone {
  final String id;
  final String elderId;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusInMeters;
  final String createdBy;

  SafeZone({
    required this.id,
    required this.elderId,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.radiusInMeters,
    required this.createdBy,
  });

  Map<String, dynamic> toMap() {
    return {
      'elderId': elderId,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
      'radiusInMeters': radiusInMeters,
      'createdBy': createdBy,
    };
  }

  factory SafeZone.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return SafeZone(
      id: id,
      elderId: map['elderId'] ?? '',
      name: map['name'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      radiusInMeters:
          (map['radiusInMeters'] as num?)?.toDouble() ?? 100.0,
      createdBy: map['createdBy'] ?? '',
    );
  }
}