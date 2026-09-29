import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/safe_zone.dart';
import 'location_service.dart';

class SafeZoneService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // ============================================================
  // CREATE SAFE ZONE
  // ============================================================

  Future<void> createSafeZone(
    SafeZone safeZone,
  ) async {
    final CollectionReference<Map<String, dynamic>> collection =
        _firestore.collection('safeZones');

    final DocumentReference<Map<String, dynamic>> document =
        safeZone.id.trim().isEmpty
            ? collection.doc()
            : collection.doc(safeZone.id);

    await document.set(
      safeZone.toMap(),
    );
  }

  // ============================================================
  // GET SAFE ZONES FOR AN ELDER
  // ============================================================

  Future<List<SafeZone>> getSafeZones(
    String elderId,
  ) async {
    final String normalizedElderId =
        elderId.trim();

    if (normalizedElderId.isEmpty) {
      throw Exception(
        'Elder ID is required.',
      );
    }

    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _firestore
            .collection('safeZones')
            .where(
              'elderId',
              isEqualTo: normalizedElderId,
            )
            .get();

    return snapshot.docs
        .map(
          (doc) => SafeZone.fromMap(
            doc.id,
            doc.data(),
          ),
        )
        .toList();
  }

  // ============================================================
  // DELETE SAFE ZONE
  // ============================================================

  Future<void> cancelSafeZone(
    String safeZoneId,
  ) async {
    final String normalizedSafeZoneId =
        safeZoneId.trim();

    if (normalizedSafeZoneId.isEmpty) {
      throw Exception(
        'Safe zone ID is required.',
      );
    }

    await _firestore
        .collection('safeZones')
        .doc(normalizedSafeZoneId)
        .delete();
  }

  // ============================================================
  // ONE-TIME LOCATION CHECK
  // ============================================================

  Future<void> checkCurrentLocation(
    String elderId,
  ) async {
    final String normalizedElderId =
        elderId.trim();

    if (normalizedElderId.isEmpty) {
      throw Exception(
        'Elder ID is required.',
      );
    }

    final position =
        await LocationService.getCurrentLocation();

    if (position == null) {
      throw Exception(
        'Unable to get current location. '
        'Please make sure GPS is enabled and '
        'location permission is granted.',
      );
    }

    final List<SafeZone> safeZones =
        await getSafeZones(
      normalizedElderId,
    );

    if (safeZones.isEmpty) {
      return;
    }

    bool isInsideAnyZone = false;

    for (final SafeZone safeZone in safeZones) {
      final double distanceInMeters =
          _calculateDistanceInMeters(
        position.latitude,
        position.longitude,
        safeZone.latitude,
        safeZone.longitude,
      );

      if (distanceInMeters <=
          safeZone.radiusInMeters) {
        isInsideAnyZone = true;
        break;
      }
    }

    // Elder is inside at least one safe zone.
    if (isInsideAnyZone) {
      return;
    }

    // Elder is outside every safe zone.
    for (final SafeZone safeZone in safeZones) {
      final double distanceInMeters =
          _calculateDistanceInMeters(
        position.latitude,
        position.longitude,
        safeZone.latitude,
        safeZone.longitude,
      );

      await _createSafeZoneViolation(
        elderId: normalizedElderId,
        safeZone: safeZone,
        latitude: position.latitude,
        longitude: position.longitude,
        distanceInMeters: distanceInMeters,
      );
    }
  }

  // ============================================================
  // PUBLIC SAFE-ZONE VIOLATION CREATION
  // ============================================================

  Future<void> createSafeZoneViolation({
    required String elderId,
    required SafeZone safeZone,
    required double latitude,
    required double longitude,
    required double distanceInMeters,
  }) async {
    final String normalizedElderId =
        elderId.trim();

    if (normalizedElderId.isEmpty) {
      throw Exception(
        'Elder ID is required.',
      );
    }

    await _createSafeZoneViolation(
      elderId: normalizedElderId,
      safeZone: safeZone,
      latitude: latitude,
      longitude: longitude,
      distanceInMeters: distanceInMeters,
    );
  }

  // ============================================================
  // CREATE SAFE-ZONE VIOLATION + ALERT
  // ============================================================

  Future<void> _createSafeZoneViolation({
    required String elderId,
    required SafeZone safeZone,
    required double latitude,
    required double longitude,
    required double distanceInMeters,
  }) async {
    // ----------------------------------------------------------
    // 1. CREATE SAFE-ZONE VIOLATION RECORD
    // ----------------------------------------------------------

    final CollectionReference<Map<String, dynamic>>
        violationCollection =
        _firestore.collection('safeZoneViolations');

    final DocumentReference<Map<String, dynamic>>
        violationDocument =
        violationCollection.doc();

    await violationDocument.set({
      'violationId': violationDocument.id,

      'elderId': elderId,

      'safeZoneId': safeZone.id,
      'safeZoneName': safeZone.name,

      'latitude': latitude,
      'longitude': longitude,

      'safeZoneLatitude': safeZone.latitude,
      'safeZoneLongitude': safeZone.longitude,

      'distanceInMeters': distanceInMeters,

      'timestamp':
          FieldValue.serverTimestamp(),

      'status': 'OUTSIDE',

      'createdAt':
          FieldValue.serverTimestamp(),
    });

    // ----------------------------------------------------------
    // 2. CREATE CAREGIVER ALERT
    // ----------------------------------------------------------

    final CollectionReference<Map<String, dynamic>>
        alertCollection =
        _firestore
            .collection('elders')
            .doc(elderId)
            .collection('alerts');

    final DocumentReference<Map<String, dynamic>>
        alertDocument =
        alertCollection.doc();

    await alertDocument.set({
      'title': 'Safe Zone Alert',

      'message':
          'Elder is outside the safe zone "${safeZone.name}". '
          'Current distance: ${distanceInMeters.toStringAsFixed(0)} meters.',

      'date': _formatCurrentDateTime(),

      'type': 'safe_zone',

      'elderId': elderId,

      'safeZoneId': safeZone.id,

      'safeZoneName': safeZone.name,

      'latitude': latitude,

      'longitude': longitude,

      'distanceInMeters': distanceInMeters,

      'status': 'ACTIVE',

      'createdAt':
          FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // FORMAT ALERT DATE
  // ============================================================

  String _formatCurrentDateTime() {
    final DateTime now =
        DateTime.now();

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
  // HAVERSINE DISTANCE
  // ============================================================

  double _calculateDistanceInMeters(
    double latitude1,
    double longitude1,
    double latitude2,
    double longitude2,
  ) {
    const double earthRadiusInMeters =
        6371000.0;

    final double latitude1Radians =
        _degreesToRadians(latitude1);

    final double latitude2Radians =
        _degreesToRadians(latitude2);

    final double latitudeDifferenceRadians =
        _degreesToRadians(
      latitude2 - latitude1,
    );

    final double longitudeDifferenceRadians =
        _degreesToRadians(
      longitude2 - longitude1,
    );

    final double sinLatitude =
        math.sin(
      latitudeDifferenceRadians / 2,
    );

    final double sinLongitude =
        math.sin(
      longitudeDifferenceRadians / 2,
    );

    final double a =
        (sinLatitude * sinLatitude) +
            math.cos(latitude1Radians) *
                math.cos(latitude2Radians) *
                (sinLongitude *
                    sinLongitude);

    final double safeA =
        a.clamp(0.0, 1.0);

    final double c =
        2 *
            math.atan2(
              math.sqrt(safeA),
              math.sqrt(1 - safeA),
            );

    return earthRadiusInMeters * c;
  }

  double _degreesToRadians(
    double degrees,
  ) {
    return degrees *
        math.pi /
        180.0;
  }
}