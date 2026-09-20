import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Stream used by AuthWrapper to detect login/logout changes.
  Stream<User?> get userStateStream => _auth.authStateChanges();

  // Returns the currently logged-in user's Firebase UID.
  String? get currentUserId => _auth.currentUser?.uid;

  // ============================================================
  // REGISTER USER
  // ============================================================

  Future<UserCredential> registerUser({
    required String email,
    required String password,
    required String role,
  }) async {
    final String cleanEmail = email.trim();

    UserCredential cred;

    // ------------------------------------------------------------
    // Step 1: Create Firebase Authentication account
    // ------------------------------------------------------------
    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Unable to create the account: $e');
    }

    // Make sure Firebase returned a user.
    if (cred.user == null) {
      throw Exception('Account creation failed. No user was returned.');
    }

    // ------------------------------------------------------------
    // Step 2: Prepare Firestore user document
    // ------------------------------------------------------------
    final Map<String, dynamic> userData = {
      'uid': cred.user!.uid,
      'email': cleanEmail,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (role == 'caregiver') {
      userData['linkedElders'] = [];
    } else {
      userData['inviteCode'] = '';
    }

    // ------------------------------------------------------------
    // Step 3: Save user information in Firestore
    // ------------------------------------------------------------
    try {
      await _db
          .collection('users')
          .doc(cred.user!.uid)
          .set(userData);
    } on FirebaseException catch (e) {
      // If Firestore fails after Authentication succeeds,
      // try to remove the newly-created Firebase Auth account
      // so we don't leave a partially-created account behind.
      try {
        await cred.user!.delete();
      } catch (_) {
        // Ignore cleanup failure.
      }

      throw Exception(_getFirestoreErrorMessage(e));
    } catch (e) {
      try {
        await cred.user!.delete();
      } catch (_) {
        // Ignore cleanup failure.
      }

      throw Exception('Account was created, but saving user data failed: $e');
    }

    return cred;
  }

  // ============================================================
  // LOGIN USER
  // ============================================================

  Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(_getAuthErrorMessage(e));
    } catch (e) {
      throw Exception('Unable to sign in: $e');
    }
  }

  // ============================================================
  // SIGN OUT
  // ============================================================

  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ============================================================
  // FIREBASE AUTH ERROR MESSAGES
  // ============================================================

  String _getAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'An account already exists with this email address.';

      case 'invalid-email':
        return 'The email address is invalid.';

      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';

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
        return 'Authentication error (${e.code}): ${e.message ?? 'Unknown error'}';
    }
  }

  // ============================================================
  // FIRESTORE ERROR MESSAGES
  // ============================================================

  String _getFirestoreErrorMessage(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Account authentication succeeded, but Firestore denied permission to save the user data. Please check the Firestore security rules.';

      case 'unavailable':
        return 'Firestore is currently unavailable. Please check your internet connection and try again.';

      case 'failed-precondition':
        return 'Firestore is not properly configured for this operation.';

      case 'not-found':
        return 'The required Firestore resource was not found.';

      default:
        return 'Firestore error (${e.code}): ${e.message ?? 'Unknown Firestore error'}';
    }
  }
}