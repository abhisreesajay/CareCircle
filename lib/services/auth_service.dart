import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserCredential?> registerUser({
    required String email,
    required String password,
    required String role, // Received from SignUpScreen ('elder' or 'caregiver')
  }) async {
    try {
      // Step 1: Create authentication account
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Step 2: Build document payload
      Map<String, dynamic> userData = {
        'uid': cred.user!.uid,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add role-specific schema fields
      if (role == 'caregiver') {
        userData['linkedElders'] = []; // Array storing UIDs of elders they look after
      } else {
        userData['inviteCode'] = ''; // Code used by caregivers to link to this elder
      }

      // Step 3: Save payload to /users/{uid}
      await _db.collection('users').doc(cred.user!.uid).set(userData);

      return cred;
    } catch (e) {
      rethrow;
    }
  }
}
