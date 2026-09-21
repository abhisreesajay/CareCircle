import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

/// Handles Firebase Cloud Messaging (FCM) setup for CareCircle.
///
/// Responsibilities:
/// - Request notification permission.
/// - Get and store the user's FCM token.
/// - Keep the token updated when Firebase refreshes it.
/// - Handle notifications while the app is in the foreground.
/// - Register a background message handler.
/// - Remove the token when the user logs out.
class MessagingService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  StreamSubscription<String>? _tokenRefreshSubscription;

  StreamSubscription<RemoteMessage>? _foregroundMessageSubscription;

  /// Initializes FCM notifications for the logged-in user.
  Future<void> initialize(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        return;
      }

      final User? currentUser = _auth.currentUser;

      // Do not initialize FCM for a different user.
      if (currentUser == null || currentUser.uid != userId) {
        return;
      }

      // --------------------------------------------------
      // 1. REQUEST NOTIFICATION PERMISSION
      // --------------------------------------------------

      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // --------------------------------------------------
      // 2. GET FCM TOKEN
      // --------------------------------------------------

      final String? token = await _messaging.getToken();

      if (token != null && token.isNotEmpty) {
        await _saveToken(
          userId: userId,
          token: token,
        );
      }

      // --------------------------------------------------
      // 3. STOP PREVIOUS TOKEN LISTENER
      // --------------------------------------------------

      await _tokenRefreshSubscription?.cancel();

      // --------------------------------------------------
      // 4. LISTEN FOR TOKEN REFRESH
      // --------------------------------------------------

      _tokenRefreshSubscription = _messaging.onTokenRefresh.listen(
        (String newToken) async {
          try {
            if (newToken.isEmpty) {
              return;
            }

            final User? refreshedUser = _auth.currentUser;

            // Do not save a token after logout
            // or after switching to another user.
            if (refreshedUser == null ||
                refreshedUser.uid != userId) {
              return;
            }

            await _saveToken(
              userId: userId,
              token: newToken,
            );
          } catch (_) {
            // Token refresh errors should not crash the app.
          }
        },
        onError: (_) {
          // Token refresh listener errors should not crash the app.
        },
      );

      // --------------------------------------------------
      // 5. STOP PREVIOUS FOREGROUND LISTENER
      // --------------------------------------------------

      await _foregroundMessageSubscription?.cancel();

      // --------------------------------------------------
      // 6. LISTEN FOR FOREGROUND NOTIFICATIONS
      // --------------------------------------------------

      _foregroundMessageSubscription =
          FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) {
          _handleForegroundMessage(message);
        },
        onError: (_) {
          // Foreground notification errors should not crash the app.
        },
      );
    } catch (_) {
      // Notification setup should not prevent
      // the CareCircle app from opening.
    }
  }

  /// Handles an FCM message received while the app
  /// is currently open in the foreground.
  void _handleForegroundMessage(RemoteMessage message) {
    // Foreground messages are received here.
    //
    // The actual notification UI can be added later if required.
    // For now, receiving the message is sufficient for
    // the Person 4 FCM integration.
  }

  /// Saves the FCM token in the user's Firestore document.
  Future<void> _saveToken({
    required String userId,
    required String token,
  }) async {
    if (userId.trim().isEmpty ||
        token.trim().isEmpty) {
      return;
    }
  
    final User? currentUser =
        _auth.currentUser;
  
    if (currentUser == null ||
        currentUser.uid != userId) {
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

  Future<void> removeToken(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        return;
      }
  
      final User? currentUser =
          _auth.currentUser;
  
      if (currentUser == null ||
          currentUser.uid != userId) {
        return;
      }
  
      final String? token =
          await _messaging.getToken();
  
      if (token == null ||
          token.isEmpty) {
        return;
      }
  
      await _firestore
          .collection('users')
          .doc(userId)
          .set(
        {
          'fcmTokens':
              FieldValue.arrayRemove([token]),
          'fcmTokenUpdatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {
      // Do not crash the application.
    }
  }

  /// Stops listening for token refreshes and foreground messages.
  Future<void> dispose() async {
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = null;

    await _foregroundMessageSubscription?.cancel();
    _foregroundMessageSubscription = null;
  }
}

/// Handles FCM messages when the application is running
/// in the background or has been terminated.
///
/// This function must remain a top-level function.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  // Background FCM handler.
  //
  // Firebase can invoke this function when a message
  // arrives while the application is in the background.
}
