import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
<<<<<<< HEAD
=======
import '../../models/care_circle_model.dart';
>>>>>>> develop

class CareCircleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String generateInviteCode() {
    const String chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final Random random = Random();

    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<String> createElderInviteCode(String elderUid) async {
    final String uid = elderUid.trim();

    if (uid.isEmpty) {
      throw Exception('Elder UID is required.');
    }

    final DocumentReference<Map<String, dynamic>> userRef =
        _db.collection('users').doc(uid);

    final DocumentSnapshot<Map<String, dynamic>> elderSnapshot =
        await userRef.get();

    if (!elderSnapshot.exists) {
      throw Exception('Elder account was not found.');
    }

    final Map<String, dynamic> elderData =
        elderSnapshot.data() ?? {};

    final String role =
        elderData['role']?.toString().trim().toLowerCase() ?? '';

    if (role != 'elder') {
      throw Exception('Only elder accounts can create an invite code.');
    }

    String? existingCode =
        elderData['inviteCode']?.toString().trim().toUpperCase();

    // If the elder already has a code, make sure the corresponding
    // inviteCodes document exists.
    if (existingCode != null && existingCode.isNotEmpty) {
      await _db.collection('inviteCodes').doc(existingCode).set({
        'code': existingCode,
        'elderId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return existingCode;
    }

    // Generate a new code.
    final String code = generateInviteCode();

    // Save the code in the elder's user document.
    await userRef.set({
      'inviteCode': code,
    }, SetOptions(merge: true));

    // Create the lookup document used by caregivers.
    await _db.collection('inviteCodes').doc(code).set({
      'code': code,
      'elderId': uid,
      'createdAt': FieldValue.serverTimestamp(),
    });

    return code;
  }

  Future<void> linkCaregiverToElder({
    required String caregiverUid,
    required String inviteCode,
  }) async {
    final String caregiverId = caregiverUid.trim();
    final String code = inviteCode.trim().toUpperCase();

    if (caregiverId.isEmpty) {
      throw Exception('Caregiver UID is required.');
    }

    if (code.isEmpty) {
      throw Exception('Invite code is required.');
    }

    if (code.length != 6) {
      throw Exception('Invite code must contain 6 characters.');
    }

    // Find the elder associated with the code.
    final DocumentSnapshot<Map<String, dynamic>> invite =
        await _db.collection('inviteCodes').doc(code).get();

    if (!invite.exists) {
      throw Exception('Invalid invite code.');
    }

    final Map<String, dynamic> inviteData =
        invite.data() ?? {};

    final String elderUid =
        inviteData['elderId']?.toString().trim() ?? '';

    if (elderUid.isEmpty) {
      throw Exception('Invite code is invalid.');
    }

    if (elderUid == caregiverId) {
      throw Exception('A user cannot link themselves.');
    }

    // Get elder account.
    final DocumentSnapshot<Map<String, dynamic>> elderSnapshot =
        await _db.collection('users').doc(elderUid).get();

    if (!elderSnapshot.exists) {
      throw Exception('Elder account was not found.');
    }

    final Map<String, dynamic> elderData =
        elderSnapshot.data() ?? {};

    final String elderRole =
        elderData['role']?.toString().trim().toLowerCase() ?? '';

    if (elderRole != 'elder') {
      throw Exception(
        'This invite code does not belong to an elder.',
      );
    }

    // Get caregiver account.
    final DocumentSnapshot<Map<String, dynamic>> caregiverSnapshot =
        await _db.collection('users').doc(caregiverId).get();

    if (!caregiverSnapshot.exists) {
      throw Exception('Caregiver account was not found.');
    }

    final Map<String, dynamic> caregiverData =
        caregiverSnapshot.data() ?? {};

    final String caregiverRole =
        caregiverData['role']?.toString().trim().toLowerCase() ?? '';

    if (caregiverRole != 'caregiver') {
      throw Exception('Only caregiver accounts can be linked.');
    }

    // Add elder to caregiver's linked elder list.
    await _db.collection('users').doc(caregiverId).set(
      {
        'linkedElders': FieldValue.arrayUnion([elderUid]),
      },
      SetOptions(merge: true),
    );

    // Add caregiver to elder's caregiver list.
    await _db.collection('users').doc(elderUid).set(
      {
        'caregivers': FieldValue.arrayUnion([caregiverId]),
      },
      SetOptions(merge: true),
    );
  }
}