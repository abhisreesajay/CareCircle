import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class CareCircleService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  // ============================================================
  // GENERATE INVITE CODE
  // ============================================================

  String generateInviteCode() {
    const String chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

    final Random random = Random();

    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  // ============================================================
  // CREATE ELDER INVITE CODE
  // ============================================================

  Future<String> createElderInviteCode(
    String elderUid,
  ) async {
    final String uid = elderUid.trim();

    if (uid.isEmpty) {
      throw Exception(
        'Elder UID is required.',
      );
    }

    // Check whether the elder already has a code.
    final DocumentSnapshot<Map<String, dynamic>>
        elderSnapshot = await _db
            .collection('users')
            .doc(uid)
            .get();

    final existingCode =
        elderSnapshot.data()?['inviteCode']
            ?.toString()
            .trim()
            .toUpperCase();

    if (existingCode != null &&
        existingCode.isNotEmpty) {
      return existingCode;
    }

    // Generate a new code.
    String code = generateInviteCode();

    // Make sure the code does not already exist.
    for (int i = 0; i < 5; i++) {
      final existing =
          await _db
              .collection('inviteCodes')
              .doc(code)
              .get();

      if (!existing.exists) {
        break;
      }

      code = generateInviteCode();
    }

    // Save the code on the elder's profile.
    await _db
        .collection('users')
        .doc(uid)
        .set(
      {
        'inviteCode': code,
      },
      SetOptions(merge: true),
    );

    // Also create the lookup document used
    // by caregivers.
    await _db
        .collection('inviteCodes')
        .doc(code)
        .set({
      'code': code,
      'elderId': uid,
      'createdAt':
          FieldValue.serverTimestamp(),
    });

    return code;
  }

  // ============================================================
  // LINK CAREGIVER TO ELDER
  // ============================================================

  Future<void> linkCaregiverToElder({
    required String caregiverUid,
    required String inviteCode,
  }) async {
    final String caregiverId =
        caregiverUid.trim();

    final String code =
        inviteCode.trim().toUpperCase();

    if (caregiverId.isEmpty) {
      throw Exception(
        'Caregiver UID is required.',
      );
    }

    if (code.isEmpty) {
      throw Exception(
        'Invite code is required.',
      );
    }

    if (code.length != 6) {
      throw Exception(
        'Invite code must contain 6 characters.',
      );
    }

    // Find the invite code.
    final DocumentSnapshot<
        Map<String, dynamic>> invite =
        await _db
            .collection('inviteCodes')
            .doc(code)
            .get();

    if (!invite.exists) {
      throw Exception(
        'Invalid invite code.',
      );
    }

    final Map<String, dynamic> data =
        invite.data() ?? {};

    final String elderUid =
        data['elderId']?.toString().trim() ?? '';

    if (elderUid.isEmpty) {
      throw Exception(
        'Invite code is invalid.',
      );
    }

    if (elderUid == caregiverId) {
      throw Exception(
        'A user cannot link themselves.',
      );
    }

    // Make sure the target user really exists
    // and is an elder.
    final elderSnapshot =
        await _db
            .collection('users')
            .doc(elderUid)
            .get();

    if (!elderSnapshot.exists) {
      throw Exception(
        'Elder account was not found.',
      );
    }

    final elderData =
        elderSnapshot.data() ?? {};

    final String role =
        elderData['role']
                ?.toString()
                .toLowerCase() ??
            '';

    if (role != 'elder') {
      throw Exception(
        'This invite code does not belong to an elder.',
      );
    }

    // Make sure the caregiver is actually a caregiver.
    final caregiverSnapshot =
        await _db
            .collection('users')
            .doc(caregiverId)
            .get();

    if (!caregiverSnapshot.exists) {
      throw Exception(
        'Caregiver account was not found.',
      );
    }

    final caregiverData =
        caregiverSnapshot.data() ?? {};

    final String caregiverRole =
        caregiverData['role']
                ?.toString()
                .toLowerCase() ??
            '';

    if (caregiverRole != 'caregiver') {
      throw Exception(
        'Only caregiver accounts can be linked.',
      );
    }

    // Add elder to caregiver's linkedElders.
    await _db
        .collection('users')
        .doc(caregiverId)
        .set(
      {
        'linkedElders':
            FieldValue.arrayUnion(
          [elderUid],
        ),
      },
      SetOptions(merge: true),
    );

    // Add caregiver to elder's caregivers.
    await _db
        .collection('users')
        .doc(elderUid)
        .set(
      {
        'caregivers':
            FieldValue.arrayUnion(
          [caregiverId],
        ),
      },
      SetOptions(merge: true),
    );
  }
}