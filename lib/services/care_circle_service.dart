import 'dart:math';
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
    });

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
  }
}
