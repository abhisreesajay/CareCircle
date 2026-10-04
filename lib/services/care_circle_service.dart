import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class CareCircleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // GENERATE INVITE CODE
  // ============================================================

  String generateInviteCode() {
    const String chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final Random random = Random();

    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // ============================================================
  // CREATE / GET ELDER INVITE CODE
  // ============================================================

  Future<String> createElderInviteCode(String elderUid) async {
    final String uid = elderUid.trim();

    if (uid.isEmpty) {
      throw Exception('Elder UID is required.');
    }

    final DocumentReference<Map<String, dynamic>> elderRef =
        _db.collection('users').doc(uid);

    final DocumentSnapshot<Map<String, dynamic>> elderSnapshot =
        await elderRef.get();

    if (!elderSnapshot.exists) {
      throw Exception('Elder account was not found.');
    }

    final Map<String, dynamic> elderData = elderSnapshot.data() ?? {};

    final String role =
        elderData['role']?.toString().trim().toLowerCase() ?? '';

    if (role != 'elder') {
      throw Exception(
        'Only elder accounts can create an invite code.',
      );
    }

    // ----------------------------------------------------------
    // EXISTING CODE
    // ----------------------------------------------------------

    final String existingCode =
        elderData['inviteCode']?.toString().trim().toUpperCase() ?? '';

    if (existingCode.isNotEmpty) {
      final DocumentReference<Map<String, dynamic>> inviteRef =
          _db.collection('inviteCodes').doc(existingCode);

      final DocumentSnapshot<Map<String, dynamic>> inviteSnapshot =
          await inviteRef.get();

      if (!inviteSnapshot.exists) {
        await inviteRef.set({
          'code': existingCode,
          'elderId': uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final Map<String, dynamic> existingInviteData =
            inviteSnapshot.data() ?? {};

        if (existingInviteData['elderId']?.toString() != uid) {
          throw Exception(
            'This invite code is already assigned to another account. '
            'Please contact support.',
          );
        }
      }

      return existingCode;
    }

    // ----------------------------------------------------------
    // GENERATE UNIQUE CODE
    // ----------------------------------------------------------

    String code = '';

    while (true) {
      final String generated = generateInviteCode();

      final DocumentSnapshot<Map<String, dynamic>> existing =
          await _db.collection('inviteCodes').doc(generated).get();

      if (!existing.exists) {
        code = generated;
        break;
      }
    }

    // ----------------------------------------------------------
    // SAVE ELDER CODE + LOOKUP DOCUMENT
    // ----------------------------------------------------------

    final DocumentReference<Map<String, dynamic>> inviteRef =
        _db.collection('inviteCodes').doc(code);

    final WriteBatch batch = _db.batch();

    batch.update(
      elderRef,
      {'inviteCode': code},
    );

    batch.set(
      inviteRef,
      {
        'code': code,
        'elderId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();

    return code;
  }

  // ============================================================
  // LINK CAREGIVER TO ELDER
  // ============================================================

  Future<void> linkCaregiverWithInviteCode({
    required String inviteCode,
    required String caregiverUid,
  }) async {
    final String code = inviteCode.trim().toUpperCase();
    final String caregiverId = caregiverUid.trim();

    if (code.isEmpty) {
      throw Exception('Please enter the elder invite code.');
    }

    if (code.length != 6) {
      throw Exception('Invite code must contain exactly 6 characters.');
    }

    if (caregiverId.isEmpty) {
      throw Exception('Caregiver account was not found.');
    }

    // ----------------------------------------------------------
    // FIND INVITE CODE
    // ----------------------------------------------------------

    final DocumentSnapshot<Map<String, dynamic>> inviteSnapshot =
        await _db.collection('inviteCodes').doc(code).get();

    if (!inviteSnapshot.exists) {
      throw Exception(
        'Invalid invite code. Please check the code and try again.',
      );
    }

    final Map<String, dynamic> inviteData =
        inviteSnapshot.data() ?? {};

    final String storedCode =
        inviteData['code']?.toString().trim().toUpperCase() ?? '';

    final String elderId = inviteData['elderId']?.toString().trim() ?? '';

    if (storedCode != code || elderId.isEmpty) {
      throw Exception('This invite code is invalid or incomplete.');
    }

    if (elderId == caregiverId) {
      throw Exception('A caregiver cannot connect to their own account.');
    }

    // ----------------------------------------------------------
    // GET CAREGIVER
    // ----------------------------------------------------------
    // The invite-code document provides the elder ID.
    // Do not read the elder's private user profile before linking.
    // Firestore rules must authorize both profile updates below.

    final DocumentSnapshot<Map<String, dynamic>> caregiverSnapshot =
        await _db.collection('users').doc(caregiverId).get();

    if (!caregiverSnapshot.exists) {
      throw Exception('Caregiver account profile was not found.');
    }

    final Map<String, dynamic> caregiverData =
        caregiverSnapshot.data() ?? {};

    final String caregiverRole =
        caregiverData['role']?.toString().trim().toLowerCase() ?? '';

    if (caregiverRole != 'caregiver') {
      throw Exception('Only caregiver accounts can connect to an elder.');
    }

    // ----------------------------------------------------------
    // CONNECT CAREGIVER <-> ELDER ATOMICALLY
    // ----------------------------------------------------------

    final WriteBatch batch = _db.batch();

    final DocumentReference<Map<String, dynamic>> caregiverRef =
        _db.collection('users').doc(caregiverId);

    final DocumentReference<Map<String, dynamic>> elderRef =
        _db.collection('users').doc(elderId);

    // Caregiver -> Elder
    batch.update(
      caregiverRef,
      {
        'linkedElders': FieldValue.arrayUnion([elderId]),
      },
    );

    // Elder -> Caregiver
    batch.update(
      elderRef,
      {
        'caregivers': FieldValue.arrayUnion([caregiverId]),
      },
    );

    await batch.commit();
  }

  // ============================================================
  // BACKWARD COMPATIBILITY
  // ============================================================

  Future<void> linkCaregiverToElder({
    required String caregiverUid,
    required String inviteCode,
  }) async {
    await linkCaregiverWithInviteCode(
      inviteCode: inviteCode,
      caregiverUid: caregiverUid,
    );
  }
}