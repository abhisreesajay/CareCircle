import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/emergency_contact_model.dart';

class EmergencyContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addContact(
    String elderId,
    EmergencyContact contact,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('emergencyContacts')
        .doc(contact.id)
        .set(contact.toMap());
  }

  Future<void> updateContact(
    String elderId,
    EmergencyContact contact,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('emergencyContacts')
        .doc(contact.id)
        .update(contact.toMap());
  }

  Future<void> deleteContact(
    String elderId,
    String contactId,
  ) async {
    await _firestore
        .collection('elders')
        .doc(elderId)
        .collection('emergencyContacts')
        .doc(contactId)
        .delete();
  }

  Stream<List<EmergencyContact>> getContacts(String elderId) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('emergencyContacts')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => EmergencyContact.fromMap(
                  doc.id,
                  doc.data(),
                ),
              )
              .toList(),
        );
  }
}