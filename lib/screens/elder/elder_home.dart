import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
<<<<<<< HEAD
import '../../services/auth_service.dart'; // Added this import

class ElderHome extends StatelessWidget {
  const ElderHome({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
=======

import 'elder_medication_screen.dart';
import 'hospital_documents_screen.dart';
import 'invite_code_screen.dart';

class ElderHome extends StatelessWidget {
  const ElderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFEFE),

>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF415111),
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CARE CIRCLE',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              'Elder Care Assistant',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(
              Icons.logout_rounded,
              size: 25,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            14,
            16,
            14,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEFEFE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFF2E8DF),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Care Circle',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF415111),
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'How can we help you today?',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF6A6D5B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

<<<<<<< HEAD
=======
              const SizedBox(height: 28),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF163B4D),
                ),
              ),

              const SizedBox(height: 15),

              // Check-in
              _buildActionCard(
                context: context,
                title: 'Daily Check-in',
                subtitle: 'Tell us how you are feeling',
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF16845B),
                backgroundColor: const Color(0xFFE8F6EF),
                route: '/checkin',
              ),

                           const SizedBox(height: 14),

              // Check-in Reminders
              _buildActionCard(
                context: context,
                title: 'Check-in Reminders',
                subtitle: 'Set and manage daily reminders',
                icon: Icons.alarm_rounded,
                iconColor: const Color(0xFFB36B00),
                backgroundColor: const Color(0xFFFFF2DE),
                route: '/checkin-reminder',
              ),

              const SizedBox(height: 14),

              // Voice Check-in
              // Voice Check-in
              _buildActionCard(
                context: context,
                title: 'Voice Check-in',
                subtitle: 'Speak instead of typing',
                icon: Icons.mic_none_rounded,
                iconColor: const Color(0xFF3867A6),
                backgroundColor: const Color(0xFFEAF1FB),
                route: '/voice-checkin',
              ),

              const SizedBox(height: 14),

              // SOS
              _buildActionCard(
                context: context,
                title: 'Emergency SOS',
                subtitle: 'Get immediate emergency help',
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFC62828),
                backgroundColor: const Color(0xFFFFEAEA),
                route: '/sos',
                isEmergency: true,
              ),

              const SizedBox(height: 14),

              // Hospitals
              _buildActionCard(
                context: context,
                title: 'Nearby Hospitals',
                subtitle: 'Find hospitals near you',
                icon: Icons.local_hospital_outlined,
                iconColor: const Color(0xFF7A4FA3),
                backgroundColor: const Color(0xFFF3EAF8),
                route: '/hospitals',
              ),

              const SizedBox(height: 14),

              // Services
              _buildActionCard(
                context: context,
                title: 'Nearby Services',
                subtitle: 'Find shops and restaurants nearby',
                icon: Icons.storefront_outlined,
                iconColor: const Color(0xFFB36B00),
                backgroundColor: const Color(0xFFFFF2DE),
                route: '/services',
              ),

              const SizedBox(height: 28),

              // Help information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF164A63),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Need help? Use the Emergency SOS button or contact your caregiver.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

>>>>>>> develop
              const SizedBox(height: 18),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF415111),
                ),
              ),

              const SizedBox(height: 10),

              // Smaller vertical cards
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.08,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  // Daily Check-in
                  _buildActionCard(
                    context: context,
                    title: 'Daily\nCheck-in',
                    subtitle: 'Tell us how you feel',
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: const Color(0xFF415111),
                    backgroundColor: const Color(0xFFD2E186),
                    route: '/checkin',
                  ),

                  // Voice Check-in
                  _buildActionCard(
                    context: context,
                    title: 'Voice\nCheck-in',
                    subtitle: 'Speak instead of typing',
                    icon: Icons.mic_none_rounded,
                    iconColor: const Color(0xFF9A674C),
                    backgroundColor: const Color(0xFFFCBF93),
                    route: '/voice-checkin',
                  ),

                  // My Medications
                  _buildActionCard(
                    context: context,
                    title: 'My\nMedications',
                    subtitle: 'Today\'s medicines',
                    icon: Icons.medication_rounded,
                    iconColor: const Color(0xFF415111),
                    backgroundColor: const Color(0xFFF2E8DF),
                    onTapOverride: () {
                      final uid =
                          FirebaseAuth.instance.currentUser?.uid ?? '';

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ElderMedicationScreen(
                            elderId: uid,
                          ),
                        ),
                      );
                    },
                  ),

                  // Hospital Documents
                  _buildActionCard(
                    context: context,
                    title: 'Hospital\nDocuments',
                    subtitle: 'Access medical documents',
                    icon: Icons.folder_shared_rounded,
                    iconColor: const Color(0xFF415111),
                    backgroundColor: const Color(0xFFFEFEFE),
                    onTapOverride: () {
                      final uid =
                          FirebaseAuth.instance.currentUser?.uid ?? '';

                      if (uid.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Unable to identify your account.',
                            ),
                          ),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HospitalDocumentsScreen(
                            elderId: uid,
                          ),
                        ),
                      );
                    },
                  ),

                  // Emergency SOS
                  _buildActionCard(
                    context: context,
                    title: 'Emergency\nSOS',
                    subtitle: 'Get immediate help',
                    icon: Icons.warning_amber_rounded,
                    iconColor: Colors.white,
                    backgroundColor: const Color(0xFFFB8159),
                    route: '/sos',
                    isEmergency: true,
                  ),

                  // Nearby Hospitals
                  _buildActionCard(
                    context: context,
                    title: 'Nearby\nHospitals',
                    subtitle: 'Find hospitals near you',
                    icon: Icons.local_hospital_outlined,
                    iconColor: Colors.white,
                    backgroundColor: const Color(0xFF415111),
                    route: '/hospitals',
                  ),

                  // Nearby Services
                  _buildActionCard(
                    context: context,
                    title: 'Nearby\nServices',
                    subtitle: 'Find shops nearby',
                    icon: Icons.storefront_outlined,
                    iconColor: const Color(0xFF415111),
                    backgroundColor: const Color(0xFFD2E186),
                    route: '/services',
                  ),

                  // Caregiver Connection
                  _buildActionCard(
                    context: context,
                    title: 'Caregiver\nConnection',
                    subtitle: 'Connect with caregiver',
                    icon: Icons.link_rounded,
                    iconColor: const Color(0xFF9A5A48),
                    backgroundColor: const Color(0xFFF2E8DF),
                    onTapOverride: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InviteCodeScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Help information
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFF415111),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Need help? Use Emergency SOS or contact your caregiver.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Center(
                child: Text(
                  'Care • Connect • Safe',
                  style: TextStyle(
                    fontSize: 13,
                    color: const Color(0xFF7A7D6D),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    String? route,
    VoidCallback? onTapOverride,
    bool isEmergency = false,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (onTapOverride != null) {
            onTapOverride();
          } else if (route != null) {
            Navigator.pushNamed(
              context,
              route,
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Small icon
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
<<<<<<< HEAD
                const SizedBox(width: 17),
                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: isEmergency
                              ? const Color(0xFFC62828)
                              : const Color(0xFF163B4D),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF63747B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20,
                  color: Color(0xFF78909C),
=======
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 25,
                ),
              ),

              const Spacer(),

              // Title
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.05,
                  color: isEmergency
                      ? Colors.white
                      : const Color(0xFF415111),
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
                ),
              ),

              const SizedBox(height: 5),

              // Subtitle
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.15,
                  color: isEmergency
                      ? Colors.white.withValues(alpha: 0.9)
                      : const Color(0xFF66695A),
                ),
              ),

              const SizedBox(height: 5),

              // Arrow
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 18,
                  color: isEmergency
                      ? Colors.white
                      : const Color(0xFF59653A),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(
    BuildContext context,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFEFEFE),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF415111),
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 17,
              color: Color(0xFF66695A),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF415111),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog first
                await AuthService().signOut(); // Actually log the user out
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFB8159),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'LOGOUT',
                style: TextStyle(
                  fontSize: 15,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}