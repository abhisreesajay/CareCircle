<<<<<<< HEAD
=======
<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';

>>>>>>> main
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
=======
class UserModel {
  final String uid;
  final String email;
  final String role;
  final List<String> linkedElders;
  final List<String> caregivers;
  final String? inviteCode;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.linkedElders = const [],
    this.caregivers = const [],
    this.inviteCode,
  });

  factory UserModel.fromMap(
    String uid,
    Map<String, dynamic> data,
  ) {
    return UserModel(
      uid: uid,
      email: data['email']?.toString() ?? '',
      role: data['role']?.toString() ?? 'elder',

      linkedElders:
          (data['linkedElders'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],

      caregivers:
          (data['caregivers'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],

      inviteCode:
          data['inviteCode']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'linkedElders': linkedElders,
      'caregivers': caregivers,
      'inviteCode': inviteCode,
    };
  }
}
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
