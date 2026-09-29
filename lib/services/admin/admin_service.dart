import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ============================================================
  // REAL-TIME SYSTEM METRICS
  // ============================================================

  Stream<Map<String, dynamic>> streamSystemMetrics() {
    return _db.collection('users').snapshots().asyncMap((usersSnap) async {
      final circlesSnap = await _db.collection('careCircles').get();

      final alertsSnap = await _db
          .collection('alerts')
          .where('status', isEqualTo: 'active')
          .get();

      int elders = 0;
      int caregivers = 0;
      int admins = 0;

      for (final doc in usersSnap.docs) {
        final role = doc.data()['role'];

        if (role == 'elder') {
          elders++;
        } else if (role == 'caregiver') {
          caregivers++;
        } else if (role == 'admin') {
          admins++;
        }
      }

      return {
        'totalElders': elders,
        'totalCaregivers': caregivers,
        'totalAdmins': admins,
        'activeCircles': circlesSnap.docs.length,
        'pendingAlerts': alertsSnap.docs.length,
      };
    });
  }

  // ============================================================
  // USERS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> streamUsers({
    String? roleFilter,
  }) {
    Query<Map<String, dynamic>> query =
        _db.collection('users');

    if (roleFilter != null && roleFilter != 'all') {
      query = query.where(
        'role',
        isEqualTo: roleFilter,
      );
    }

    return query.snapshots();
  }

  // ============================================================
  // CARE CIRCLES
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> streamCareCircles() {
    return _db.collection('careCircles').snapshots();
  }

  // ============================================================
  // SYSTEM ALERTS
  // ============================================================

  Stream<QuerySnapshot<Map<String, dynamic>>> streamActiveAlerts() {
    return _db.collection('alerts').snapshots();
  }

  // ============================================================
  // USER ROLE MANAGEMENT
  // ============================================================

  Future<void> updateUserRole(
    String uid,
    String newRole,
  ) async {
    const allowedRoles = [
      'admin',
      'caregiver',
      'elder',
    ];

    if (!allowedRoles.contains(newRole)) {
      throw ArgumentError(
        'Invalid user role: $newRole',
      );
    }

    await _db
        .collection('users')
        .doc(uid)
        .update({
      'role': newRole,
    });
  }

  // ============================================================
  // ACCOUNT STATUS
  // ============================================================

  Future<void> toggleUserAccountStatus(
    String uid,
    bool isEnabled,
  ) async {
    await _db
        .collection('users')
        .doc(uid)
        .update({
      'disabled': !isEnabled,
    });
  }

  // ============================================================
  // EMERGENCY ALERT MANAGEMENT
  // ============================================================

  Future<void> resolveEmergencyAlert(
    String alertId,
  ) async {
    await _db
        .collection('alerts')
        .doc(alertId)
        .update({
      'status': 'resolved_by_admin',
      'resolvedAt':
          FieldValue.serverTimestamp(),
    });
  }
}