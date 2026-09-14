import 'package:cloud_firestore/cloud_firestore.dart';

class ElderStatusService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> getStatus(
    String elderId,
  ) {
    return _firestore
        .collection('elders')
        .doc(elderId)
        .collection('status')
        .doc('current')
        .snapshots();
  }
}