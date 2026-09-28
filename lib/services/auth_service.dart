import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import 'messaging_service.dart';

class AuthService {
  final FirebaseAuth _auth =
      FirebaseAuth.instance;

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

  Future<void> _saveDeviceToken(
    String uid,
  ) async {
    try {
      // ----------------------------------------------------------
      // FLUTTER WEB
      // ----------------------------------------------------------
      // FCM web requires firebase-messaging-sw.js.
      // Web FCM is disabled for now so Chrome/Edge does not
      // attempt to register the missing service worker.
      // ----------------------------------------------------------

      if (kIsWeb) {
        debugPrint(
          'FCM token saving skipped on web platform.',
        );
        return;
      }

      if (uid.trim().isEmpty) {
        return;
      }

      final User? currentUser =
          _auth.currentUser;

      if (currentUser == null ||
          currentUser.uid != uid) {
        return;
      }

      await FirebaseMessaging.instance
          .requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      final String? token =
          await FirebaseMessaging.instance
              .getToken();

      if (token != null &&
          token.isNotEmpty) {
        await _firestore
            .collection('users')
            .doc(uid)
            .set(
          {
            'fcmToken': token,
            'lastActive':
                FieldValue.serverTimestamp(),
          },
          SetOptions(
            merge: true,
          ),
        );
      }
    } catch (e) {
      // FCM failure must never prevent login/signup.
      debugPrint(
        'FCM token could not be saved: $e',
      );
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
    final String cleanEmail =
        email.trim();

    final String cleanRole =
        role.trim().toLowerCase();

    // ----------------------------------------------------------
    // VALIDATION
    // ----------------------------------------------------------

    if (cleanEmail.isEmpty) {
      throw Exception(
        'Email is required.',
      );
    }

    if (password.isEmpty) {
      throw Exception(
        'Password is required.',
      );
    }

    if (cleanRole != 'elder' &&
        cleanRole != 'caregiver') {
      throw Exception(
        'Invalid account role.',
      );
    }

    // ----------------------------------------------------------
    // CREATE FIREBASE AUTH ACCOUNT
    // ----------------------------------------------------------

    UserCredential credential;

    try {
      credential =
          await _auth
              .createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e),
      );
    } catch (e) {
      throw Exception(
        'Unable to create the account: $e',
      );
    }

    final User? user =
        credential.user;

    if (user == null) {
      throw Exception(
        'Account creation failed.',
      );
    }

    // ----------------------------------------------------------
    // ELDER INVITE CODE
    // ----------------------------------------------------------

    final String? inviteCode =
        cleanRole == 'elder'
            ? _generateInviteCode()
            : null;

    // ----------------------------------------------------------
    // USER PROFILE
    // ----------------------------------------------------------

    final UserModel userModel =
        UserModel(
      uid: user.uid,
      email: cleanEmail,
      role: cleanRole,
      name: name,
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );

    // ----------------------------------------------------------
    // CREATE FIRESTORE USER PROFILE
    // ----------------------------------------------------------

    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set(
        userModel.toMap(),
      );

      // --------------------------------------------------------
      // CREATE ELDER INVITE CODE DOCUMENT
      // --------------------------------------------------------
      //
      // This is done only for elders.
      //
      // The signup Firestore rules allow the authenticated elder
      // to create their own inviteCodes document.
      //
      // Caregiver signup does not create an invite code.
      // --------------------------------------------------------

      if (cleanRole == 'elder' &&
          inviteCode != null &&
          inviteCode.isNotEmpty) {
        await _firestore
            .collection('inviteCodes')
            .doc(inviteCode)
            .set({
          'code': inviteCode,
          'elderId': user.uid,
          'createdAt':
              FieldValue.serverTimestamp(),
        });
      }

      // --------------------------------------------------------
      // INITIALIZE NOTIFICATION SERVICE
      // --------------------------------------------------------

      try {
        await _messagingService
            .initialize(
          user.uid,
        );
      } catch (e) {
        debugPrint(
          'Messaging initialization failed: $e',
        );
      }

      // --------------------------------------------------------
      // SAVE FCM TOKEN
      // --------------------------------------------------------
      //
      // On Chrome/Edge this method immediately returns.
      // On Android/iOS it saves the FCM token normally.
      // --------------------------------------------------------

      await _saveDeviceToken(
        user.uid,
      );

      return credential;
    } on FirebaseException catch (e) {
      // If Firestore setup fails, remove the Firebase Auth
      // account so we don't leave an incomplete account behind.

      try {
        await user.delete();
      } catch (_) {}

      throw Exception(
        _getFirestoreErrorMessage(e),
      );
    } catch (e) {
      try {
        await user.delete();
      } catch (_) {}

      throw Exception(
        'Account was created, but setup failed: $e',
      );
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
          await _auth
              .signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final User? user =
          credential.user;

      if (user != null) {
        // --------------------------------------------------------
        // INITIALIZE MESSAGING
        // --------------------------------------------------------

        try {
          await _messagingService
              .initialize(
            user.uid,
          );
        } catch (e) {
          debugPrint(
            'Messaging initialization failed: $e',
          );
        }

        // --------------------------------------------------------
        // SAVE DEVICE TOKEN
        // --------------------------------------------------------

        await _saveDeviceToken(
          user.uid,
        );
      }

      return credential;
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e),
      );
    } catch (e) {
      throw Exception(
        'Unable to sign in: $e',
      );
    }
  }

  // ============================================================
  // PASSWORD RESET
  // ============================================================

  Future<void> sendPasswordResetEmail(
    String email,
  ) async {
    try {
      await _auth
          .sendPasswordResetEmail(
        email: email.trim(),
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(
        _getAuthErrorMessage(e),
      );
    }
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    final User? user =
        _auth.currentUser;

    if (user != null) {
      try {
        await _messagingService
            .removeToken(
          user.uid,
        );
      } catch (e) {
        debugPrint(
          'Failed to remove messaging token: $e',
        );
      }
    }

    try {
      await _messagingService
          .dispose();
    } catch (e) {
      debugPrint(
        'Messaging dispose failed: $e',
      );
    }

    await _auth.signOut();
  }

  // ============================================================
  // GET USER PROFILE
  // ============================================================

  Future<UserModel?> getUserProfile(
    String uid,
  ) async {
    try {
      final DocumentSnapshot<
          Map<String, dynamic>> doc =
          await _firestore
              .collection('users')
              .doc(uid)
              .get();

      if (doc.exists &&
          doc.data() != null) {
        return UserModel.fromMap(
          doc.data()!,
          uid,
        );
      }

      return null;
    } catch (e) {
      debugPrint(
        'Failed to get user profile: $e',
      );

      rethrow;
    }
  }

  // ============================================================
  // AUTH ERROR MESSAGES
  // ============================================================

  String _getAuthErrorMessage(
    FirebaseAuthException e,
  ) {
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

  String _getFirestoreErrorMessage(
    FirebaseException e,
  ) {
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