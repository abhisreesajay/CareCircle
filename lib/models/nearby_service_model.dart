class NearbyService {
  final String id;
  final String name;
  final String type;
  final String phone;
  final String address;
  final bool preferred;

  NearbyService({
    required this.id,
    required this.name,
    required this.type,
    required this.phone,
    required this.address,
    this.preferred = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'phone': phone,
      'address': address,
      'preferred': preferred,
    };
  }

  factory NearbyService.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return NearbyService(
      id: id,
      name: map['name'] ?? '',
      type: map['type'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      preferred: map['preferred'] ?? false,
    );
  }
}