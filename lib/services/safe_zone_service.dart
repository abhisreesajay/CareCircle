
import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';

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

  Future<String> createSafeZone(SafeZone safeZone) async {
    _validateZone(safeZone);

    final elderId = safeZone.elderId.trim();
    final name = safeZone.name.trim();

    final data = <String, dynamic>{
      ...safeZone.toMap(),
      'elderId': elderId,
      'name': name,
      'createdBy': safeZone.createdBy.trim(),
    };

    final zoneId = safeZone.id.trim();

    if (zoneId.isNotEmpty) {
      await _safeZones.doc(zoneId).set(data);
      return zoneId;
    }

    final doc = _safeZones.doc();
    await doc.set(data);
    return doc.id;
  }

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

  Future<void> cancelSafeZone(String safeZoneId) async {
    final id = safeZoneId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Safe zone ID cannot be empty.');
    }

    await _safeZones.doc(id).delete();
  }

  Future<void> checkCurrentLocation(String elderId) async {
    final id = elderId.trim();

    if (id.isEmpty) {
      throw ArgumentError('Elder ID cannot be empty.');
    }

    final position = await LocationService.getCurrentLocation();

    if (position == null) {
      throw StateError('Could not get the current location.');
    }

    final zones = await getSafeZonesOnce(id);

    for (final zone in zones) {
      final distance = _calculateDistance(
        position.latitude,
        position.longitude,
        zone.latitude,
        zone.longitude,
      );

      await createSafeZoneViolation(
        elderId: id,
        safeZone: zone,
        latitude: position.latitude,
        longitude: position.longitude,
        distanceInMeters: distance,
      );
    }
  }

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

    if (safeZone.elderId.trim() != id) {
      throw StateError('Safe zone does not belong to this elder.');
    }

    final outside = distanceInMeters > safeZone.radiusInMeters;
    final violationId = _stableViolationId(id, safeZone.id);
    final violationRef = _violations.doc(violationId);

    final existing = await violationRef.get();
    final wasOutside =
        existing.exists && existing.data()?['status'] == 'OUTSIDE';

    if (!outside) {
      if (wasOutside) {
        await violationRef.update({
          'status': 'SAFE',
          'resolvedAt': FieldValue.serverTimestamp(),
          'lastCheckedAt': FieldValue.serverTimestamp(),
        });
      }
      return;
    }

    if (wasOutside) {
      await violationRef.update({
        'latitude': latitude,
        'longitude': longitude,
        'distanceInMeters': distanceInMeters,
        'lastCheckedAt': FieldValue.serverTimestamp(),
      });
      return;
    }

    final alertRef = _elderAlerts(id).doc();
    final batch = _firestore.batch();

    batch.set(violationRef, {
      'violationId': violationId,
      'elderId': id,
      'safeZoneId': safeZone.id,
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
    });

    batch.set(alertRef, {
      'elderId': id,
      'title': 'Safe Zone Alert',
      'message':
          '${safeZone.name}: the elder is '
          '${distanceInMeters.round()} meters from the zone center, '
          'outside its ${safeZone.radiusInMeters.round()} meter radius.',
      'date': DateTime.now().toIso8601String(),
      'type': 'safe_zone',
      'safeZoneId': safeZone.id,
      'safeZoneName': safeZone.name,
      'latitude': latitude,
      'longitude': longitude,
      'distanceInMeters': distanceInMeters,
      'status': 'active',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  String _stableViolationId(String elderId, String zoneId) =>
      '${elderId.length}_$elderId${zoneId.length}_$zoneId';

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
      throw ArgumentError('Safe zone radius must be positive.');
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
        math.atan2(math.sqrt(clampedA), math.sqrt(1 - clampedA));
  }

  double _degreesToRadians(double degrees) => degrees * math.pi / 180;
}