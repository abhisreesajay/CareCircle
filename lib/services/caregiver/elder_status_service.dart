import 'package:cloud_firestore/cloud_firestore.dart';

class ElderStatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ============================================================
  // GET CURRENT STATUS
  // ============================================================

  Stream<DocumentSnapshot<Map<String, dynamic>>> getStatus(
    String elderId,
  ) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('status')
        .doc('current')
        .snapshots();
  }

  // ============================================================
  // UPDATE CURRENT STATUS
  // ============================================================

  Future<void> updateStatus({
    required String elderId,
    String? checkInStatus,
    String? activityStatus,
    String? wellbeingStatus,
    bool? safeZoneActive,
    bool? sosActive,
    bool? fallDetected,
    Timestamp? lastCheckIn,
    Timestamp? lastActivity,
  }) async {
    final Map<String, dynamic> updates = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (checkInStatus != null) {
      updates['checkInStatus'] = checkInStatus;
    }

    if (activityStatus != null) {
      updates['activityStatus'] = activityStatus;
    }

    if (wellbeingStatus != null) {
      updates['wellbeingStatus'] = wellbeingStatus;
    }

    if (safeZoneActive != null) {
      updates['safeZoneActive'] = safeZoneActive;
    }

    if (sosActive != null) {
      updates['sosActive'] = sosActive;
    }

    if (fallDetected != null) {
      updates['fallDetected'] = fallDetected;
    }

    if (lastCheckIn != null) {
      updates['lastCheckIn'] = lastCheckIn;
    }

    if (lastActivity != null) {
      updates['lastActivity'] = lastActivity;
    }

    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('status')
        .doc('current')
        .set(
          updates,
          SetOptions(merge: true),
        );
  }

  // ============================================================
  // UPDATE CHECK-IN STATUS
  // ============================================================

  Future<void> updateCheckInStatus({
    required String elderId,
    required String status,
  }) async {
    await updateStatus(
      elderId: elderId,
      checkInStatus: status,
      lastCheckIn: Timestamp.now(),
    );
  }

  // ============================================================
  // UPDATE ACTIVITY STATUS
  // ============================================================

  Future<void> updateActivityStatus({
    required String elderId,
    required String status,
  }) async {
    await updateStatus(
      elderId: elderId,
      activityStatus: status,
      lastActivity: Timestamp.now(),
    );
  }

  // ============================================================
  // UPDATE WELLBEING
  // ============================================================

  Future<void> updateWellbeingStatus({
    required String elderId,
    required String status,
  }) async {
    await updateStatus(
      elderId: elderId,
      wellbeingStatus: status,
    );
  }

  // ============================================================
  // UPDATE SAFE ZONE
  // ============================================================

  Future<void> updateSafeZoneStatus({
    required String elderId,
    required bool active,
  }) async {
    await updateStatus(
      elderId: elderId,
      safeZoneActive: active,
    );
  }

  // ============================================================
  // UPDATE SOS STATUS
  // ============================================================

  Future<void> updateSosStatus({
    required String elderId,
    required bool active,
  }) async {
    await updateStatus(
      elderId: elderId,
      sosActive: active,
    );
  }

  // ============================================================
  // UPDATE FALL DETECTION
  // ============================================================

  Future<void> updateFallStatus({
    required String elderId,
    required bool detected,
  }) async {
    await updateStatus(
      elderId: elderId,
      fallDetected: detected,
    );
  }

  // ============================================================
  // RESET EMERGENCY STATES
  // ============================================================

  Future<void> clearEmergencyStates({
    required String elderId,
  }) async {
    await updateStatus(
      elderId: elderId,
      sosActive: false,
      fallDetected: false,
    );
  }
}