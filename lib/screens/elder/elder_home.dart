import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ElderHome extends StatelessWidget {
  const ElderHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4EFE5),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF46695A),
        foregroundColor: Colors.white,
        centerTitle: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'CARE CIRCLE',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            Text(
              'Elder Care Assistant',
              style: TextStyle(
                fontSize: 13,
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
              size: 28,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            24,
            20,
            30,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // WELCOME
              // --------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBF4),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome to Care Circle',
                      style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF26352F),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'How can we help you today?',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF46695A),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26352F),
                ),
              ),

              const SizedBox(height: 15),

              // --------------------------------------------------
              // 1. CHECK-IN
              // --------------------------------------------------

              _buildActionCard(
                context: context,
                title: 'Daily Check-in',
                subtitle: 'Let your caregiver know you are okay',
                icon: Icons.check_circle_outline_rounded,
                iconColor: const Color(0xFF46695A),
                backgroundColor: const Color(0xFFE5F0EA),
                route: '/checkin',
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------
              // 2. VOICE CHECK-IN
              // --------------------------------------------------

              _buildActionCard(
                context: context,
                title: 'Voice Check-in',
                subtitle: 'Speak instead of typing',
                icon: Icons.mic_none_rounded,
                iconColor: const Color(0xFF5C7D72),
                backgroundColor: const Color(0xFFE9F0ED),
                route: '/voice-checkin',
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------
              // 3. SOS
              // --------------------------------------------------

              _buildActionCard(
                context: context,
                title: 'Emergency SOS',
                subtitle: 'Send an emergency alert',
                icon: Icons.warning_amber_rounded,
                iconColor: const Color(0xFFC85C50),
                backgroundColor: const Color(0xFFFBE8E5),
                route: '/sos',
                isEmergency: true,
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------
              // 4. NEARBY HOSPITALS
              // --------------------------------------------------

              _buildActionCard(
                context: context,
                title: 'Nearby Hospitals',
                subtitle: 'Find hospitals near you',
                icon: Icons.local_hospital_outlined,
                iconColor: const Color(0xFF8A6259),
                backgroundColor: const Color(0xFFF4E8E4),
                route: '/nearby-services',
              ),

              const SizedBox(height: 14),

              // --------------------------------------------------
              // 5. NEARBY SERVICES
              // --------------------------------------------------

              _buildActionCard(
                context: context,
                title: 'Nearby Services',
                subtitle: 'Find shops and restaurants nearby',
                icon: Icons.storefront_outlined,
                iconColor: const Color(0xFF8A7448),
                backgroundColor: const Color(0xFFF4EEDC),
                route: '/nearby-services',
              ),

              const SizedBox(height: 28),

              // --------------------------------------------------
              // HELP
              // --------------------------------------------------

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF46695A),
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
                        'Need help? Use Emergency SOS or contact your caregiver.',
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

              const SizedBox(height: 18),

              Center(
                child: Text(
                  'Care • Connect • Safe',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey.shade600,
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
    required String route,
    bool isEmergency = false,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Material(
        color: const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.pushNamed(
              context,
              route,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                Container(
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 34,
                  ),
                ),

                const SizedBox(width: 17),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: isEmergency
                              ? const Color(0xFFC85C50)
                              : const Color(0xFF26352F),
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF66756E),
                        ),
                      ),
                    ],
                  ),
                ),

                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20,
                  color: Color(0xFF789089),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: const Color(0xFFFFFBF4),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF26352F),
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 19,
              color: Color(0xFF46695A),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(fontSize: 17),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                try {
                  await FirebaseAuth.instance.signOut();
                } catch (error) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Logout failed: $error',
                        ),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF46695A),
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'LOGOUT',
                style: TextStyle(fontSize: 17),
              ),
            ),
          ],
        );
      },
    );
  }
}
