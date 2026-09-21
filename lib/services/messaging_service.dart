import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> initialize() async {
    await _requestPermission();
    await _saveToken();

    _messaging.onTokenRefresh.listen((token) async {
      await _saveToken(token);
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      
     
    });
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
  alert: true,
  badge: true,
  sound: true,
  provisional: false,
);

  }

  Future<void> _saveToken([String? token]) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return;
    }

    final fcmToken = token ?? await _messaging.getToken();

    if (fcmToken == null || fcmToken.isEmpty) {
      return;
    }

    await _firestore.collection('users').doc(user.uid).set(
      {
        'fcmToken': fcmToken,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}