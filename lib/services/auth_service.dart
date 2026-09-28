import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      debugPrint("Failed to save FCM token: $e");
    }
  }

  // Sign Up with Role Allocation & Token Registration
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String role,
    String? name,
  }) async {
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
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Fetch Current User Details
  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return UserModel.fromMap(doc.data()!, uid);
    }
    return null;
  }
}
