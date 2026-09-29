<<<<<<< HEAD
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

// This must be a top-level function outside of the class
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Handle background messages here (e.g., if the app is closed)
  print("Handling a background message: ${message.messageId}");
}

class MessagingService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> initialize() async {
    // 1. Request permissions (Required for iOS)
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // 2. Get the FCM Token for this device
      String? token = await _fcm.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }

      // 3. Listen for token refreshes
      _fcm.onTokenRefresh.listen(_saveTokenToFirestore);

      // 4. Set up foreground message handling
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        print('Got a message whilst in the foreground!');
        if (message.notification != null) {
          print('Notification Title: ${message.notification?.title}');
          // Person 5 will handle showing a local notification UI here
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    // Save the token to the user's document so Cloud Functions can find it
    await _db.collection('users').doc(uid).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  // Setup the background handler
  static void setupBackgroundHandling() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }
}
=======
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../firebase_options.dart';

class MessagingService {
  final FirebaseMessaging _messaging =
      FirebaseMessaging.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final FirebaseAuth _auth =
      FirebaseAuth.instance;

  StreamSubscription<String>?
      _tokenRefreshSubscription;

  StreamSubscription<RemoteMessage>?
      _foregroundMessageSubscription;

  Future<void> initialize(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        return;
      }

      final currentUser = _auth.currentUser;

      if (currentUser == null ||
          currentUser.uid != userId) {
        return;
      }

      // Request notification permission.
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // iOS/macOS requires APNs token before FCM token.
      if (!kIsWeb &&
          (defaultTargetPlatform ==
                  TargetPlatform.iOS ||
              defaultTargetPlatform ==
                  TargetPlatform.macOS)) {
        String? apnsToken;

        for (int i = 0; i < 10; i++) {
          apnsToken =
              await _messaging.getAPNSToken();

          if (apnsToken != null &&
              apnsToken.isNotEmpty) {
            break;
          }

          await Future.delayed(
            const Duration(milliseconds: 500),
          );
        }

        if (apnsToken == null ||
            apnsToken.isEmpty) {
          return;
        }
      }

      final token =
          await _messaging.getToken();

      if (token != null && token.isNotEmpty) {
        await _saveToken(
          userId,
          token,
        );
      }

      await _tokenRefreshSubscription?.cancel();

      _tokenRefreshSubscription =
          _messaging.onTokenRefresh.listen(
        (newToken) async {
          try {
            final user = _auth.currentUser;

            if (user == null ||
                user.uid != userId) {
              return;
            }

            if (newToken.isEmpty) {
              return;
            }

            await _saveToken(
              userId,
              newToken,
            );
          } catch (_) {}
        },
      );

      await _foregroundMessageSubscription
          ?.cancel();

      _foregroundMessageSubscription =
          FirebaseMessaging.onMessage.listen(
        (message) {
          _handleForegroundMessage(
            message,
          );
        },
      );
    } catch (_) {
      // FCM failure should not prevent app startup.
    }
  }

  Future<void> _saveToken(
    String userId,
    String token,
  ) async {
    if (userId.isEmpty || token.isEmpty) {
      return;
    }

    final user = _auth.currentUser;

    if (user == null ||
        user.uid != userId) {
      return;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .set(
      {
        'fcmTokens':
            FieldValue.arrayUnion([token]),
        'fcmTokenUpdatedAt':
            FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  void _handleForegroundMessage(
    RemoteMessage message,
  ) {
    // The notification is received here.
    //
    // If you want a custom popup later,
    // implement it here.
  }

  Future<void> removeToken(
    String userId,
  ) async {
    try {
      if (userId.isEmpty) {
        return;
      }

      final user = _auth.currentUser;

      if (user == null ||
          user.uid != userId) {
        return;
      }

      final token =
          await _messaging.getToken();

      if (token == null || token.isEmpty) {
        return;
      }

      await _firestore
          .collection('users')
          .doc(userId)
          .set(
        {
          'fcmTokens':
              FieldValue.arrayRemove([token]),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();

    _tokenRefreshSubscription = null;

    await _foregroundMessageSubscription
        ?.cancel();

    _foregroundMessageSubscription = null;
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  try {
    await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  // Background notification handling.
}
>>>>>>> main
