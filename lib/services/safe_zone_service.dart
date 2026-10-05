import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/safe_zone.dart';
import 'location_service.dart';

class SafeZoneService {
  SafeZoneService({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _safeZones =>
      _firestore.collection('safeZones');

  CollectionReference<Map<String, dynamic>> get _violations =>
      _firestore.collection('safeZoneViolations');

  CollectionReference<Map<String, dynamic>> _elderAlerts(
    String elderId,
  ) =>
      _firestore.collection('elders').doc(elderId).collection('alerts');

  // ------------------------------------------------------------
  // CREATE SAFE ZONE
  // ------------------------------------------------------------

  Future<String> createSafeZone(SafeZone safeZone) async {
    _validateZone(safeZone);

    final elderId = safeZone.elderId.trim();
    final name = safeZone.name.trim();
    final createdBy = safeZone.createdBy.trim();

    final data = <String, dynamic>{
      ...safeZone.toMap(),
      'elderId': elderId,
      'name': name,
      'createdBy': createdBy,
    };

    final zoneId = safeZone.id.trim();

    if (zoneId.isNotEmpty) {
      await _safeZones.doc(zoneId).set(data);
      debugPrint('SAFE ZONE: Saved zone $zoneId');
      return zoneId;
    }

    final doc = _safeZones.doc();
    await doc.set(data);

    debugPrint('SAFE ZONE: Created zone ${doc.id}');
    return doc.id;
  }

  // ------------------------------------------------------------
  // GET SAFE ZONES
  // ------------------------------------------------------------

  Stream<List<SafeZone>> getSafeZones(String elderId) {
    final id = elderId.trim();

    if (id.isEmpty) {
      return Stream.error(
        ArgumentError('Elder ID cannot be empty.'),
      );
    }

    return _safeZones
        .where('elderId', isEqualTo: id)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SafeZone.fromMap(doc.id, doc.data()))
              .toList(),
        );
  }

  Future<List<SafeZone>> getSafeZonesOnce(String elderId) async {
    final id = elderId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Elder ID cannot be empty.');
    }

    final snapshot =
        await _safeZones.where('elderId', isEqualTo: id).get();

    return snapshot.docs
        .map((doc) => SafeZone.fromMap(doc.id, doc.data()))
        .toList();
  }

  // ------------------------------------------------------------
  // DELETE SAFE ZONE
  // ------------------------------------------------------------

  Future<void> cancelSafeZone(String safeZoneId) async {
    final id = safeZoneId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Safe zone ID cannot be empty.');
    }

    await _safeZones.doc(id).delete();

    debugPrint('SAFE ZONE: Deleted zone $id');
  }

  // ------------------------------------------------------------
  // CHECK CURRENT LOCATION AGAINST ALL ZONES
  // ------------------------------------------------------------

  Future<void> checkCurrentLocation(String elderId) async {
    final id = elderId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Elder ID cannot be empty.');
    }

    debugPrint('SAFE ZONE: Starting check for elder $id');

    final position = await LocationService.getCurrentLocation();

    if (position == null) {
      debugPrint('SAFE ZONE: Current location is null');
      throw StateError('Could not get the current location.');
    }

    debugPrint(
      'SAFE ZONE: Current position = '
      '${position.latitude}, ${position.longitude}',
    );

    final zones = await getSafeZonesOnce(id);

    debugPrint('SAFE ZONE: Zones found = ${zones.length}');

    if (zones.isEmpty) {
      debugPrint('SAFE ZONE: No configured zones for elder $id');
      return;
    }

    for (final zone in zones) {
      debugPrint('SAFE ZONE: Checking zone "${zone.name}"');
      debugPrint('SAFE ZONE: Zone ID = ${zone.id}');

      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        zone.latitude,
        zone.longitude,
      );

      final outside = distance > zone.radiusInMeters;

      debugPrint(
        'SAFE ZONE: Distance = ${distance.toStringAsFixed(2)} m',
      );
      debugPrint('SAFE ZONE: Outside zone = $outside');

      await createSafeZoneViolation(
        elderId: id,
        safeZone: zone,
        latitude: position.latitude,
        longitude: position.longitude,
        distanceInMeters: distance,
      );

      debugPrint(
        'SAFE ZONE: Finished processing "${zone.name}"',
      );
    }

    debugPrint('SAFE ZONE: All zone checks completed');
  }

  // ------------------------------------------------------------
  // CREATE OR UPDATE A VIOLATION
  // ------------------------------------------------------------

  Future<void> createSafeZoneViolation({
    required String elderId,
    required SafeZone safeZone,
    required double latitude,
    required double longitude,
    required double distanceInMeters,
  }) async {
    final id = elderId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Elder ID cannot be empty.');
    }

    _validateZone(safeZone);
    _validateCoordinates(latitude, longitude);

    if (!distanceInMeters.isFinite || distanceInMeters < 0) {
      throw ArgumentError(
        'Distance must be a valid non-negative number.',
      );
    }

    if (safeZone.elderId.trim() != id) {
      throw StateError('Safe zone does not belong to this elder.');
    }

    final zoneId = safeZone.id.trim();

    if (zoneId.isEmpty) {
      throw ArgumentError('Safe zone ID cannot be empty.');
    }

    final outside = distanceInMeters > safeZone.radiusInMeters;
    final violationId = _stableViolationId(id, zoneId);
    final stableViolationRef = _violations.doc(violationId);

    debugPrint(
      'SAFE ZONE: Looking up violations for elder $id',
    );

    try {
      // Query by elder ID instead of directly reading a possibly
      // nonexistent document. Firestore rules must allow this
      // query for the signed-in user.
      final matchingViolations = await _violations
          .where('elderId', isEqualTo: id)
          .get();

      QueryDocumentSnapshot<Map<String, dynamic>>? existingDoc;

      for (final doc in matchingViolations.docs) {
        if (doc.data()['safeZoneId'] == zoneId) {
          existingDoc = doc;
          break;
        }
      }

      final existing = existingDoc?.data();
      final existingStatus = existing?['status'] as String?;

      // Reuse the actual existing document if found. Otherwise,
      // use the stable document ID for a new violation.
      final violationRef =
          existingDoc?.reference ?? stableViolationRef;

      debugPrint(
        'SAFE ZONE: Violation path = ${violationRef.path}',
      );
      debugPrint(
        'SAFE ZONE: Existing violation = ${existingDoc != null}',
      );
      debugPrint('SAFE ZONE: Existing status = $existingStatus');
      debugPrint('SAFE ZONE: Current outside status = $outside');

      // --------------------------------------------------------
      // ELDER IS INSIDE THE SAFE ZONE
      // --------------------------------------------------------

      if (!outside) {
        if (existingStatus == 'OUTSIDE') {
          await violationRef.update({
            'status': 'SAFE',
            'resolvedAt': FieldValue.serverTimestamp(),
            'lastCheckedAt': FieldValue.serverTimestamp(),
          });

          debugPrint('SAFE ZONE: Violation marked SAFE');
        } else {
          debugPrint('SAFE ZONE: No active violation to resolve');
        }

        return;
      }

      // --------------------------------------------------------
      // ELDER IS OUTSIDE; UPDATE EXISTING ACTIVE VIOLATION
      // --------------------------------------------------------

      if (existingStatus == 'OUTSIDE') {
        await violationRef.update({
          'latitude': latitude,
          'longitude': longitude,
          'distanceInMeters': distanceInMeters,
          'lastCheckedAt': FieldValue.serverTimestamp(),
        });

        debugPrint(
          'SAFE ZONE: Existing violation location updated',
        );
        return;
      }

      // --------------------------------------------------------
      // ELDER IS OUTSIDE; CREATE OR REOPEN VIOLATION
      // --------------------------------------------------------

      final alertRef = _elderAlerts(id).doc();
      final batch = _firestore.batch();

      final violationData = <String, dynamic>{
        'violationId': violationId,
        'elderId': id,
        'safeZoneId': zoneId,
        'safeZoneName': safeZone.name,
        'latitude': latitude,
        'longitude': longitude,
        'zoneLatitude': safeZone.latitude,
        'zoneLongitude': safeZone.longitude,
        'distanceInMeters': distanceInMeters,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'OUTSIDE',
        'createdAt': FieldValue.serverTimestamp(),
        'lastCheckedAt': FieldValue.serverTimestamp(),
      };

      batch.set(violationRef, violationData);

      batch.set(alertRef, {
        'elderId': id,
        'title': 'Safe Zone Alert',
        'message':
            '${safeZone.name}: the elder is '
            '${distanceInMeters.round()} meters from the zone center, '
            'outside its ${safeZone.radiusInMeters.round()} meter radius.',
        'date': DateTime.now().toIso8601String(),
        'type': 'safe_zone',
        'safeZoneId': zoneId,
        'safeZoneName': safeZone.name,
        'latitude': latitude,
        'longitude': longitude,
        'distanceInMeters': distanceInMeters,
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
      });

      debugPrint(
        'SAFE ZONE: Saving violation at ${violationRef.path}',
      );
      debugPrint('SAFE ZONE: Saving alert at ${alertRef.path}');

      await batch.commit();

      debugPrint(
        'SAFE ZONE: Violation and alert saved successfully',
      );
    } on FirebaseException catch (error, stackTrace) {
      debugPrint(
        'SAFE ZONE FIREBASE ERROR: '
        '${error.code} - ${error.message}',
      );
      debugPrint(
        'SAFE ZONE: Stable violation path = '
        '${stableViolationRef.path}',
      );
      debugPrint('SAFE ZONE STACK TRACE: $stackTrace');

      rethrow;
    } catch (error, stackTrace) {
      debugPrint('SAFE ZONE ERROR: $error');
      debugPrint('SAFE ZONE STACK TRACE: $stackTrace');
      rethrow;
    }
  }

  // ------------------------------------------------------------
  // STABLE VIOLATION DOCUMENT ID
  // ------------------------------------------------------------

  String _stableViolationId(String elderId, String zoneId) =>
      '${elderId.length}_$elderId${zoneId.length}_$zoneId';

  // ------------------------------------------------------------
  // VALIDATION
  // ------------------------------------------------------------

  void _validateZone(SafeZone zone) {
    if (zone.elderId.trim().isEmpty ||
        zone.name.trim().isEmpty ||
        zone.createdBy.trim().isEmpty) {
      throw ArgumentError(
        'Safe zone elder ID, name and creator are required.',
      );
    }

    if (!zone.latitude.isFinite ||
        !zone.longitude.isFinite ||
        zone.latitude < -90 ||
        zone.latitude > 90 ||
        zone.longitude < -180 ||
        zone.longitude > 180) {
      throw ArgumentError('Invalid safe zone coordinates.');
    }

    if (!zone.radiusInMeters.isFinite ||
        zone.radiusInMeters <= 0) {
      throw ArgumentError(
        'Safe zone radius must be positive.',
      );
    }
  }

  void _validateCoordinates(double latitude, double longitude) {
    if (!latitude.isFinite ||
        !longitude.isFinite ||
        latitude < -90 ||
        latitude > 90 ||
        longitude < -180 ||
        longitude > 180) {
      throw ArgumentError('Invalid latitude or longitude.');
    }
  }

  // ------------------------------------------------------------
  // HAVERSINE DISTANCE CALCULATION
  // ------------------------------------------------------------

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const earthRadiusMeters = 6371000.0;

    final dLat = _degreesToRadians(lat2 - lat1);
    final dLon = _degreesToRadians(lon2 - lon1);

    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.pow(math.sin(dLon / 2), 2);

    final clampedA = a.clamp(0.0, 1.0).toDouble();

    return earthRadiusMeters *
        2 *
        math.atan2(
          math.sqrt(clampedA),
          math.sqrt(1 - clampedA),
        );
  }

  double _degreesToRadians(double degrees) =>
      degrees * math.pi / 180;
}