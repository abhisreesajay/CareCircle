import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String role;

  final String? name;
  final String? inviteCode;
  final String? fcmToken;

  final List<String> linkedElders;
  final List<String> caregivers;

  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.role,
    this.name,
    this.inviteCode,
    this.fcmToken,
    this.linkedElders = const [],
    this.caregivers = const [],
    required this.createdAt,
  });

  factory UserModel.fromMap(
    Map<String, dynamic> map,
    String uid,
  ) {
    return UserModel(
      uid: uid,
      email: map['email']?.toString() ?? '',
      role: map['role']?.toString() ?? 'elder',
      name: map['name']?.toString(),
      inviteCode: map['inviteCode']?.toString(),
      fcmToken: map['fcmToken']?.toString(),

      linkedElders: (map['linkedElders'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],

      caregivers: (map['caregivers'] as List<dynamic>?)
              ?.map((item) => item.toString())
              .toList() ??
          const [],

      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
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
      'linkedElders': linkedElders,
      'caregivers': caregivers,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}