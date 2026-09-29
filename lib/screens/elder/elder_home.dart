import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'elder_medication_screen.dart';
import 'hospital_documents_screen.dart';
import 'invite_code_screen.dart';
import 'nearby_services_screen.dart';
import 'medical_information_screen.dart';
import 'news_screen.dart';

class ElderHome extends StatelessWidget {
  const ElderHome({super.key});

  static const Color primary = Color(0xFF415111);
  static const Color orange = Color(0xFFFB8159);
  static const Color lightGreen = Color(0xFFD2E186);
  static const Color cream = Color(0xFFF2E8DF);
  static const Color background = Color(0xFFFEFEFE);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF6A6D5B);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // ================================================================
      // APP BAR
      // ================================================================
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primary,
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
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: () {
              _showLogoutDialog(context);
            },
            icon: const Icon(Icons.logout_rounded, size: 25),
          ),
          const SizedBox(width: 4),
        ],
      ),

      // ================================================================
      // BODY
      // ================================================================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================================
              // WELCOME
              // ==========================================================

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF3F7DE), Color(0xFFFFF8F2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE8EBD8)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome to Care Circle',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'How can we help you today?',
                            style: TextStyle(
                              fontSize: 15,
                              color: mutedText,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ==========================================================
              // QUICK ACTIONS HEADER
              // ==========================================================
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Choose what you need',
                style: TextStyle(fontSize: 14, color: mutedText),
              ),

              const SizedBox(height: 14),

              // ==========================================================
              // FEATURED CHECK-IN ROW
              // ==========================================================
              Row(
                children: [
                  Expanded(
                    child: _buildLargeAction(
                      context: context,
                      title: 'Daily Check-in',
                      subtitle: 'How are you today?',
                      icon: Icons.check_circle_outline_rounded,
                      backgroundColor: lightGreen,
                      iconColor: primary,
                      route: '/checkin',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildLargeAction(
                      context: context,
                      title: 'Voice Check-in',
                      subtitle: 'Speak with us',
                      icon: Icons.mic_none_rounded,
                      backgroundColor: const Color(0xFFFFD9BF),
                      iconColor: const Color(0xFF9A674C),
                      route: '/voice-checkin',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // ==========================================================
              // SOS
              // ==========================================================
              _buildEmergencyCard(context),

              const SizedBox(height: 12),

              // ==========================================================
              // MEDICATION + DOCUMENTS
              // ==========================================================
              Row(
                children: [
                  Expanded(
                    child: _buildSmallAction(
                      context: context,
                      title: 'My Medications',
                      subtitle: 'Today\'s medicines',
                      icon: Icons.medication_rounded,
                      backgroundColor: cream,
                      iconColor: primary,
                      onTap: () {
                        final uid =
                            FirebaseAuth.instance.currentUser?.uid ?? '';

                        if (uid.isEmpty) {
                          _showMessage(
                            context,
                            'Unable to identify your account.',
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ElderMedicationScreen(elderId: uid),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildSmallAction(
                      context: context,
                      title: 'Hospital Documents',
                      subtitle: 'Your medical documents',
                      icon: Icons.folder_shared_rounded,
                      backgroundColor: const Color(0xFFF1F4E5),
                      iconColor: primary,
                      onTap: () {
                        final uid =
                            FirebaseAuth.instance.currentUser?.uid ?? '';

                        if (uid.isEmpty) {
                          _showMessage(
                            context,
                            'Unable to identify your account.',
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                HospitalDocumentsScreen(elderId: uid),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              // ==========================================================
              // NEWS
              // ==========================================================
              _buildSmallAction(
                context: context,
                title: 'Today\'s News',
                subtitle: 'Important headlines',
                icon: Icons.newspaper_rounded,
                backgroundColor: const Color(0xFFE8F0E4),
                iconColor: primary,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NewsScreen()),
                  );
                },
              ),

              const SizedBox(height: 12),
              // ==========================================================
              // MEDICAL INFORMATION
              // ELDER CAN VIEW ONLY
              // ==========================================================

              _buildMedicalInformationCard(context),

              const SizedBox(height: 12),

              // ==========================================================
              // NEARBY SERVICES
              // ==========================================================
              _buildNearbyServicesCard(context),

              const SizedBox(height: 12),

              // ==========================================================
              // CAREGIVER CONNECTION
              // ==========================================================
              _buildConnectionCard(context),

              const SizedBox(height: 22),

              // ==========================================================
              // HELP INFORMATION
              // ==========================================================
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Colors.white,
                      size: 27,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Need help? Use Emergency SOS or contact your caregiver.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  'Care • Connect • Safe',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF7A7D6D),
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

  // ====================================================================
  // DAILY / VOICE LARGE ACTION
  // ====================================================================

  Widget _buildLargeAction({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    String? route,
    VoidCallback? onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap:
            onTap ??
            () {
              if (route != null) {
                Navigator.pushNamed(context, route);
              }
            },
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(height: 25),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: mutedText),
              ),
              const SizedBox(height: 9),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: iconColor,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // EMERGENCY SOS
  // ====================================================================

  Widget _buildEmergencyCard(BuildContext context) {
    return Material(
      color: orange,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.pushNamed(context, '/sos');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 17),
          child: Row(
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Get immediate help',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: Colors.white,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // MEDICATION / DOCUMENTS
  // ====================================================================

  Widget _buildSmallAction({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color backgroundColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.65),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, color: iconColor, size: 26),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: mutedText),
              ),
              const SizedBox(height: 9),
              const Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: primary,
                  size: 19,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // MEDICAL INFORMATION
  // ELDER VIEW ONLY
  // ====================================================================

  Widget _buildMedicalInformationCard(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF5EA),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MedicalInformationScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: orange,
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.medical_information_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Medical Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'View your health information',
                      style: TextStyle(
                        fontSize: 13,
                        color: mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: orange,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // NEARBY SERVICES
  // IMPORTANT:
  // Directly opens NearbyServicesScreen.
  // No '/services' named route is used.
  // ====================================================================

  Widget _buildNearbyServicesCard(BuildContext context) {
    return Material(
      color: const Color(0xFFE8F0D4),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const ElderNearbyServicesScreen(),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(19),
          child: Row(
            children: [
              Container(
                width: 61,
                height: 61,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(19),
                ),
                child: const Icon(
                  Icons.explore_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nearby Services',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Hospitals • Shops • Restaurants • Care',
                      style: TextStyle(fontSize: 12, color: mutedText),
                    ),
                  ],
                ),
              ),
              Container(
                width: 39,
                height: 39,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_rounded,
                  color: primary,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // CAREGIVER CONNECTION
  // ====================================================================

  Widget _buildConnectionCard(BuildContext context) {
    return Material(
      color: const Color(0xFFFFF0E7),
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const InviteCodeScreen()),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 51,
                height: 51,
                decoration: BoxDecoration(
                  color: const Color(0xFF9A5A48),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.link_rounded,
                  color: Colors.white,
                  size: 27,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Caregiver Connection',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Connect with your caregiver',
                      style: TextStyle(fontSize: 12, color: mutedText),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 17,
                color: Color(0xFF9A5A48),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ====================================================================
  // MESSAGE
  // ====================================================================

  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // ====================================================================
  // LOGOUT
  // ====================================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: primary,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(fontSize: 17, color: mutedText),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'CANCEL',
                style: TextStyle(color: primary, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await AuthService().signOut();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: orange,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                'LOGOUT',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
