import 'package:cloud_firestore/cloud_firestore.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ------------------------------------------------------------
  // SYSTEM METRICS
  // ------------------------------------------------------------

  /// Streams user metrics and the current number of active alerts.
  ///
  /// Note: Metrics recalculate when the users collection changes.
  /// For independently live alert counts, use streamActiveAlerts().
  Stream<Map<String, dynamic>> streamSystemMetrics() {
    return _db.collection('users').snapshots().asyncMap((usersSnap) async {
      final alertsSnap = await _db
          .collectionGroup('alerts')
          .where('status', isEqualTo: 'active')
          .get();

      int elders = 0;
      int caregivers = 0;
      int admins = 0;
      int activeCircles = 0;

      for (final doc in usersSnap.docs) {
        final data = doc.data();
        final role = data['role'];

        switch (role) {
          case 'elder':
            elders++;

            final rawCaregivers = data['caregivers'];
            if (rawCaregivers is List &&
                rawCaregivers.whereType<String>().isNotEmpty) {
              activeCircles++;
            }
            break;

          case 'caregiver':
            caregivers++;
            break;

          case 'admin':
            admins++;
            break;
        }
      }

      return {
        'totalElders': elders,
        'totalCaregivers': caregivers,
        'totalAdmins': admins,
        'activeCircles': activeCircles,
        'pendingAlerts': alertsSnap.docs.length,
      };
    });
  }

  // ------------------------------------------------------------
  // USER MANAGEMENT
  // ------------------------------------------------------------

  /// Streams all users, or users matching a specific role.
  ///
  /// Supported role filters: admin, caregiver, elder, all, null.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamUsers({
    String? roleFilter,
  }) {
    Query<Map<String, dynamic>> query = _db.collection('users');

    if (roleFilter != null && roleFilter != 'all') {
      const allowedRoles = ['admin', 'caregiver', 'elder'];

      if (!allowedRoles.contains(roleFilter)) {
        throw ArgumentError('Invalid role filter: $roleFilter');
      }

      query = query.where('role', isEqualTo: roleFilter);
    }

    return query.snapshots();
  }

  /// Updates a user's role.
  ///
  /// This validates the role value, but it does not enforce a
  /// last-admin safeguard. Add that protection in the admin UI or
  /// in a trusted backend if required.
  Future<void> updateUserRole(String uid, String newRole) async {
    if (uid.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }

    const allowedRoles = ['admin', 'caregiver', 'elder'];

    if (!allowedRoles.contains(newRole)) {
      throw ArgumentError('Invalid user role: $newRole');
    }

    await _db.collection('users').doc(uid).update({
      'role': newRole,
    });
  }

  /// Sets the Firestore disabled flag.
  ///
  /// This does not disable the Firebase Authentication account itself.
  Future<void> toggleUserAccountStatus(
    String uid,
    bool isEnabled,
  ) async {
    if (uid.trim().isEmpty) {
      throw ArgumentError('User ID cannot be empty.');
    }

    await _db.collection('users').doc(uid).update({
      'disabled': !isEnabled,
    });
  }

  // ------------------------------------------------------------
  // CARE CIRCLES
  // ------------------------------------------------------------

  /// Creates a read-only live view of Care Circles using:
  ///
  /// users/{elderId}.caregivers
  ///
  /// No separate careCircles collection is required.
  Stream<List<Map<String, dynamic>>> streamCareCircles() {
    return _db.collection('users').snapshots().map((usersSnap) {
      final users = <String, Map<String, dynamic>>{};

      for (final doc in usersSnap.docs) {
        users[doc.id] = {
          ...doc.data(),
          'uid': doc.id,
        };
      }

      final circles = <Map<String, dynamic>>[];

      for (final entry in users.entries) {
        final elderId = entry.key;
        final elderData = entry.value;

        if (elderData['role'] != 'elder') {
          continue;
        }

        final rawCaregivers = elderData['caregivers'];
        final caregiverIds = rawCaregivers is List
            ? rawCaregivers.whereType<String>().toSet().toList()
            : <String>[];

        if (caregiverIds.isEmpty) {
          continue;
        }

        final caregiverDetails = <Map<String, dynamic>>[];

        for (final caregiverId in caregiverIds) {
          final caregiverData = users[caregiverId];

          if (caregiverData == null ||
              caregiverData['role'] != 'caregiver') {
            caregiverDetails.add({
              'uid': caregiverId,
              'name': 'Unknown Caregiver',
              'email': '',
            });
            continue;
          }

          caregiverDetails.add({
            'uid': caregiverId,
            'name': caregiverData['name'] ?? 'Unnamed Caregiver',
            'email': caregiverData['email'] ?? '',
          });
        }

        circles.add({
          'elderId': elderId,
          'elderName': elderData['name'] ?? 'Unnamed Elder',
          'caregiverIds': caregiverIds,
          'caregivers': caregiverDetails,
        });
      }

      return circles;
    });
  }

  // ------------------------------------------------------------
  // ALERTS
  // ------------------------------------------------------------

  /// Streams currently active alerts across alert subcollections.
  ///
  /// Alert documents should use lowercase status: 'active'.
  Stream<QuerySnapshot<Map<String, dynamic>>> streamActiveAlerts() {
    return _db
        .collectionGroup('alerts')
        .where('status', isEqualTo: 'active')
        .snapshots();
  }

  /// Resolves an emergency alert from the admin dashboard.
  ///
  /// Updates the nested caregiver alert and, when the alert references
  /// an active SOS, updates the corresponding top-level SOS record.
  ///
  /// SOS records keep uppercase statuses (ACTIVE, RESOLVED, CANCELLED).
  /// Nested caregiver alerts use lowercase statuses.
  Future<void> resolveEmergencyAlert({
    required String elderId,
    required String alertId,
  }) async {
    if (elderId.trim().isEmpty || alertId.trim().isEmpty) {
      throw ArgumentError('Elder ID and alert ID are required.');
    }

    final alertRef = _db
        .collection('elders')
        .doc(elderId)
        .collection('alerts')
        .doc(alertId);

    final alertSnapshot = await alertRef.get();

    if (!alertSnapshot.exists) {
      throw Exception('The emergency alert no longer exists.');
    }

    final alertData = alertSnapshot.data() ?? {};
    final currentAlertStatus =
        alertData['status']?.toString().toLowerCase();

    if (currentAlertStatus == 'resolved' ||
        currentAlertStatus == 'resolved_by_admin' ||
        currentAlertStatus == 'cancelled') {
      throw Exception('This alert has already been closed.');
    }

    final String? sosId = alertData['sosId']?.toString();
    final batch = _db.batch();

    batch.update(alertRef, {
      'status': 'resolved_by_admin',
      'resolvedAt': FieldValue.serverTimestamp(),
    });

    if (sosId != null && sosId.trim().isNotEmpty) {
      final sosRef = _db.collection('sosAlerts').doc(sosId);
      final sosSnapshot = await sosRef.get();

      if (sosSnapshot.exists) {
        final sosData = sosSnapshot.data() ?? {};

        if (sosData['status'] == 'ACTIVE') {
          batch.update(sosRef, {
            'status': 'RESOLVED',
            'resolvedAt': FieldValue.serverTimestamp(),
            'resolvedBy': 'admin',
          });
        }
      }
    }

    await batch.commit();
  }
}