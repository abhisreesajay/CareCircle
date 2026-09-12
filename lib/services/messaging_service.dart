import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize(String userId) async {
    // Ask for notification permission
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get FCM token
    final token = await _messaging.getToken();

    if (token == null) {
      return;
    }

    // Save token in the user's Firestore document
    await _firestore
        .collection('users')
        .doc(userId)
        .set(
      {
        'fcmToken': token,
      },
      SetOptions(merge: true),
    );
  }
}