import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/auth_screen.dart';
import 'screens/emergency_contacts_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/safe_zone_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const CareCircleApp());
}

class CareCircleApp extends StatelessWidget {
  const CareCircleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CareCircle',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),

      // Login page opens first.
      home: const AuthScreen(),
    );
  }
}

class Person4Dashboard extends StatelessWidget {
  const Person4Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CareCircle Dashboard'),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.health_and_safety,
              size: 90,
              color: Colors.green,
            ),

            const SizedBox(height: 15),

            const Text(
              'Emergency, Safety & Location',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Person 4 Module',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 30),

            _buildFeatureButton(
              context: context,
              title: 'Safe Zone',
              subtitle: 'Create and manage elder safe zones',
              icon: Icons.location_on,
              color: Colors.blue,
              screen: const SafeZoneScreen(),
            ),

            const SizedBox(height: 15),

            _buildFeatureButton(
              context: context,
              title: 'Emergency Contacts',
              subtitle: 'Add, view and delete emergency contacts',
              icon: Icons.contacts,
              color: Colors.orange,
              screen: const EmergencyContactsScreen(),
            ),

            const SizedBox(height: 15),

            _buildFeatureButton(
              context: context,
              title: 'Emergency SOS',
              subtitle: 'Confirm SOS, get GPS location and save alert',
              icon: Icons.warning,
              color: Colors.red,
              screen: const EmergencyScreen(),
            ),

            const SizedBox(height: 30),

            Card(
              color: Colors.green.shade50,
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Person 4 Features',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),

                    SizedBox(height: 10),

                    Text(
                      '• Login before accessing the dashboard\n'
                      '• GPS location permission\n'
                      '• One-time location retrieval during SOS\n'
                      '• SOS record creation\n'
                      '• SOS cancellation\n'
                      '• Safe zone creation\n'
                      '• Emergency contact management\n'
                      '• FCM token registration\n'
                      '• Background safe-zone exit monitoring: pending\n'
                      '• Safe-zone exit notifications: pending',
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget screen,
  }) {
    return Card(
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),

        leading: CircleAvatar(
          radius: 28,
          backgroundColor: color,
          child: Icon(
            icon,
            color: Colors.white,
            size: 30,
          ),
        ),

        title: Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(subtitle),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
        ),

        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => screen,
            ),
          );
        },
      ),
    );
  }
}