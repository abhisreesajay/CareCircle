import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';

class CareCircleService {
  final FirebaseFirestore _db =
      FirebaseFirestore.instance;

  String generateInviteCode() {
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';

    final Random random = Random();

    return List.generate(
      6,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  Future<String> createElderInviteCode(
    String elderUid,
  ) async {
    if (elderUid.trim().isEmpty) {
      throw Exception('Elder UID is required.');
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

    return code;
  }

  Future<void> linkCaregiverToElder({
    required String caregiverUid,
    required String inviteCode,
  }) async {
    final String normalizedCode =
        inviteCode.trim().toUpperCase();

    if (caregiverUid.trim().isEmpty) {
      throw Exception(
        'Caregiver UID is required.',
      );
    }

    if (normalizedCode.isEmpty) {
      throw Exception(
        'Invite code is required.',
      );
    }

    final QuerySnapshot<
        Map<String, dynamic>> query =
        await _db
            .collection('users')
            .where(
              'role',
              isEqualTo: 'elder',
            )
            .where(
              'inviteCode',
              isEqualTo: normalizedCode,
            )
            .limit(1)
            .get();

    if (query.docs.isEmpty) {
      throw Exception(
        'Invalid invite code.',
      );
    }

    final String elderUid =
        query.docs.first.id;

    if (elderUid == caregiverUid) {
      throw Exception(
        'A user cannot link themselves.',
      );
    }

    final DocumentReference<
        Map<String, dynamic>> elderRef =
        _db.collection('users').doc(elderUid);

    final DocumentReference<
        Map<String, dynamic>> caregiverRef =
        _db.collection('users').doc(caregiverUid);

    await caregiverRef.set(
      {
        'linkedElders':
            FieldValue.arrayUnion([elderUid]),
      },
      SetOptions(merge: true),
    );

    await elderRef.set(
      {
        'caregivers':
            FieldValue.arrayUnion([caregiverUid]),
      },
      SetOptions(merge: true),
    );
  }
}
