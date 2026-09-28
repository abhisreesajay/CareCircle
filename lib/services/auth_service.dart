<<<<<<< HEAD
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
=======
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'messaging_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final MessagingService _messagingService = MessagingService();
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Helper: Generates a 6-character random code for Elder linking
  String _generateInviteCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

<<<<<<< HEAD
  // Helper: Get and save the device FCM token for push notifications
  Future<void> _saveDeviceToken(String uid) async {
    try {
      // Request notification permission (Required for iOS, auto-granted on Android)
      await FirebaseMessaging.instance.requestPermission();

      // Fetch the unique FCM token for this device
      final fcmToken = await FirebaseMessaging.instance.getToken();

      if (fcmToken != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': fcmToken,
          'lastActive': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print("Failed to save FCM token: $e");
    }
  }

  // Sign Up with Role Allocation & Token Registration
  Future<UserCredential> signUp({
=======
  // ============================================================
  // REGISTER
  // ============================================================

  Future<UserCredential> registerUser({
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
    required String email,
    required String password,
    required String role,
    String? name,
  }) async {
<<<<<<< HEAD
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final inviteCode = (role == 'elder') ? _generateInviteCode() : null;

    final user = UserModel(
      uid: credential.user!.uid,
      email: email,
      role: role,
      name: name,
      inviteCode: inviteCode,
      createdAt: DateTime.now(),
    );

    // Save user profile to Firestore
    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toMap());

    // Save FCM Token for push notifications
    await _saveDeviceToken(credential.user!.uid);

    return credential;
  }

  // Sign In & Token Refresh
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Update FCM Token on every successful login
    await _saveDeviceToken(credential.user!.uid);

    return credential;
  }

  // Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign Out
=======
    final String cleanEmail = email.trim();
    final String cleanRole = role.trim().toLowerCase();

    if (cleanEmail.isEmpty) {
      throw Exception('Email is required.');
    }

    if (password.isEmpty) {
      throw Exception('Password is required.');
    }

    if (cleanRole != 'elder' && cleanRole != 'caregiver') {
      throw Exception('Invalid account role.');
    }

    UserCredential credential;

    try {
      credential =
          await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception(
        'Unable to create the account: $e',
      );
    }

    final User? user = credential.user;

    if (user == null) {
      throw Exception(
        'Account creation failed.',
      );
    }

    final Map<String, dynamic> userData = {
      'uid': user.uid,
      'email': cleanEmail,
      'role': cleanRole,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (cleanRole == 'caregiver') {
      userData['linkedElders'] = <String>[];
    } else {
      userData['caregivers'] = <String>[];
      userData['inviteCode'] = '';
    }

    try {
      await _db
          .collection('users')
          .doc(user.uid)
          .set(userData);

      await _messagingService.initialize(user.uid);

      return credential;
    } on FirebaseException catch (e) {
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

  Future<UserCredential> loginUser({
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
        await _messagingService.initialize(
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
  // SIGN OUT
  // ============================================================

>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
  Future<void> signOut() async {
    final User? user = _auth.currentUser;

    if (user != null) {
      await _messagingService.removeToken(
        user.uid,
      );
    }

    await _messagingService.dispose();

    await _auth.signOut();
  }

<<<<<<< HEAD
  // Fetch Current User Details
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }
}
=======
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

      default:
        return 'Firestore error (${e.code}): '
            '${e.message ?? 'Unknown Firestore error'}';
    }
  }
}
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
