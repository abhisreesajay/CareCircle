import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RoleGuard {
  static Future<String?> getCurrentRole() async {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return null;
    }

    final DocumentSnapshot<Map<String, dynamic>> doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    if (!doc.exists) {
      return null;
    }

    return doc.data()?['role']?.toString();
  }

  static Future<bool> isCaregiver() async {
    return await getCurrentRole() == 'caregiver';
  }

  static Future<bool> isElder() async {
    return await getCurrentRole() == 'elder';
  }
}
