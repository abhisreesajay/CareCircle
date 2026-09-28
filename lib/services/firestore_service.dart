import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore db =
      FirebaseFirestore.instance;

  CollectionReference<
      Map<String, dynamic>> elderCollection(
    String elderId,
    String collection,
  ) {
    return db
        .collection('elders')
        .doc(elderId)
        .collection(collection);
  }

  DocumentReference<
      Map<String, dynamic>> elderDocument(
    String elderId,
  ) {
    return db
        .collection('elders')
        .doc(elderId);
  }

  Future<void> addActivity({
    required String elderId,
    required String type,
    required String description,
    String? method,
  }) async {
    await elderCollection(
      elderId,
      'activityHistory',
    ).add({
      'type': type,
      'description':
          description,
      if (method != null)
        'method': method,
      'timestamp':
          FieldValue.serverTimestamp(),
    });
  }
}