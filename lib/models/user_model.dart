<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role; // 'caregiver' or 'elder'
  final String? name;
  final String? inviteCode; // 6-digit code for Elders to link Caregivers
  final String? fcmToken;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.inviteCode,
    this.fcmToken,
    required this.createdAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      role: map['role'] ?? 'elder',
      name: map['name'],
      inviteCode: map['inviteCode'],
      fcmToken: map['fcmToken'],
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'inviteCode': inviteCode,
      'fcmToken': fcmToken,
      'createdAt': FieldValue.serverTimestamp(),
    };
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
