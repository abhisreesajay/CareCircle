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
  //
  // Gets the user's current GPS location only once.
  //
  // This does not continuously track the user.
  //
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
  //
  // Creates and saves a new ACTIVE SOS record in Firestore.
  //
  // The supplied userId must match the currently logged-in user.
  //
  // The SOS record also includes the user's medical information
  // if it exists in:
  //
  // medicalInformation/{userId}
  //
  Future<SosRecord> createSos({
    required String userId,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception(
        'User ID is required to create an SOS.',
      );
    }

    // Get the currently logged-in Firebase user.
    final User? currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        'You must be logged in to create an SOS.',
      );
    }

    // Security check:
    // Do not allow one user to create an SOS
    // for another user.
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
    //
    // If no medical information exists, an empty
    // map will be stored in the SOS record.
    final Map<String, dynamic>?
        medicalInformation =
        await _medicalService
            .getMedicalInformation(userId);

    // Create a new Firestore document with
    // an automatically generated ID.
    final DocumentReference<
        Map<String, dynamic>> doc =
        _firestore
            .collection('sosRecords')
            .doc();

    // Create the SOS model.
    final SosRecord sos = SosRecord(
      id: doc.id,
      userId: currentUser.uid,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
      status: 'ACTIVE',
    );

    // Convert the SOS model into a map.
    final Map<String, dynamic> sosData =
        sos.toMap();

    // Add extra information to the SOS record.
    //
    // These fields are useful for the caregiver
    // and for the future notification backend.
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
  //
  // Gets the latest ACTIVE SOS record created
  // by a specific user.
  //
  Future<SosRecord?> getActiveSos({
    required String userId,
  }) async {
    if (userId.trim().isEmpty) {
      throw Exception(
        'User ID is required to find an active SOS.',
      );
    }

    // Get the currently logged-in Firebase user.
    final User? currentUser =
        _auth.currentUser;

    if (currentUser == null) {
      throw Exception(
        'You must be logged in to find an active SOS.',
      );
    }

    // Security check:
    // A user can only check their own active
    // SOS records.
    if (currentUser.uid != userId) {
      throw Exception(
        'You can only view your own active SOS records.',
      );
    }

    final QuerySnapshot<
        Map<String, dynamic>> querySnapshot =
        await _firestore
            .collection('sosRecords')
            .where(
              'userId',
              isEqualTo: currentUser.uid,
            )
            .where(
              'status',
              isEqualTo: 'ACTIVE',
            )
            .get();

    // No active SOS exists.
    if (querySnapshot.docs.isEmpty) {
      return null;
    }

    final List<
        QueryDocumentSnapshot<
            Map<String, dynamic>>> documents =
        List<
            QueryDocumentSnapshot<
                Map<String, dynamic>>>.from(
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

      // If both timestamps are unavailable,
      // keep their order.
      if (aDate == null && bDate == null) {
        return 0;
      }

      // Records without timestamps go last.
      if (aDate == null) {
        return 1;
      }

      if (bDate == null) {
        return -1;
      }

      // Newest record first.
      return bDate.compareTo(aDate);
    });

    final QueryDocumentSnapshot<
        Map<String, dynamic>> latestDocument =
        documents.first;

    return SosRecord.fromMap(
      latestDocument.id,
      latestDocument.data(),
    );
  }

  // ------------------------------------------------------------
  // GET SOS MEDICAL INFORMATION
  // ------------------------------------------------------------
  //
  // Retrieves the medical information saved inside
  // a particular SOS record.
  //
  // This can be used by the caregiver dashboard.
  //
  Future<Map<String, dynamic>> getSosMedicalInformation(
    String sosId,
  ) async {
    if (sosId.trim().isEmpty) {
      throw Exception(
        'SOS ID is required.',
      );
    }

    final DocumentSnapshot<
        Map<String, dynamic>> snapshot =
        await _firestore
            .collection('sosRecords')
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
  //
  // Updates the active SOS status to CANCELLED.
  //
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

    // Get the SOS document first so that
    // ownership can be verified.
    final DocumentReference<
        Map<String, dynamic>> sosDocument =
        _firestore
            .collection('sosRecords')
            .doc(sosId);

    final DocumentSnapshot<
        Map<String, dynamic>> snapshot =
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

    // Security check:
    // Only the user who created the SOS
    // can cancel it.
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
  //
  // Converts Firestore Timestamp or DateTime
  // into DateTime.
  //
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