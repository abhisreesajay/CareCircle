import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';

import '../models/sos_record.dart';
import 'location_service.dart';
import 'medical_service.dart';

class SosService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  final MedicalService _medicalService =
      MedicalService();

  // ------------------------------------------------------------
  // GET CURRENT LOCATION
  // ------------------------------------------------------------

  // Gets the user's current GPS location only once.
  //
  // This does not continuously track the user.
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

  // ------------------------------------------------------------
  // CREATE SOS
  // ------------------------------------------------------------

  Future<SosRecord> createSos({
    required String userId,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception(
        'User ID is required to create an SOS.',
      );
    }

    final User? currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        'You must be logged in to create an SOS.',
      );
    }

    // A user can only create an SOS for their own account.
    if (currentUser.uid != userId) {
      throw Exception(
        'You can only create an SOS for your own account.',
      );
    }

    // Get the current location before creating
    // the SOS record.
    final Position position =
        await getCurrentLocation();

    // Retrieve medical information.
    final Map<String, dynamic>? medicalInformation =
        await _medicalService
            .getMedicalInformation(userId);

    // Create a new document inside sosAlerts.
    final DocumentReference<Map<String, dynamic>> doc =
        _firestore
            .collection('sosAlerts')
            .doc();

    final SosRecord sos = SosRecord(
      id: doc.id,
      userId: currentUser.uid,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
      status: 'ACTIVE',
    );

    final Map<String, dynamic> sosData =
        sos.toMap();

    sosData['createdAt'] =
        FieldValue.serverTimestamp();

    sosData['medicalInformation'] =
        medicalInformation ?? {};

    // Save the SOS record.
    await doc.set(sosData);

    return sos;
  }

  // ------------------------------------------------------------
  // GET ACTIVE SOS
  // ------------------------------------------------------------

  Future<SosRecord?> getActiveSos({
    required String userId,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception(
        'User ID is required to find an active SOS.',
      );
    }

    final User? currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        'You must be logged in to find an active SOS.',
      );
    }

    if (currentUser.uid != userId) {
      throw Exception(
        'You can only view your own active SOS records.',
      );
    }

    final QuerySnapshot<Map<String, dynamic>>
        querySnapshot =
        await _firestore
            .collection('sosAlerts')
            .where(
              'userId',
              isEqualTo: currentUser.uid,
            )
            .where(
              'status',
              isEqualTo: 'ACTIVE',
            )
            .get();

    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final List<QueryDocumentSnapshot<Map<String, dynamic>>>
        documents =
        List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
      querySnapshot.docs,
    );

    // Sort SOS records from newest to oldest.
    documents.sort((a, b) {
      final dynamic aTimestamp =
          a.data()['timestamp'];

      final dynamic bTimestamp =
          b.data()['timestamp'];

      final DateTime? aDate =
          _convertTimestampToDateTime(
        aTimestamp,
      );

      final DateTime? bDate =
          _convertTimestampToDateTime(
        bTimestamp,
      );

      if (aDate == null && bDate == null) {
        return 0;
      }

      if (aDate == null) {
        return 1;
      }

      if (bDate == null) {
        return -1;
      }

      return bDate.compareTo(aDate);
    });

    final QueryDocumentSnapshot<Map<String, dynamic>>
        latestDocument =
        documents.first;

    return SosRecord.fromMap(
      latestDocument.id,
      latestDocument.data(),
    );
  }

  // ------------------------------------------------------------
  // GET SOS MEDICAL INFORMATION
  // ------------------------------------------------------------

  Future<Map<String, dynamic>> getSosMedicalInformation(
    String sosId,
  ) async {
    if (sosId.trim().isEmpty) {
      throw Exception(
        'SOS ID is required.',
      );
    }

    final DocumentSnapshot<Map<String, dynamic>>
        snapshot =
        await _firestore
            .collection('sosAlerts')
            .doc(sosId)
            .get();

    if (!snapshot.exists) {
      throw Exception(
        'SOS record was not found.',
      );
    }

    final Map<String, dynamic>? data =
        snapshot.data();

    if (data == null) {
      throw Exception(
        'SOS record data is unavailable.',
      );
    }

    final dynamic medicalData =
        data['medicalInformation'];

    if (medicalData is Map<String, dynamic>) {
      return medicalData;
    }

    return {};
  }

  // ------------------------------------------------------------
  // CANCEL SOS
  // ------------------------------------------------------------

  Future<void> cancelSos(String sosId) async {
    if (sosId.trim().isEmpty) {
      throw Exception(
        'SOS ID is required to cancel an SOS.',
      );
    }

    final User? currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        'You must be logged in to cancel an SOS.',
      );
    }

    final DocumentReference<Map<String, dynamic>>
        sosDocument =
        _firestore
            .collection('sosAlerts')
            .doc(sosId);

    final DocumentSnapshot<Map<String, dynamic>>
        snapshot =
        await sosDocument.get();

    if (!snapshot.exists) {
      throw Exception(
        'SOS record was not found.',
      );
    }

    final Map<String, dynamic>? data =
        snapshot.data();

    if (data == null) {
      throw Exception(
        'SOS record data is unavailable.',
      );
    }

    final String recordUserId =
        data['userId'] as String? ?? '';

    if (recordUserId != currentUser.uid) {
      throw Exception(
        'You can only cancel your own SOS.',
      );
    }

    final String status =
        data['status'] as String? ?? '';

    if (status != 'ACTIVE') {
      throw Exception(
        'This SOS is not currently active.',
      );
    }

    await sosDocument.update({
      'status': 'CANCELLED',
      'cancelledAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ------------------------------------------------------------
  // TIMESTAMP CONVERSION HELPER
  // ------------------------------------------------------------

  DateTime? _convertTimestampToDateTime(
    dynamic timestamp,
  ) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    }

    if (timestamp is DateTime) {
      return timestamp;
    }

    return null;
  }
}