import 'package:flutter/material.dart';
import '../../services/auth_service.dart'; // Added this import

class ElderHome extends StatelessWidget {
  const ElderHome({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F8FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF164A63),
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
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
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
                        color: Color(0xFF163B4D),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'How can we help you today?',
                      style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF52656D),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.pushNamed(context, route);
          },
          child: Padding(
            padding: const EdgeInsets.all(17),
            child: Row(
              children: [
                // Icon box
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
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 19,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(fontSize: 17),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close the dialog first
                await AuthService().signOut(); // Actually log the user out
              },
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