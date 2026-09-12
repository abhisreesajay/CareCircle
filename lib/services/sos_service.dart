import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import '../models/sos_record.dart';

class SosService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Location permission denied.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
        'Location permission permanently denied. '
        'Please enable it from device settings.',
      );
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  Future<SosRecord> createSos(String userId) async {
    final Position position = await getCurrentLocation();

    final DocumentReference doc =
        _firestore.collection('sosRecords').doc();

    final SosRecord sos = SosRecord(
      id: doc.id,
      userId: userId,
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: DateTime.now(),
      status: 'ACTIVE',
    );

    await doc.set(sos.toMap());

    return sos;
  }

  Future<void> cancelSos(String sosId) async {
    await _firestore
        .collection('sosRecords')
        .doc(sosId)
        .update({
      'status': 'CANCELLED',
    });
  }
}