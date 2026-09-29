import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Real-time system metrics
  Stream<Map<String, dynamic>> streamSystemMetrics() {
    return _db.collection('users').snapshots().asyncMap((usersSnap) async {
      final circlesSnap = await _db.collection('care_circles').get();
      final alertsSnap = await _db.collection('alerts').where('status', isEqualTo: 'active').get();

      int elders = 0;
      int caregivers = 0;
      int admins = 0;
      for (var doc in usersSnap.docs) {
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

  // Stream all registered users
  Stream<QuerySnapshot> streamUsers({String? roleFilter}) {
    Query query = _db.collection('users');
    if (roleFilter != null && roleFilter != 'all') {
      query = query.where('role', isEqualTo: roleFilter);
    }
    return query.snapshots();
  }

  // Stream all Care Circles
  Stream<QuerySnapshot> streamCareCircles() {
    return _db.collection('care_circles').snapshots();
  }

  // Stream platform-wide emergency alerts
  Stream<QuerySnapshot> streamActiveAlerts() {
    return _db.collection('alerts').snapshots();
  }

  // User Actions
  Future<void> updateUserRole(String uid, String newRole) async {
    await _db.collection('users').doc(uid).update({'role': newRole});
  }

  Future<void> toggleUserAccountStatus(String uid, bool isEnabled) async {
    await _db.collection('users').doc(uid).update({'disabled': !isEnabled});
  }

  // Emergency Override: Resolve an active alert directly from Admin UI
  Future<void> resolveEmergencyAlert(String alertId) async {
    await _db.collection('alerts').doc(alertId).update({
      'status': 'resolved_by_admin',
      'resolvedAt': FieldValue.serverTimestamp(),
    });
  }
}
