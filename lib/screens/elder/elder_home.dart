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

  // ================================================================
  // COLORS
  // ================================================================

  static const Color black = Color(0xFF111111);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF7F8FA);
  static const Color muted = Color(0xFF62666D);
  static const Color border = Color(0xFFE5E7EB);

  // Feature colors
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

      // ==============================================================
      // APP BAR
      // ==============================================================

      appBar: AppBar(
        backgroundColor: white,
        foregroundColor: black,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        toolbarHeight: 78,
        titleSpacing: 22,
        title: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    orange,
                    yellow,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: white,
                size: 25,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CARE CIRCLE',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                    color: black,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Your care, all in one place',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: muted,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F2F4),
              borderRadius: BorderRadius.circular(15),
            ),
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

      // ==============================================================
      // BODY
      // ==============================================================

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 850;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isWide ? 32 : 16,
                vertical: 18,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: 1200,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWelcomeBanner(isWide),

                      const SizedBox(height: 26),

                      const Text(
                        'Your day',
                        style: TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.w900,
                          color: black,
                        ),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        'Quick ways to check in and stay connected.',
                        style: TextStyle(
                          fontSize: 15,
                          color: muted,
                          fontWeight: FontWeight.w500,
                        ),
                      ),

                      const SizedBox(height: 17),

                      // ==================================================
                      // MAIN THREE ACTIONS
                      // ==================================================

                      if (isWide)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildCheckInCard(context),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildSOSCard(context),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _buildVoiceCheckInCard(context),
                            ),
                          ],
                        )
                      else
                        Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCheckInCard(context),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildVoiceCheckInCard(context),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _buildSOSCard(context),
                          ],
                        ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // EVERYDAY CARE
                      // ==================================================

                      _buildSectionHeader(
                        title: 'Everyday Care',
                        subtitle: 'Your important health tools',
                      ),

                      const SizedBox(height: 14),

                      _buildFeatureGrid(
                        context,
                        isWide: isWide,
                      ),

                      const SizedBox(height: 30),

                      // ==================================================
                      // MORE FOR YOU
                      // ==================================================

                      _buildSectionHeader(
                        title: 'More for You',
                        subtitle: 'Helpful things around you',
                      ),

                      const SizedBox(height: 14),

                      if (isWide)
                        Row(
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
                            const SizedBox(width: 14),
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
                            const SizedBox(height: 12),
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
                                    builder: (_) =>
                                        const InviteCodeScreen(),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),

                      const SizedBox(height: 24),

                      _buildHelpCard(),

                      const SizedBox(height: 22),

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

                      const SizedBox(height: 12),
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

  // ================================================================
  // WELCOME
  // ================================================================

  Widget _buildWelcomeBanner(bool isWide) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isWide ? 26 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFFF3D8),
            Color(0xFFFFF9EE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: const Color(0xFFFFE4AD),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Good day!',
                  style: TextStyle(
                    fontSize: 29,
                    fontWeight: FontWeight.w900,
                    color: black,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Stay healthy, stay connected.',
                  style: TextStyle(
                    fontSize: 16,
                    color: muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: yellow,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: yellow.withValues(alpha: 0.25),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(
              Icons.wb_sunny_rounded,
              color: white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }

  // ================================================================
  // SECTION HEADER
  // ================================================================

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
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 14,
            color: muted,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // ================================================================
  // DAILY CHECK-IN
  // ================================================================

  Widget _buildCheckInCard(BuildContext context) {
    return _buildMainActionCard(
      title: 'Daily Check-in',
      subtitle: 'How are you today?',
      icon: Icons.calendar_month_rounded,
      iconColor: green,
      backgroundColor: greenLight,
      buttonText: 'Check In',
      onTap: () {
        Navigator.pushNamed(context, '/checkin');
      },
    );
  }

  // ================================================================
  // VOICE CHECK-IN
  // ================================================================

  Widget _buildVoiceCheckInCard(BuildContext context) {
    return _buildMainActionCard(
      title: 'Voice Check-in',
      subtitle: 'Speak with us',
      icon: Icons.mic_rounded,
      iconColor: orange,
      backgroundColor: orangeLight,
      buttonText: 'Start',
      onTap: () {
        Navigator.pushNamed(context, '/voice-checkin');
      },
    );
  }

  // ================================================================
  // MAIN ACTION CARD
  // ================================================================

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
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 245,
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: const BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: black,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: onTap,
                  icon: const Icon(
                    Icons.arrow_forward_rounded,
                    size: 21,
                  ),
                  label: Text(
                    buttonText,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
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

  // ================================================================
  // SOS
  // ================================================================

  Widget _buildSOSCard(BuildContext context) {
    return Material(
      color: red,
      borderRadius: BorderRadius.circular(26),
      elevation: 2,
      shadowColor: red.withValues(alpha: 0.25),
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: () {
          // TEMPORARY:
          // This currently opens your existing SOS screen.
          //
          // Once you send me emergency_screen.dart, this will be
          // replaced with the actual direct SOS sending method.
          Navigator.pushNamed(context, '/sos');
        },
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 245,
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.warning_rounded,
                  color: red,
                  size: 42,
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Emergency SOS',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tap to get immediate help',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                height: 50,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: redDark,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: white.withValues(alpha: 0.8),
                    width: 2,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.notifications_active_rounded,
                      color: white,
                      size: 22,
                    ),
                    SizedBox(width: 9),
                    Text(
                      'SEND SOS',
                      style: TextStyle(
                        color: white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // EVERYDAY CARE GRID
  // ================================================================

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
              builder: (_) => ElderMedicationScreen(
                elderId: uid,
              ),
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
              builder: (_) =>
                  const MedicalInformationScreen(),
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
              builder: (_) => HospitalDocumentsScreen(
                elderId: uid,
              ),
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

    if (isWide) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (context, index) {
          return _buildFeatureCard(items[index]);
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.08,
      ),
      itemBuilder: (context, index) {
        return _buildFeatureCard(items[index]);
      },
    );
  }

  // ================================================================
  // FEATURE CARD
  // ================================================================

  Widget _buildFeatureCard(_FeatureItem item) {
    return Material(
      color: item.backgroundColor,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: item.iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: white,
                  size: 28,
                ),
              ),
              const Spacer(),
              Text(
                item.title,
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
                item.subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: muted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Icon(
                Icons.arrow_forward_rounded,
                color: item.iconColor,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // MORE CARD
  // ================================================================

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
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: white,
                  size: 29,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
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
                        fontSize: 13,
                        color: muted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: iconColor,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ================================================================
  // HELP
  // ================================================================

  Widget _buildHelpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: yellowLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.favorite_rounded,
              color: orange,
              size: 25,
            ),
          ),
          const SizedBox(width: 13),
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

  // ================================================================
  // MESSAGE
  // ================================================================

  static void _showMessage(
    BuildContext context,
    String message,
  ) {
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

  // ================================================================
  // LOGOUT
  // ================================================================

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
              onPressed: () {
                Navigator.pop(dialogContext);
              },
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
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ================================================================
// FEATURE MODEL
// ================================================================

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