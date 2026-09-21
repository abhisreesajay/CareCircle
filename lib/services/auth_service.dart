import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'messaging_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final MessagingService _messagingService = MessagingService();

  Stream<User?> get userStateStream => _auth.authStateChanges();

  String? get currentUserId => _auth.currentUser?.uid;

  // ============================================================
  // REGISTER
  // ============================================================

  Future<UserCredential> registerUser({
    required String email,
    required String password,
    required String role,
  }) async {
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