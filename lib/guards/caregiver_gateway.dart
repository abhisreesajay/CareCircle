import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// EXACT path based on your tree output
import '../screens/caregiver/caregiver_dashboard.dart';

class CaregiverGateway extends StatelessWidget {
  const CaregiverGateway({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Scaffold(body: Center(child: Text("Not logged in")));

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: Text("Profile not found")));
        }

        // Safely extract data map
        final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
        
        // Safely extract array
        final linkedElders = List.from(data['linkedElders'] ?? []);

        if (linkedElders.isEmpty) {
          return const Scaffold(body: Center(child: Text("Route to: Invite Code Screen")));
        }

        return CaregiverDashboard(elderId: linkedElders.first.toString());
      },
    );
  }
}
