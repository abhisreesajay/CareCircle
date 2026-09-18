import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<String>? _tokenRefreshSubscription;

  // Initializes FCM notifications for the logged-in user.
  Future<void> initialize(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        return;
      }

      final User? currentUser = _auth.currentUser;

      // Do not save a token for a different user.
      if (currentUser == null || currentUser.uid != userId) {
        return;
      }

      // Request notification permission.
      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // Get the current FCM token.
      final String? token = await _messaging.getToken();

      if (token != null && token.isNotEmpty) {
        await _saveToken(
          userId: userId,
          token: token,
        );
      }

      // Stop any previous token listener.
      await _tokenRefreshSubscription?.cancel();

      // Listen for FCM token changes.
      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
        (String newToken) async {
          if (newToken.isEmpty) {
            return;
          }

          final User? refreshedUser = _auth.currentUser;

          // Do not save a token after logout or user change.
          if (refreshedUser == null || refreshedUser.uid != userId) {
            return;
          }

          await _saveToken(
            userId: userId,
            token: newToken,
          );
        },
        onError: (error) {
          // Token refresh errors should not crash the app.
        },
      );
    } catch (error) {
      // Notification setup should not prevent the app from opening.
      // Add logging here later if required.
    }
  }

  // Saves the FCM token in the user's Firestore document.
  Future<void> _saveToken({
    required String userId,
    required String token,
  }) async {
    if (userId.trim().isEmpty || token.trim().isEmpty) {
      return;
    }

    final User? currentUser = _auth.currentUser;

    if (currentUser == null || currentUser.uid != userId) {
      return;
    }

    await _firestore.collection('users').doc(userId).set(
      {
        'fcmToken': token,
        'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  // Removes the saved FCM token when the user logs out.
  Future<void> removeToken(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        return;
      }

      final User? currentUser = _auth.currentUser;

      if (currentUser == null || currentUser.uid != userId) {
        return;
      }

      await _firestore.collection('users').doc(userId).set(
        {
          'fcmToken': FieldValue.delete(),
          'fcmTokenUpdatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (error) {
      // Do not crash the app if token removal fails.
    }
  }

  // Stops listening for token changes.
  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;
  }
}