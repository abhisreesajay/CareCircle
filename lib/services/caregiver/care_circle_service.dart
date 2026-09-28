import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/care_circle_model.dart';

class CareCircleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Link caregiver to an elder using the 6-character invite code
  Future<String> linkCaregiverWithInviteCode({
    required String inviteCode,
    required String caregiverUid,
  }) async {
    final cleanCode = inviteCode.trim().toUpperCase();

    // 1. Locate elder with matching invite code
    final query = await _firestore
        .collection('users')
        .where('role', isEqualTo: 'elder')
        .where('inviteCode', isEqualTo: cleanCode)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Invalid invite code. Please check and try again.');
    }

    final elderId = query.docs.first.id;

    // 2. Add caregiver to the elder's care circle collection
    await _firestore.collection('care_circles').doc(elderId).set({
      'elderId': elderId,
      'caregiverIds': FieldValue.arrayUnion([caregiverUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return elderId;
  }

  // Get the linked elder ID for a specific caregiver
  Future<String?> getElderIdForCaregiver(String caregiverUid) async {
    final query = await _firestore
        .collection('care_circles')
        .where('caregiverIds', arrayContains: caregiverUid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      return query.docs.first.id;
    }
    return null;
  }

  // Stream caregiver list for a specific elder (used in Elder UI)
  Stream<CareCircleModel?> streamCareCircle(String elderId) {
    return _firestore
        .collection('care_circles')
        .doc(elderId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return CareCircleModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    });
  }

  // Unlink a caregiver from an elder
  Future<void> removeCaregiver({
    required String elderId,
    required String caregiverUid,
  }) async {
    await _firestore.collection('care_circles').doc(elderId).update({
      'caregiverIds': FieldValue.arrayRemove([caregiverUid]),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
