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

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> initialize(String userId) async {
    try {
      if (userId.trim().isEmpty) {
        return;
      }

      // ----------------------------------------------------------
      // FLUTTER WEB
      // ----------------------------------------------------------
      // Firebase Cloud Messaging on web requires a properly
      // configured firebase-messaging-sw.js service worker.
      //
      // For now, skip FCM completely on Chrome/Edge.
      // This prevents:
      // failed-service-worker-registration
      //
      // Android and iOS continue to use FCM normally.
      // ----------------------------------------------------------

      if (kIsWeb) {
        debugPrint(
          'FCM skipped on web platform.',
        );
        return;
      }

      final User? currentUser =
          _auth.currentUser;

      if (currentUser == null ||
          currentUser.uid != userId) {
        return;
      }

      // ----------------------------------------------------------
      // REQUEST NOTIFICATION PERMISSION
      // ----------------------------------------------------------

      await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // ----------------------------------------------------------
      // IOS / MACOS APNS TOKEN
      // ----------------------------------------------------------

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
            const Duration(
              milliseconds: 500,
            ),
          );
        }

        if (apnsToken == null ||
            apnsToken.isEmpty) {
          debugPrint(
            'APNs token unavailable.',
          );

          return;
        }
      }

      // ----------------------------------------------------------
      // GET FCM TOKEN
      // ----------------------------------------------------------

      final String? token =
          await _messaging.getToken();

      if (token != null &&
          token.isNotEmpty) {
        await _saveToken(
          userId,
          token,
        );
      }

      // ----------------------------------------------------------
      // TOKEN REFRESH
      // ----------------------------------------------------------

      await _tokenRefreshSubscription
          ?.cancel();

      _tokenRefreshSubscription =
          _messaging.onTokenRefresh.listen(
        (String newToken) async {
          try {
            final User? user =
                _auth.currentUser;

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
          } catch (e) {
            debugPrint(
              'FCM token refresh failed: $e',
            );
          }
        },
      );

      // ----------------------------------------------------------
      // FOREGROUND MESSAGES
      // ----------------------------------------------------------

      await _foregroundMessageSubscription
          ?.cancel();

      _foregroundMessageSubscription =
          FirebaseMessaging.onMessage.listen(
        (RemoteMessage message) {
          _handleForegroundMessage(
            message,
          );
        },
      );
    } catch (e) {
      // FCM failure should never prevent
      // the application from starting.
      debugPrint(
        'FCM initialization skipped/failed: $e',
      );
    }
  }

  // ============================================================
  // SAVE TOKEN
  // ============================================================

  Future<void> _saveToken(
    String userId,
    String token,
  ) async {
    try {
      if (userId.isEmpty ||
          token.isEmpty) {
        return;
      }

      final User? user =
          _auth.currentUser;

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
              FieldValue.arrayUnion(
            [token],
          ),
          'fcmTokenUpdatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );
    } catch (e) {
      debugPrint(
        'Failed to save FCM token: $e',
      );
    }
  }

  // ============================================================
  // FOREGROUND MESSAGE
  // ============================================================

  void _handleForegroundMessage(
    RemoteMessage message,
  ) {
    debugPrint(
      'FCM foreground message received: '
      '${message.messageId}',
    );

    // Custom in-app notification UI
    // can be added here later.
  }

  // ============================================================
  // REMOVE TOKEN
  // ============================================================

  Future<void> removeToken(
    String userId,
  ) async {
    try {
      if (userId.isEmpty) {
        return;
      }

      // FCM is intentionally disabled on web.
      if (kIsWeb) {
        return;
      }

      final User? user =
          _auth.currentUser;

      if (user == null ||
          user.uid != userId) {
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
              FieldValue.arrayRemove(
            [token],
          ),
        },
        SetOptions(
          merge: true,
        ),
      );
    } catch (e) {
      debugPrint(
        'Failed to remove FCM token: $e',
      );
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  Future<void> dispose() async {
    await _tokenRefreshSubscription
        ?.cancel();

    _tokenRefreshSubscription = null;

    await _foregroundMessageSubscription
        ?.cancel();

    _foregroundMessageSubscription = null;
  }
}

// ================================================================
// BACKGROUND FCM HANDLER
// ================================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  try {
    await Firebase.initializeApp(
      options:
          DefaultFirebaseOptions
              .currentPlatform,
    );
  } catch (_) {}

  // Background notification handling
  // can be implemented here later.
}