import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get userStateStream => _auth.authStateChanges();

  String? get currentUserId => _auth.currentUser?.uid;

  Future<UserCredential> registerUser({
    required String email,
    required String password,
    required String role,
  }) async {
    UserCredential cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );

    Map<String, dynamic> userData = {
      'uid': cred.user!.uid,
      'email': email.trim(),
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    };

    if (role == 'caregiver') {
      userData['linkedElders'] = [];
    } else {
      userData['inviteCode'] = '';
    }

    await _db.collection('users').doc(cred.user!.uid).set(userData);
    return cred;
  }

  Future<UserCredential> loginUser({
    required String email,
    required String password,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password.trim(),
    );
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
