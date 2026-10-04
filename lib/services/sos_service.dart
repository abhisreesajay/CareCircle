import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../models/sos_record.dart';
import 'location_service.dart';

class SosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================
  // GET CURRENT LOCATION
  // ============================================================

  /// Gets the current GPS location once.
  /// This does not continuously track the user.
  Future<Position> getCurrentLocation() async {
    final Position? position =
        await LocationService.getCurrentLocation();

    if (position == null) {
      throw Exception(
        'Could not get current location. '
        'Please enable GPS and location permission.',
      );
    }

    return position;
  }

  // ============================================================
  // CREATE SOS
  // ============================================================

  Future<SosRecord> createSos({
    required String userId,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required to create an SOS.');
    }

    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('You must be logged in to create an SOS.');
    }

    if (currentUser.uid != userId) {
      throw Exception('You can only create an SOS for your own account.');
    }

    // Get the current location.
    final Position position = await getCurrentLocation();

    // Prepare the SOS document.
    final DocumentReference<Map<String, dynamic>> sosDocument =
        _firestore.collection('sosAlerts').doc();

    // Prepare the corresponding caregiver alert.
    final DocumentReference<Map<String, dynamic>> alertDocument =
        _firestore
            .collection('elders')
            .doc(userId)
            .collection('alerts')
            .doc();

    final DateTime now = DateTime.now();

    final SosRecord sos = SosRecord(
      id: sosDocument.id,
      userId: currentUser.uid,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: now,
      status: 'ACTIVE',
    );

    final Map<String, dynamic> sosData = sos.toMap();

    sosData['createdAt'] = FieldValue.serverTimestamp();

    final Map<String, dynamic> alertData = {
      'title': 'Emergency SOS',
      'message':
          'The elder has triggered an emergency SOS. '
          'Immediate attention may be required.',
      'date': _formatCurrentDateTime(),
      'type': 'sos',
      'elderId': userId,
      'sosId': sosDocument.id,
      'latitude': position.latitude,
      'longitude': position.longitude,

      // Nested caregiver alerts use lowercase statuses.
      'status': 'active',

      'createdAt': FieldValue.serverTimestamp(),
    };

    // Both documents are written atomically.
    // If either write fails, neither document is created.
    final WriteBatch batch = _firestore.batch();

    batch.set(sosDocument, sosData);
    batch.set(alertDocument, alertData);

    await batch.commit();

    return sos;
  }

  // ============================================================
  // GET ACTIVE SOS
  // ============================================================

  Future<SosRecord?> getActiveSos({
    required String userId,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception('User ID is required to find an active SOS.');
    }

    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('You must be logged in to find an active SOS.');
    }

    if (currentUser.uid != userId) {
      throw Exception('You can only view your own active SOS records.');
    }

    final QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore
            .collection('sosAlerts')
            .where('userId', isEqualTo: currentUser.uid)
            .where('status', isEqualTo: 'ACTIVE')
            .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final documents = querySnapshot.docs.toList();

    // Sort newest to oldest.
    documents.sort((a, b) {
      final DateTime? aDate =
          _convertTimestampToDateTime(a.data()['timestamp']);

      final DateTime? bDate =
          _convertTimestampToDateTime(b.data()['timestamp']);

      if (aDate == null && bDate == null) return 0;
      if (aDate == null) return 1;
      if (bDate == null) return -1;

      return bDate.compareTo(aDate);
    });

    return SosRecord.fromMap(
      documents.first.id,
      documents.first.data(),
    );
  }
  
  // ============================================================
  // CANCEL SOS
  // ============================================================

  Future<void> cancelSos(String sosId) async {
    if (sosId.trim().isEmpty) {
      throw Exception('SOS ID is required to cancel an SOS.');
    }

    final User? currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw Exception('You must be logged in to cancel an SOS.');
    }

    final DocumentReference<Map<String, dynamic>> sosDocument =
        _firestore.collection('sosAlerts').doc(sosId);

    final DocumentSnapshot<Map<String, dynamic>> snapshot =
        await sosDocument.get();

    if (!snapshot.exists) {
      throw Exception('SOS record was not found.');
    }

    final Map<String, dynamic>? data = snapshot.data();

    if (data == null) {
      throw Exception('SOS record data is unavailable.');
    }

    final String recordUserId = data['userId'] as String? ?? '';

    if (recordUserId != currentUser.uid) {
      throw Exception('You can only cancel your own SOS.');
    }

    final String status = data['status'] as String? ?? '';

    if (status != 'ACTIVE') {
      throw Exception('This SOS is not currently active.');
    }

    // Find all caregiver alerts associated with this SOS.
    final QuerySnapshot<Map<String, dynamic>> alertSnapshot =
        await _firestore
            .collection('elders')
            .doc(currentUser.uid)
            .collection('alerts')
            .where('sosId', isEqualTo: sosId)
            .where('type', isEqualTo: 'sos')
            .get();

    // Update the SOS record and all matching caregiver alerts
    // in a single atomic batch.
    final WriteBatch batch = _firestore.batch();

    batch.update(sosDocument, {
      'status': 'CANCELLED',
      'cancelledAt': FieldValue.serverTimestamp(),
    });

    for (final alertDocument in alertSnapshot.docs) {
      batch.update(alertDocument.reference, {
        'status': 'cancelled',
        'message': 'The emergency SOS was cancelled by the elder.',
        'cancelledAt': FieldValue.serverTimestamp(),
      });
    }

    // Commit even if no caregiver alert was found:
    // the SOS record itself still needs to be cancelled.
    await batch.commit();
  }

  // ============================================================
  // FORMAT ALERT DATE
  // ============================================================

  String _formatCurrentDateTime() {
    final DateTime now = DateTime.now();

    final String date =
        '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';

    final String time =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';

    return '$date at $time';
  }

  // ============================================================
  // TIMESTAMP CONVERSION
  // ============================================================

  DateTime? _convertTimestampToDateTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }

    if (timestamp is DateTime) {
      return timestamp;
    }

    return null;
  }
}