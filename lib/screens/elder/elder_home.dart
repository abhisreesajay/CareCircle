import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';
import '../../services/safe_zone_service.dart';

import 'elder_medication_screen.dart';
import 'hospital_documents_screen.dart';
import 'invite_code_screen.dart';
import 'nearby_services_screen.dart';
import 'medical_information_screen.dart';
import 'news_screen.dart';
import 'elder_emergency_contacts_screen.dart';

import '../common/profile_screen.dart';
import '../common/settings_screen.dart';

class ElderHome extends StatefulWidget {
  const ElderHome({super.key});

  @override
  State<ElderHome> createState() => _ElderHomeState();
}

class _ElderHomeState extends State<ElderHome> {
  // ================================================================
  // EXISTING COLOUR PALETTE
  // ================================================================

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

  // ================================================================
  // ELDER NAME
  // ================================================================

  String get elderName {
    final user = FirebaseAuth.instance.currentUser;

    final displayName = user?.displayName?.trim();

    if (displayName != null && displayName.isNotEmpty) {
      return displayName;
    }

    return 'there';
  }

  String _formatName(String value) {
    final cleaned = value.replaceAll(RegExp(r'[._-]+'), ' ').trim();

    if (cleaned.isEmpty) {
      return 'there';
    }

    return cleaned
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map(
          (part) => part[0].toUpperCase() + part.substring(1).toLowerCase(),
        )
        .join(' ');
  }

  // ================================================================
  // BUILD
  // ================================================================

  @override
  Widget build(BuildContext context) {
    return _SafeZoneCheckOnOpen(
      child: Scaffold(
        backgroundColor: background,

        // ============================================================
        // APP BAR
        // ============================================================

        appBar: AppBar(
          backgroundColor: white,
          foregroundColor: black,
          elevation: 0,
          scrolledUnderElevation: 0,
          surfaceTintColor: Colors.transparent,
          automaticallyImplyLeading: false,
          toolbarHeight: 72,
          titleSpacing: 18,

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
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: orange.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: white,
                  size: 24,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, $elderName',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: black,
                        letterSpacing: -0.2,
                      ),
                    ),

                    const SizedBox(height: 2),

                    const Text(
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
            IconButton(
              tooltip: 'Profile',
              icon: const Icon(
                Icons.person_outline_rounded,
                size: 23,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(
                      role: 'elder',
                    ),
                  ),
                );
              },
            ),

            IconButton(
              tooltip: 'Settings',
              icon: const Icon(
                Icons.settings_outlined,
                size: 23,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const SettingsScreen(
                      role: 'elder',
                    ),
                  ),
                );
              },
            ),

            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                tooltip: 'Logout',
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 22,
                ),
                onPressed: () => _showLogoutDialog(context),
              ),
            ),
          ],
        ),

        // ============================================================
        // BODY
        // ============================================================

        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;

              final bool isDesktop = width >= 1100;
              final bool isTablet = width >= 700 && width < 1100;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),

                padding: EdgeInsets.symmetric(
                  horizontal: isDesktop
                      ? 34
                      : isTablet
                          ? 26
                          : 16,
                  vertical: 20,
                ),

                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 1240,
                    ),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ==================================================
                        // HERO
                        // ==================================================

                        _buildWelcomeBanner(
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                        ),

                        const SizedBox(height: 28),

                        // ==================================================
                        // QUICK ACTIONS HEADER
                        // ==================================================

                        _buildSectionHeader(
                          title: 'How can we help?',
                          subtitle:
                              'Quick access to the things you use most.',
                        ),

                        const SizedBox(height: 16),

                        // IMPORTANT:
                        // This uses Wrap instead of Row + Expanded.
                        // This prevents the infinite-height constraint
                        // crash that happened in Chrome.
                        _buildPrimaryActions(
                          context,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                        ),

                        const SizedBox(height: 30),

                        // ==================================================
                        // EVERYDAY CARE
                        // ==================================================

                        _buildSectionHeader(
                          title: 'Everyday Care',
                          subtitle: 'Your important health tools.',
                        ),

                        const SizedBox(height: 16),

                        _buildFeatureGrid(
                          context,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                        ),

                        const SizedBox(height: 24),

                        // ==================================================
                        // EMERGENCY CONTACTS
                        // ==================================================

                        _buildEmergencyContactsCard(context),

                        const SizedBox(height: 30),

                        // ==================================================
                        // MORE FOR YOU
                        // ==================================================

                        _buildSectionHeader(
                          title: 'More for You',
                          subtitle:
                              'Stay connected, informed and supported.',
                        ),

                        const SizedBox(height: 16),

                        _buildMoreSection(
                          context,
                          isDesktop: isDesktop,
                          isTablet: isTablet,
                        ),

                        const SizedBox(height: 28),

                        // ==================================================
                        // SUPPORT
                        // ==================================================

                        _buildHelpCard(),

                        const SizedBox(height: 24),

                        const Center(
                          child: Text(
                            'Care • Connect • Safe',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
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
      ),
    );
  }

  // ================================================================
  // WELCOME BANNER
  // ================================================================

  Widget _buildWelcomeBanner({
    required bool isDesktop,
    required bool isTablet,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        isDesktop
            ? 28
            : isTablet
                ? 24
                : 20,
      ),
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
        boxShadow: [
          BoxShadow(
            color: orange.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),

      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 520;

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGreetingIcon(),

                const SizedBox(height: 18),

                _buildGreetingText(),
              ],
            );
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _buildGreetingText(),
              ),

              const SizedBox(width: 24),

              _buildGreetingIcon(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGreetingText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good day, $elderName!',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            color: black,
            letterSpacing: -0.7,
          ),
        ),

        const SizedBox(height: 7),

        const Text(
          'Stay healthy, stay connected.',
          style: TextStyle(
            fontSize: 15,
            color: muted,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 14),

        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: green,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Your CareCircle is here for you',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: muted,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGreetingIcon() {
    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: yellow,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: yellow.withValues(alpha: 0.25),
            blurRadius: 16,
            spreadRadius: 1,
          ),
        ],
      ),
      child: const Icon(
        Icons.wb_sunny_rounded,
        color: white,
        size: 34,
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
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: black,
            letterSpacing: -0.3,
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

  // ================================================================
  // PRIMARY ACTIONS
  // ================================================================

  Widget _buildPrimaryActions(
    BuildContext context, {
    required bool isDesktop,
    required bool isTablet,
  }) {
    // --------------------------------------------------------------
    // MOBILE
    // Daily Check-in + Voice Check-in side by side
    // Emergency SOS underneath in the middle
    // --------------------------------------------------------------
    if (!isDesktop && !isTablet) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildMainActionCard(
                  title: 'Daily Check-in',
                  subtitle: 'How are you today?',
                  icon: Icons.calendar_month_rounded,
                  iconColor: green,
                  backgroundColor: greenLight,
                  buttonText: 'Check In',
                  onTap: () {
                    Navigator.pushNamed(context, '/checkin');
                  },
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _buildMainActionCard(
                  title: 'Voice Check-in',
                  subtitle: 'Speak with us',
                  icon: Icons.mic_rounded,
                  iconColor: orange,
                  backgroundColor: orangeLight,
                  buttonText: 'Start',
                  onTap: () {
                    Navigator.pushNamed(context, '/voice-checkin');
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          _buildSOSCard(context),
        ],
      );
    }

    // --------------------------------------------------------------
    // TABLET / DESKTOP
    // Daily Check-in | Emergency SOS | Voice Check-in
    // --------------------------------------------------------------
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = isDesktop ? 16.0 : 12.0;

        final cardWidth =
            (constraints.maxWidth - (spacing * 2)) / 3;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: _buildMainActionCard(
                title: 'Daily Check-in',
                subtitle: 'How are you today?',
                icon: Icons.calendar_month_rounded,
                iconColor: green,
                backgroundColor: greenLight,
                buttonText: 'Check In',
                onTap: () {
                  Navigator.pushNamed(context, '/checkin');
                },
              ),
            ),

            SizedBox(
              width: cardWidth,
              child: _buildSOSCard(context),
            ),

            SizedBox(
              width: cardWidth,
              child: _buildMainActionCard(
                title: 'Voice Check-in',
                subtitle: 'Speak with us',
                icon: Icons.mic_rounded,
                iconColor: orange,
                backgroundColor: orangeLight,
                buttonText: 'Start',
                onTap: () {
                  Navigator.pushNamed(context, '/voice-checkin');
                },
              ),
            ),
          ],
        );
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
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(
            minHeight: 220,
          ),
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 30,
                ),
              ),

              const SizedBox(height: 18),

              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                  color: black,
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 5),

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

              const SizedBox(height: 18),

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
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: iconColor,
                    foregroundColor: white,
                    elevation: 0,
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

  // ================================================================
  // SOS
  // ================================================================

  Widget _buildSOSCard(BuildContext context) {
    return Material(
      color: red,
      borderRadius: BorderRadius.circular(22),
      elevation: 2,
      shadowColor: red.withValues(alpha: 0.20),

      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: () {
          Navigator.pushNamed(context, '/sos');
        },

        child: Container(
          constraints: const BoxConstraints(
            minHeight: 220,
          ),
          padding: const EdgeInsets.all(18),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.warning_rounded,
                      color: red,
                      size: 30,
                    ),
                  ),

                  const Spacer(),

                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: redDark,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: white,
                      size: 21,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              const Text(
                'Emergency SOS',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: white,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Tap here when you need immediate help.',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: white,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: redDark,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: white.withValues(alpha: 0.7),
                  ),
                ),
                child: const Text(
                  'GET HELP',
                  style: TextStyle(
                    color: white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
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
  // FEATURE GRID
  // ================================================================

  Widget _buildFeatureGrid(
    BuildContext context, {
    required bool isDesktop,
    required bool isTablet,
  }) {
    final items = [
      _FeatureItem(
        title: 'My Medications',
        subtitle: "Today's medicines",
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
        title: "Today's News",
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

    final crossAxisCount =
        isDesktop
            ? 4
            : isTablet
                ? 2
                : 2;

    final spacing = isDesktop ? 16.0 : 12.0;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,

      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        mainAxisExtent: isDesktop
            ? 220
            : isTablet
                ? 210
                : 200,
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
      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: item.onTap,

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: item.iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: white,
                  size: 24,
                ),
              ),

              const SizedBox(height: 14),

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

              const SizedBox(height: 5),

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
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    color: item.iconColor,
                    size: 18,
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
  // EMERGENCY CONTACTS
  // ================================================================

  Widget _buildEmergencyContactsCard(BuildContext context) {
    return _buildMoreCard(
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
            builder: (_) => ElderEmergencyContactsScreen(
              elderId: uid,
            ),
          ),
        );
      },
    );
  }

  // ================================================================
  // MORE SECTION
  // ================================================================

  Widget _buildMoreSection(
    BuildContext context, {
    required bool isDesktop,
    required bool isTablet,
  }) {
    final nearbyCard = _buildMoreCard(
      context,
      title: 'Nearby Services',
      subtitle: 'Hospitals, shops, restaurants and care',
      icon: Icons.location_on_rounded,
      iconColor: green,
      backgroundColor: greenLight,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ElderNearbyServicesScreen(),
          ),
        );
      },
    );

    final caregiverCard = _buildMoreCard(
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
    );

    if (!isDesktop && !isTablet) {
      return Column(
        children: [
          nearbyCard,
          const SizedBox(height: 12),
          caregiverCard,
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 16.0;

        final cardWidth =
            (constraints.maxWidth - spacing) / 2;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            SizedBox(
              width: cardWidth,
              child: nearbyCard,
            ),
            SizedBox(
              width: cardWidth,
              child: caregiverCard,
            ),
          ],
        );
      },
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
      borderRadius: BorderRadius.circular(20),

      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,

        child: Padding(
          padding: const EdgeInsets.all(16),

          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: white,
                  size: 25,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
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
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              Container(
                width: 34,
                height: 34,
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

  // ================================================================
  // HELP CARD
  // ================================================================

  Widget _buildHelpCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: border,
        ),
        boxShadow: [
          BoxShadow(
            color: black.withValues(alpha: 0.035),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
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

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You’re not alone',
                  style: TextStyle(
                    color: black,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: 4),

                Text(
                  'Your caregiver is here to help you whenever you need support.',
                  style: TextStyle(
                    color: muted,
                    fontSize: 12,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
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
    showDialog<void>(
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
              fontSize: 15,
              color: muted,
              height: 1.4,
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

// ==================================================================
// FEATURE MODEL
// ==================================================================

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

// ==================================================================
// SAFE ZONE CHECK
// ==================================================================

/// Checks the elder's location once when the dashboard opens.
///
/// This is not continuous or background location monitoring.
class _SafeZoneCheckOnOpen extends StatefulWidget {
  final Widget child;

  const _SafeZoneCheckOnOpen({
    required this.child,
  });

  @override
  State<_SafeZoneCheckOnOpen> createState() =>
      _SafeZoneCheckOnOpenState();
}

class _SafeZoneCheckOnOpenState
    extends State<_SafeZoneCheckOnOpen> {
  bool _checkStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_checkStarted) {
      return;
    }

    _checkStarted = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkSafeZone();
    });
  }

  Future<void> _checkSafeZone() async {
    final uid =
        FirebaseAuth.instance.currentUser?.uid;

    if (uid == null || uid.isEmpty) {
      debugPrint(
        'Safe zone check skipped: elder is not logged in.',
      );
      return;
    }

    try {
      debugPrint(
        'Safe zone check started for elder: $uid',
      );

      await SafeZoneService().checkCurrentLocation(uid);

      debugPrint(
        'Safe zone location check completed.',
      );
    } catch (error, stackTrace) {
      // Do not let location failure break the dashboard.
      // This is particularly important on Chrome where
      // geolocation permission/location can be unavailable.
      debugPrint(
        'Safe zone check failed: $error',
      );

      debugPrintStack(
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}