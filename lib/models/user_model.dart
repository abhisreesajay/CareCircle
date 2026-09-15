class UserModel {
  final String uid;
  final String email;
  final String role; // 'elder' or 'caregiver'
  final String? name;
  final String? inviteCode;
  final String? elderId; // <--- Added field
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.inviteCode,
    this.elderId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'inviteCode': inviteCode,
      'elderId': elderId,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      name: map['name'],
      inviteCode: map['inviteCode'],
      elderId: map['elderId'],
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String
              ? DateTime.tryParse(map['createdAt'])
              : (map['createdAt'] as dynamic).toDate())
          : null,
    );
  }
}
