import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';

class CareCircleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Generate a random 6-digit alphanumeric code for Elders
  String generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return List.generate(6, (index) => chars[rnd.nextInt(chars.length)]).join();
  }

  // Save the generated code to an Elder's document
  Future<String> createElderInviteCode(String elderUid) async {
    final code = generateInviteCode();
    await _db.collection('users').doc(elderUid).update({
      'inviteCode': code,
    });
    return code;
  }

  // Link a Caregiver to an Elder using the 6-digit code
  Future<void> linkCaregiverToElder({
    required String caregiverUid,
    required String inviteCode,
  }) async {
    final query = await _db
        .collection('users')
        .where('role', isEqualTo: 'elder')
        .where('inviteCode', isEqualTo: inviteCode.trim().toUpperCase())
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid code. No matching elder account found.');
    }

    final elderUid = query.docs.first.id;

    await _db.collection('users').doc(caregiverUid).update({
      'linkedElders': FieldValue.arrayUnion([elderUid]),
    });
  }
}
