import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class CareCircleService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  // ============================================================
  // GENERATE CODE
  // ============================================================

  String generateInviteCode() {
    const String chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    final Random random = Random();

    return List.generate(
      6,
      (_) => chars[
          random.nextInt(chars.length)],
    ).join();
  }

  // ============================================================
  // CREATE ELDER INVITE CODE
  // ============================================================

  Future<String> createElderInviteCode(
    String elderUid,
  ) async {
    if (elderUid.trim().isEmpty) {
      throw Exception(
        'Elder UID is required.',
      );
    }

    final String code =
        generateInviteCode();

    await _db
        .collection('users')
        .doc(elderUid)
        .set(
      {
        'inviteCode': code,
      },
      SetOptions(merge: true),
    );

    await _db
        .collection('inviteCodes')
        .doc(code)
        .set({
      'code': code,
      'elderId': elderUid,
      'createdAt':
          FieldValue.serverTimestamp(),
    });

    return code;
  }

  // ============================================================
  // LINK CAREGIVER
  // ============================================================

  Future<void> linkCaregiverToElder({
    required String caregiverUid,
    required String inviteCode,
  }) async {
    final String code =
        inviteCode.trim().toUpperCase();

    if (caregiverUid.trim().isEmpty) {
      throw Exception(
        'Caregiver UID is required.',
      );
    }

    if (code.isEmpty) {
      throw Exception(
        'Invite code is required.',
      );
    }

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
        data['elderId']?.toString() ?? '';

    if (elderUid.isEmpty) {
      throw Exception(
        'Invite code is invalid.',
      );
    }

    if (elderUid == caregiverUid) {
      throw Exception(
        'A user cannot link themselves.',
      );
    }

    await _db
        .collection('users')
        .doc(caregiverUid)
        .set(
      {
        'linkedElders':
            FieldValue.arrayUnion(
          [elderUid],
        ),
      },
      SetOptions(merge: true),
    );

    await _db
        .collection('users')
        .doc(elderUid)
        .set(
      {
        'caregivers':
            FieldValue.arrayUnion(
          [caregiverUid],
        ),
      },
      SetOptions(merge: true),
    );
  }
}