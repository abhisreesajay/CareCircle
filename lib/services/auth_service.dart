import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // Get Current User
  User? get currentUser => _auth.currentUser;

  // Sign In
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign Up with Role and Optional Invite Code
  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String role,
    String? name,
    String? inviteCode,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // If Elder, auto-generate code; if Caregiver, use provided code
    final finalInviteCode = (role == 'elder') ? _generateInviteCode() : inviteCode;

    final user = UserModel(
      uid: credential.user!.uid,
      email: email,
      role: role,
      name: name,
      inviteCode: finalInviteCode,
      createdAt: DateTime.now(),
    );

    // Save profile to Firestore
    await _firestore
        .collection('users')
        .doc(credential.user!.uid)
        .set(user.toMap());

    // Save FCM Token for Push Notifications
    await _saveDeviceToken(credential.user!.uid);

    return credential;
  }

  // Fetch Profile Document from Firestore
  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Helper: Generate Random 6-Character Alphanumeric Code
  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return List.generate(6, (index) => chars[random.nextInt(chars.length)]).join();
  }

  // Helper: Save Device FCM Token
  Future<void> _saveDeviceToken(String uid) async {
    try {
      String? token = await _fcm.getToken();
      if (token != null) {
        await _firestore.collection('users').doc(uid).update({
          'fcmToken': token,
        });
      }
    } catch (_) {
      // Non-critical token error caught silently
    }
  }
}
