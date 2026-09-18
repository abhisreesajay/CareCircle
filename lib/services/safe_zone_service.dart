import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/safe_zone.dart';

class SafeZoneService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new safe zone
  Future<void> createSafeZone(SafeZone safeZone) async {
    final collection = _firestore.collection('safeZones');

    final document = safeZone.id.trim().isEmpty
        ? collection.doc()
        : collection.doc(safeZone.id);

    await document.set(safeZone.toMap());
  }

  // Get all safe zones belonging to an elder
  Future<List<SafeZone>> getSafeZones(String elderId) async {
    final snapshot = await _firestore
        .collection('safeZones')
        .where('elderId', isEqualTo: elderId)
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

  // Delete a safe zone
  Future<void> cancelSafeZone(String safeZoneId) async {
    await _firestore
        .collection('safeZones')
        .doc(safeZoneId)
        .delete();
  }
}