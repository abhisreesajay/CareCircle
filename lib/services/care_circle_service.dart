import 'dart:math';
<<<<<<< HEAD
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CareCircleService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // 1. ELDER SIDE: Generate a secure invite code
  // ============================================================
  Future<String> createElderInviteCode() async {
    final elderUid = _auth.currentUser?.uid;
    if (elderUid == null) throw Exception("User not logged in");

    // Generate a random 6-digit code
    final String code = (Random().nextInt(900000) + 100000).toString();

    // Save to the invite_codes collection
    await _db.collection('invite_codes').add({
      'code': code,
      'createdBy': elderUid,
      'status': 'active', 
      'createdAt': FieldValue.serverTimestamp(),
    });

    return code;
  }

  // ============================================================
  // 2. CAREGIVER SIDE: Consume code and securely link accounts
  // ============================================================
  Future<void> linkCaregiverToElder(String inviteCode) async {
    final caregiverUid = _auth.currentUser?.uid;
    if (caregiverUid == null) throw Exception("User not logged in");

    // A. Verify the code exists and is active
    final codeQuery = await _db.collection('invite_codes')
        .where('code', isEqualTo: inviteCode)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .get();

    if (codeQuery.docs.isEmpty) {
      throw Exception("Invalid or expired invite code.");
    }

    final codeDoc = codeQuery.docs.first;
    final elderUid = codeDoc.data()['createdBy'];
    
    // B. Initialize the atomic batch
    final batch = _db.batch();

    // C. Add Caregiver to Elder's profile (Satisfies your new Security Rules)
    batch.update(_db.collection('users').doc(elderUid), {
      'caregivers': FieldValue.arrayUnion([caregiverUid])
=======

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
      (_) => chars[
          random.nextInt(chars.length)
      ],
    ).join();
  }

  // ============================================================
  // CREATE / GET ELDER INVITE CODE
  // ============================================================

  Future<String> createElderInviteCode(
    String elderUid,
  ) async {
    final String uid =
        elderUid.trim();

    if (uid.isEmpty) {
      throw Exception(
        'Elder UID is required.',
      );
    }

    final DocumentReference<
            Map<String, dynamic>>
        elderRef =
        _db.collection('users').doc(uid);

    final DocumentSnapshot<
            Map<String, dynamic>>
        elderSnapshot =
        await elderRef.get();

    if (!elderSnapshot.exists) {
      throw Exception(
        'Elder account was not found.',
      );
    }

    final Map<String, dynamic>
        elderData =
        elderSnapshot.data() ?? {};

    final String role =
        elderData['role']
                ?.toString()
                .trim()
                .toLowerCase() ??
            '';

    if (role != 'elder') {
      throw Exception(
        'Only elder accounts can create an invite code.',
      );
    }

    // ----------------------------------------------------------
    // EXISTING CODE
    // ----------------------------------------------------------

    final String existingCode =
        elderData['inviteCode']
                ?.toString()
                .trim()
                .toUpperCase() ??
            '';

    if (existingCode.isNotEmpty) {
      final DocumentReference<
              Map<String, dynamic>>
          inviteRef =
          _db
              .collection('inviteCodes')
              .doc(existingCode);

      final DocumentSnapshot<
              Map<String, dynamic>>
          inviteSnapshot =
          await inviteRef.get();

      if (!inviteSnapshot.exists) {
        await inviteRef.set({
          'code': existingCode,
          'elderId': uid,
          'createdAt':
              FieldValue.serverTimestamp(),
        });
      }

      return existingCode;
    }

    // ----------------------------------------------------------
    // GENERATE UNIQUE CODE
    // ----------------------------------------------------------

    String code = '';

    while (true) {
      final String generated =
          generateInviteCode();

      final DocumentSnapshot<
              Map<String, dynamic>>
          existing =
          await _db
              .collection('inviteCodes')
              .doc(generated)
              .get();

      if (!existing.exists) {
        code = generated;
        break;
      }
    }

    // Save on elder profile.
    await elderRef.update({
      'inviteCode': code,
    });

    // Create lookup document.
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

  Future<void> linkCaregiverWithInviteCode({
    required String inviteCode,
    required String caregiverUid,
  }) async {
    final String code =
        inviteCode.trim().toUpperCase();

    final String caregiverId =
        caregiverUid.trim();

    if (code.isEmpty) {
      throw Exception(
        'Please enter the elder invite code.',
      );
    }

    if (code.length != 6) {
      throw Exception(
        'Invite code must contain exactly 6 characters.',
      );
    }

    if (caregiverId.isEmpty) {
      throw Exception(
        'Caregiver account was not found.',
      );
    }

    // ----------------------------------------------------------
    // FIND INVITE CODE
    // ----------------------------------------------------------

    final DocumentSnapshot<
            Map<String, dynamic>>
        inviteSnapshot =
        await _db
            .collection('inviteCodes')
            .doc(code)
            .get();

    if (!inviteSnapshot.exists) {
      throw Exception(
        'Invalid invite code. Please check the code and try again.',
      );
    }

    final Map<String, dynamic>
        inviteData =
        inviteSnapshot.data() ?? {};

    final String elderId =
        inviteData['elderId']
                ?.toString()
                .trim() ??
            '';

    if (elderId.isEmpty) {
      throw Exception(
        'This invite code is not linked to an elder.',
      );
    }

    if (elderId == caregiverId) {
      throw Exception(
        'A caregiver cannot connect to their own account.',
      );
    }

    // ----------------------------------------------------------
    // GET ELDER
    // ----------------------------------------------------------

    final DocumentSnapshot<
            Map<String, dynamic>>
        elderSnapshot =
        await _db
            .collection('users')
            .doc(elderId)
            .get();

    if (!elderSnapshot.exists) {
      throw Exception(
        'The elder account was not found.',
      );
    }

    final Map<String, dynamic>
        elderData =
        elderSnapshot.data() ?? {};

    final String elderRole =
        elderData['role']
                ?.toString()
                .trim()
                .toLowerCase() ??
            '';

    if (elderRole != 'elder') {
      throw Exception(
        'This invite code does not belong to an elder.',
      );
    }

    // ----------------------------------------------------------
    // GET CAREGIVER
    // ----------------------------------------------------------

    final DocumentSnapshot<
            Map<String, dynamic>>
        caregiverSnapshot =
        await _db
            .collection('users')
            .doc(caregiverId)
            .get();

    if (!caregiverSnapshot.exists) {
      throw Exception(
        'Caregiver account profile was not found.',
      );
    }

    final Map<String, dynamic>
        caregiverData =
        caregiverSnapshot.data() ?? {};

    final String caregiverRole =
        caregiverData['role']
                ?.toString()
                .trim()
                .toLowerCase() ??
            '';

    if (caregiverRole != 'caregiver') {
      throw Exception(
        'Only caregiver accounts can connect to an elder.',
      );
    }

    // ----------------------------------------------------------
    // CONNECT CAREGIVER -> ELDER
    // ----------------------------------------------------------

    await _db
        .collection('users')
        .doc(caregiverId)
        .update({
      'linkedElders':
          FieldValue.arrayUnion([
        elderId,
      ]),
    });

    // ----------------------------------------------------------
    // CONNECT ELDER -> CAREGIVER
    // ----------------------------------------------------------

    await _db
        .collection('users')
        .doc(elderId)
        .update({
      'caregivers':
          FieldValue.arrayUnion([
        caregiverId,
      ]),
>>>>>>> origin/main
    });

<<<<<<< HEAD
    // D. Add Elder to Caregiver's profile (Satisfies your new CaregiverGateway)
    batch.update(_db.collection('users').doc(caregiverUid), {
      'linkedElders': FieldValue.arrayUnion([elderUid])
    });

    // E. Invalidate the code so it cannot be reused
    batch.update(codeDoc.reference, {
      'status': 'used',
      'usedBy': caregiverUid,
      'usedAt': FieldValue.serverTimestamp(),
    });

    // F. Commit everything simultaneously
    await batch.commit();
=======
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
>>>>>>> origin/main
  }
}