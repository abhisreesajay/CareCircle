import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/nearby_service_model.dart';

class NearbyServiceService {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> addService(
    String elderId,
    NearbyService service,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('nearbyServices')
        .doc(service.id)
        .set(service.toMap());
  }

  Future<void> updateService(
    String elderId,
    NearbyService service,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('nearbyServices')
        .doc(service.id)
        .update(service.toMap());
  }

  Future<void> deleteService(
    String elderId,
    String serviceId,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('nearbyServices')
        .doc(serviceId)
        .delete();
  }

  Stream<List<NearbyService>> getServices(
    String elderId,
  ) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('nearbyServices')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => NearbyService.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }

  Future<void> togglePreferred(
    String elderId,
    NearbyService service,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('nearbyServices')
        .doc(service.id)
        .update({
      'preferred': !service.preferred,
    });
  }
}
