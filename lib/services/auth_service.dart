
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'messaging_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  final MessagingService _messagingService =
      MessagingService();

  // ============================================================
  // CURRENT USER
  // ============================================================

  User? get currentUser => _auth.currentUser;

  Stream<User?> get authStateChanges =>
      _auth.authStateChanges();

  // ============================================================
  // INVITE CODE
  // ============================================================

  String _generateInviteCode() {
    const String chars =
        'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

    final Random random = Random();

    return String.fromCharCodes(
      Iterable.generate(
        6,
        (_) => chars.codeUnitAt(
          random.nextInt(chars.length),
        ),
      ),
    );
  }

  // ============================================================
  // FCM TOKEN
  // ============================================================

  Future<void> _saveDeviceToken(String uid) async {
    try {
      // Web FCM is disabled until the service worker is configured.
      if (kIsWeb) {
        debugPrint(
          'FCM token saving skipped on web platform.',
        );
        return;
      }

      if (uid.trim().isEmpty) {
        return;
      }

      final User? activeUser = _auth.currentUser;

      if (activeUser == null || activeUser.uid != uid) {
        return;
      }

      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      // The user may have logged out while permission was requested.
      if (_auth.currentUser?.uid != uid) {
        return;
      }

      final String? token =
          await FirebaseMessaging.instance.getToken();

      if (token != null && token.isNotEmpty) {
        // Avoid writing a token after the account has changed.
        if (_auth.currentUser?.uid != uid) {
          return;
        }

        await _firestore.collection('users').doc(uid).set(
          {
            'fcmToken': token,
            'lastActive': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }
    } catch (e) {
      // Notification failures must not prevent authentication.
      debugPrint('FCM token could not be saved: $e');
    }
  }

  // ============================================================
  // SAFE BACKGROUND NOTIFICATION SETUP
  // ============================================================

  Future<void> _initializeMessagingSafely(String uid) async {
    try {
      // Don't initialize messaging for a user who has signed out
      // or switched accounts.
      if (_auth.currentUser?.uid != uid) {
        return;
      }

      await _messagingService.initialize(uid);
    } catch (e) {
      debugPrint('Messaging initialization failed: $e');
    }
  }

  Future<void> _saveDeviceTokenSafely(String uid) async {
    try {
      await _saveDeviceToken(uid);
    } catch (e) {
      debugPrint('Device token setup failed: $e');
    }
  }

  // ============================================================
  // SIGN UP
  // ============================================================

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String role,
    String? name,
  }) async {
    final String cleanEmail = email.trim();
    final String cleanRole = role.trim().toLowerCase();

    if (cleanEmail.isEmpty) {
      throw Exception('Email is required.');
    }

    if (password.isEmpty) {
      throw Exception('Password is required.');
    }

    if (cleanRole != 'elder' &&
        cleanRole != 'caregiver') {
      throw Exception(
        'Only Elder and Caregiver accounts can sign up.',
      );
    }

    UserCredential credential;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Unable to create the account: $e');
    }

    final User? user = credential.user;

    if (user == null) {
      throw Exception('Account creation failed.');
    }

    final String? inviteCode =
        cleanRole == 'elder' ? _generateInviteCode() : null;

    final UserModel userModel = UserModel(
      uid: user.uid,
      email: cleanEmail,
      role: cleanRole,
      name: name,
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );

    try {
      await _firestore.collection('users').doc(user.uid).set(
            userModel.toMap(),
          );

      if (cleanRole == 'elder' &&
          inviteCode != null &&
          inviteCode.isNotEmpty) {
        await _firestore
            .collection('inviteCodes')
            .doc(inviteCode)
            .set({
          'code': inviteCode,
          'elderId': user.uid,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // Start notification setup without blocking account creation.
      _initializeMessagingSafely(user.uid);
      _saveDeviceTokenSafely(user.uid);

      return credential;
    } on FirebaseException catch (e) {
      // Attempt to clean up an incomplete account if setup fails.
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .delete();
      } catch (cleanupError) {
        debugPrint(
          'Failed to clean up user profile: $cleanupError',
        );
      }

      try {
        await user.delete();
      } catch (cleanupError) {
        debugPrint(
          'Failed to clean up authentication account: $cleanupError',
        );
      }

      throw Exception(_getFirestoreErrorMessage(e));
    } catch (e) {
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .delete();
      } catch (cleanupError) {
        debugPrint(
          'Failed to clean up user profile: $cleanupError',
        );
      }

      try {
        await user.delete();
      } catch (cleanupError) {
        debugPrint(
          'Failed to clean up authentication account: $cleanupError',
        );
      }

      throw Exception('Account was created, but setup failed: $e');
    }
  }

  // ============================================================
  // LOGIN
  // ============================================================

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential credential =
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user = credential.user;

      if (user != null) {
        // These methods catch their own errors and do not block login.
        _initializeMessagingSafely(user.uid);
        _saveDeviceTokenSafely(user.uid);
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Unable to sign in: $e');
    }
  }

  // ============================================================
  // PASSWORD RESET
  // ============================================================

  Future<void> sendPasswordResetEmail(String email) async {
    final String cleanEmail = email.trim();

    if (cleanEmail.isEmpty ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
            .hasMatch(cleanEmail)) {
      throw Exception('Please enter a valid email address.');
    }

    try {
      await _auth.sendPasswordResetEmail(
        email: cleanEmail,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint(
        'Password reset failed: ${e.code} - ${e.message}',
      );

      switch (e.code) {
        case 'invalid-email':
          throw Exception('Please enter a valid email address.');

        case 'user-not-found':
          throw Exception(
            'No account was found for that email address.',
          );

        case 'too-many-requests':
          throw Exception(
            'Too many reset attempts. Please wait and try again.',
          );

        case 'network-request-failed':
          throw Exception(
            'Network error. Check your internet connection.',
          );

        case 'operation-not-allowed':
          throw Exception(
            'Password reset is unavailable. Check Firebase settings.',
          );

        default:
          throw Exception(
            'Could not send the reset email. Error: ${e.code}',
          );
      }
    }
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    final User? user = _auth.currentUser;

    // Sign out first so messaging cleanup cannot delay the
    // authentication state change that returns the app to login.
    await _auth.signOut();

    if (user != null) {
      try {
        await _messagingService.removeToken(user.uid);
      } catch (e) {
        debugPrint('Failed to remove messaging token: $e');
      }
    }

    try {
      await _messagingService.dispose();
    } catch (e) {
      debugPrint('Messaging dispose failed: $e');
    }
  }

  // ============================================================
  // GET USER PROFILE
  // ============================================================

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final DocumentSnapshot<Map<String, dynamic>> doc =
          await _firestore.collection('users').doc(uid).get();

      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!, uid);
      }

      return null;
    } catch (e) {
      debugPrint('Failed to get user profile: $e');
      rethrow;
    }
  }

  // ============================================================
  // AUTH ERROR MESSAGES
  // ============================================================

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email address.';

      case 'invalid-email':
        return 'The email address is invalid.';

      case 'weak-password':
        return 'The password is too weak.';

      case 'operation-not-allowed':
        return 'Email/Password authentication is not enabled in Firebase.';

      case 'user-not-found':
        return 'No account exists with this email address.';

      case 'wrong-password':
        return 'The password is incorrect.';

      case 'invalid-credential':
        return 'The email or password is incorrect.';

      case 'user-disabled':
        return 'This account has been disabled.';

      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';

      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';

      case 'requires-recent-login':
        return 'Please log in again and try the operation.';

      default:
        return 'Authentication error (${e.code}): '
            '${e.message ?? 'Unknown error'}';
    }
  }

  // ============================================================
  // FIRESTORE ERROR MESSAGES
  // ============================================================

  String _getFirestoreErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Firestore denied permission. Check Firestore rules.';

      case 'unavailable':
        return 'Firestore is unavailable. Check your internet connection.';

      case 'failed-precondition':
        return 'Firestore is not properly configured.';

      case 'not-found':
        return 'The required Firestore resource was not found.';

      case 'already-exists':
        return 'The required Firestore resource already exists.';

      default:
        return 'Firestore error (${e.code}): '
            '${e.message ?? 'Unknown Firestore error'}';
    }
  }
}