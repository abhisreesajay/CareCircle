
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import 'elder_medication_screen.dart';
import 'hospital_documents_screen.dart';
import 'invite_code_screen.dart';
import 'nearby_services_screen.dart';
import 'medical_information_screen.dart';
import 'news_screen.dart';
import 'elder_emergency_contacts_screen.dart';

class ElderHome extends StatelessWidget {
  const ElderHome({super.key});

  // COLORS
  static const Color black = Color(0xFF111111);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F8FA);
  static const Color muted = Color(0xFF62666D);
  static const Color border = Color(0xFFE5E7EB);

  static const Color green = Color(0xFF009E60);
  static const Color greenLight = Color(0xFFE4F8EC);
  static const Color red = Color(0xFFE53935);
  static const Color redDark = Color(0xFFC62828);
  static const Color orange = Color(0xFFFF7A00);
  static const Color orangeLight = Color(0xFFFFF0DD);
  static const Color blue = Color(0xFF2474E8);
  static const Color blueLight = Color(0xFFE8F1FF);
  static const Color purple = Color(0xFF7651E8);
  static const Color purpleLight = Color(0xFFF0EBFF);
  static const Color cyan = Color(0xFF08A6B5);
  static const Color cyanLight = Color(0xFFE5F8FA);
  static const Color yellow = Color(0xFFFFB800);
  static const Color yellowLight = Color(0xFFFFF7D9);
  static const Color pink = Color(0xFFE84D78);
  static const Color pinkLight = Color(0xFFFFEAF0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 72,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [orange, yellow],
                ),
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: white,
                size: 24,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'CARE CIRCLE',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: black,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Your care, all in one place',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: IconButton(
              tooltip: 'Logout',
              onPressed: () => _showLogoutDialog(context),
              icon: const Icon(
                Icons.logout_rounded,
                color: black,
                size: 23,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 28 : 14,
                vertical: 14,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeBanner(isWide),
                      const SizedBox(height: 22),
                      const Text(
                        'Your day',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: black,
                        ),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        'Quick ways to check in and stay connected.',
                        style: TextStyle(
                          fontSize: 14,
                          color: muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 15),

                      // Main actions
                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _buildCheckInCard(context)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildSOSCard(context)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildVoiceCheckInCard(context)),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(child: _buildCheckInCard(context)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _buildVoiceCheckInCard(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            _buildSOSCard(context),
                          ],
                        ),

                      const SizedBox(height: 26),

                      _buildSectionHeader(
                        title: 'Everyday Care',
                        subtitle: 'Your important health tools',
                      ),
                      const SizedBox(height: 12),
                      _buildFeatureGrid(context, isWide: isWide),

                      // EMERGENCY CONTACTS
                      const SizedBox(height: 18),
                      _buildMoreCard(
                        context,
                        title: 'Emergency Contacts',
                        subtitle: 'Call your family or trusted contacts',
                        icon: Icons.contact_phone_rounded,
                        iconColor: red,
                        backgroundColor: const Color(0xFFFFE8E8),
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
                                  ElderEmergencyContactsScreen(elderId: uid),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 26),

                      _buildSectionHeader(
                        title: 'More for You',
                        subtitle: 'Helpful things around you',
                      ),
                      const SizedBox(height: 12),

                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildMoreCard(
                                context,
                                title: 'Nearby Services',
                                subtitle:
                                    'Hospitals, shops, restaurants and care',
                                icon: Icons.location_on_rounded,
                                iconColor: green,
                                backgroundColor: greenLight,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const ElderNearbyServicesScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildMoreCard(
                                context,
                                title: 'Caregiver',
                                subtitle: 'Connect with your caregiver',
                                icon: Icons.people_alt_rounded,
                                iconColor: pink,
                                backgroundColor: pinkLight,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const InviteCodeScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            _buildMoreCard(
                              context,
                              title: 'Nearby Services',
                              subtitle:
                                  'Hospitals, shops, restaurants and care',
                              icon: Icons.location_on_rounded,
                              iconColor: green,
                              backgroundColor: greenLight,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const ElderNearbyServicesScreen(),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            _buildMoreCard(
                              context,
                              title: 'Caregiver',
                              subtitle: 'Connect with your caregiver',
                              icon: Icons.people_alt_rounded,
                              iconColor: pink,
                              backgroundColor: pinkLight,
                              onTap: () {
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

                      const SizedBox(height: 22),
                      _buildHelpCard(),
                      const SizedBox(height: 18),
                      const Center(
                        child: Text(
                          'Care • Connect • Safe',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: muted,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // WELCOME
  Widget _buildWelcomeBanner(bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 22 : 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF3D8), Color(0xFFFFF9EE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFFFE4AD)),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good day!',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                    color: black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Stay healthy, stay connected.',
                  style: TextStyle(
                    fontSize: 15,
                    color: muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: yellow,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: yellow.withValues(alpha: 0.25),
                  blurRadius: 12,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: white,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  // SECTION HEADER
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // DAILY CHECK-IN
  Widget _buildCheckInCard(BuildContext context) {
    return _buildMainActionCard(
      title: 'Daily Check-in',
      subtitle: 'How are you today?',
      icon: Icons.calendar_month_rounded,
      iconColor: green,
      backgroundColor: greenLight,
      buttonText: 'Check In',
      onTap: () => Navigator.pushNamed(context, '/checkin'),
    );
  }

  // VOICE CHECK-IN
  Widget _buildVoiceCheckInCard(BuildContext context) {
    return _buildMainActionCard(
      title: 'Voice Check-in',
      subtitle: 'Speak with us',
      icon: Icons.mic_rounded,
      iconColor: orange,
      backgroundColor: orangeLight,
      buttonText: 'Start',
      onTap: () => Navigator.pushNamed(context, '/voice-checkin'),
    );
  }

  // MAIN ACTION CARD
  Widget _buildMainActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 32),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                  ),
                  label: Text(
                    buttonText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    backgroundColor: iconColor,
                    foregroundColor: white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // SOS
  Widget _buildSOSCard(BuildContext context) {
    return Material(
      color: red,
      borderRadius: BorderRadius.circular(22),
      elevation: 2,
      shadowColor: red.withValues(alpha: 0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () => Navigator.pushNamed(context, '/sos'),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: red,
                  size: 31,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Emergency SOS',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Tap to get immediate help',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: redDark,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: white.withValues(alpha: 0.8),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: white,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // EVERYDAY CARE GRID
  Widget _buildFeatureGrid(
    BuildContext context, {
    required bool isWide,
  }) {
    final items = [
      _FeatureItem(
        title: 'My Medications',
        subtitle: 'Today\'s medicines',
        icon: Icons.medication_rounded,
        iconColor: orange,
        backgroundColor: orangeLight,
        onTap: () {
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

          if (uid.isEmpty) {
            _showMessage(context, 'Unable to identify your account.');
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
      _FeatureItem(
        title: 'Medical Information',
        subtitle: 'Your health details',
        icon: Icons.medical_information_rounded,
        iconColor: blue,
        backgroundColor: blueLight,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const MedicalInformationScreen(),
            ),
          );
        },
      ),
      _FeatureItem(
        title: 'Hospital Documents',
        subtitle: 'Your medical files',
        icon: Icons.folder_rounded,
        iconColor: cyan,
        backgroundColor: cyanLight,
        onTap: () {
          final uid = FirebaseAuth.instance.currentUser?.uid ?? '';

          if (uid.isEmpty) {
            _showMessage(context, 'Unable to identify your account.');
            return;
          }

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => HospitalDocumentsScreen(elderId: uid),
            ),
          );
        },
      ),
      _FeatureItem(
        title: 'Today\'s News',
        subtitle: 'Important updates',
        icon: Icons.newspaper_rounded,
        iconColor: yellow,
        backgroundColor: yellowLight,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const NewsScreen(),
            ),
          );
        },
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isWide ? 4 : 2,
        crossAxisSpacing: isWide ? 14 : 10,
        mainAxisSpacing: 12,
        // Fixed tile height avoids short-card overflow on narrow screens.
        mainAxisExtent: isWide ? 220 : 210,
      ),
      itemBuilder: (context, index) => _buildFeatureCard(items[index]),
    );
  }

  // FEATURE CARD
  Widget _buildFeatureCard(_FeatureItem item) {
    return Material(
      color: item.backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: item.iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(item.icon, color: white, size: 24),
              ),
              const SizedBox(height: 12),
              Text(
                item.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: item.iconColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // MORE CARD
  Widget _buildMoreCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: white, size: 25),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        color: black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: iconColor,
                  size: 18,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // HELP
  Widget _buildHelpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: yellowLight,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: orange,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'You\'re not alone. Your caregiver is here to help you.',
              style: TextStyle(
                color: black,
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MESSAGE
  static void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  // LOGOUT
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: white,
          surfaceTintColor: white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.w900,
              color: black,
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(
              fontSize: 16,
              color: muted,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'CANCEL',
                style: TextStyle(
                  color: black,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                await AuthService().signOut();
              },
              style: FilledButton.styleFrom(
                backgroundColor: black,
                foregroundColor: white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'LOGOUT',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        );
      },
    );
  }
}

// FEATURE MODEL
class _FeatureItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final VoidCallback onTap;

  const _FeatureItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.onTap,
  });
}