import 'package:flutter/material.dart';
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
import '../../services/elder_status_service.dart';
=======
import '../../services/caregiver/elder_status_service.dart';
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
import '../../services/caregiver/elder_status_service.dart';
>>>>>>> develop
=======
import '../../services/caregiver/elder_status_service.dart';
>>>>>>> origin/main

class ElderStatusScreen extends StatelessWidget {
  final String elderId;

  const ElderStatusScreen({
    super.key,
    required this.elderId,
  });

<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
  static const Color primaryGreen = Color(0xFF738F52);
  static const Color darkGreen = Color(0xFF536B3A);
  static const Color lightGreen = Color(0xFFE8EFDF);
  static const Color backgroundColor = Color(0xFFF7F9F3);
  static const Color textColor = Color(0xFF26301F);
<<<<<<< HEAD
=======
=======
>>>>>>> origin/main
  static const Color backgroundColor = Color(0xFFF4EFE5);
  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main

  @override
  Widget build(BuildContext context) {
    final service = ElderStatusService();

    return Scaffold(
      backgroundColor: backgroundColor,
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
      appBar: AppBar(
        title: const Text(
          'Elder Status',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
<<<<<<< HEAD
=======

=======
>>>>>>> origin/main
      appBar: AppBar(
        backgroundColor: backgroundColor,
        foregroundColor: textDark,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        titleSpacing: 20,
        title: const Text(
          'Elder status',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
      ),
<<<<<<< HEAD

>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
      body: StreamBuilder(
        stream: service.getStatus(elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
                color: primaryGreen,
=======
                color: darkSage,
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
                color: primaryGreen,
>>>>>>> develop
=======
                color: darkSage,
>>>>>>> origin/main
              ),
            );
          }

          if (snapshot.hasError) {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 55,
                      color: darkGreen,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Unable to load elder status',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
<<<<<<< HEAD
=======
            return const _ErrorState();
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
            return const _ErrorState();
>>>>>>> origin/main
          }

          final document = snapshot.data;

          if (document == null || !document.exists) {
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 65,
                      color: primaryGreen,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Elder status not available',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ),
            );
<<<<<<< HEAD
=======
            return const _UnavailableState();
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
            return const _UnavailableState();
>>>>>>> origin/main
          }

          final data = document.data() ?? {};

          final checkInStatus =
              data['checkInStatus'] ?? 'Not available';

          final safeZoneStatus =
              data['safeZoneStatus'] ?? 'Not available';

          final medicineStatus =
              data['medicineStatus'] ?? 'Not available';

          final lastActivity =
              data['lastActivity'] ?? 'Not available';

          return SingleChildScrollView(
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _statusCard(
                  icon: Icons.check_circle_outline,
                  title: 'Check-in',
                  value: checkInStatus.toString(),
                ),
                const SizedBox(height: 14),
                _statusCard(
                  icon: Icons.home_outlined,
                  title: 'Safe Zone',
                  value: safeZoneStatus.toString(),
                ),
                const SizedBox(height: 14),
                _statusCard(
                  icon: Icons.medication_outlined,
                  title: 'Medicine',
                  value: medicineStatus.toString(),
                ),
                const SizedBox(height: 14),
                _statusCard(
                  icon: Icons.access_time,
                  title: 'Last Activity',
                  value: lastActivity.toString(),
<<<<<<< HEAD
=======
=======
>>>>>>> origin/main
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OverviewCard(
                  checkInStatus: checkInStatus.toString(),
                  safeZoneStatus: safeZoneStatus.toString(),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Today at a glance',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'A quick view of your elder\'s current status.',
                  style: TextStyle(
                    fontSize: 14,
                    color: mutedText,
                  ),
                ),

                const SizedBox(height: 16),

                _StatusCard(
                  icon: Icons.check_circle_outline,
                  title: 'Check-in',
                  value: checkInStatus.toString(),
                  accentColor: darkSage,
                ),

                const SizedBox(height: 14),

                _StatusCard(
                  icon: Icons.home_outlined,
                  title: 'Safe zone',
                  value: safeZoneStatus.toString(),
                  accentColor: sage,
                ),

                const SizedBox(height: 14),

                _StatusCard(
                  icon: Icons.medication_outlined,
                  title: 'Medicine',
                  value: medicineStatus.toString(),
                  accentColor: terracotta,
                ),

                const SizedBox(height: 14),

                _StatusCard(
                  icon: Icons.access_time_outlined,
                  title: 'Last activity',
                  value: lastActivity.toString(),
                  accentColor: darkSage,
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
                ),
              ],
            ),
          );
        },
      ),
    );
  }
<<<<<<< HEAD
<<<<<<< HEAD
<<<<<<< HEAD
=======
>>>>>>> develop

  Widget _statusCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black12,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(
                icon,
                size: 30,
                color: darkGreen,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
<<<<<<< HEAD
=======
=======
>>>>>>> origin/main
}

class _OverviewCard extends StatelessWidget {
  final String checkInStatus;
  final String safeZoneStatus;

  const _OverviewCard({
    required this.checkInStatus,
    required this.safeZoneStatus,
  });

  static const Color darkSage = Color(0xFF46695A);
  static const Color cream = Color(0xFFFFFBF4);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: darkSage,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: cream.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.favorite_outline,
                  color: cream,
                  size: 29,
                ),
              ),
              const SizedBox(width: 15),
              const Expanded(
                child: Text(
                  'How are things?',
                  style: TextStyle(
                    color: cream,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            'Here is the latest information available for your elder.',
            style: TextStyle(
              color: cream.withValues(alpha: 0.72),
              fontSize: 13,
              height: 1.45,
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _OverviewPill(
                  label: 'Check-in',
                  value: checkInStatus,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _OverviewPill(
                  label: 'Safe zone',
                  value: safeZoneStatus,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OverviewPill extends StatelessWidget {
  final String label;
  final String value;

  const _OverviewPill({
    required this.label,
    required this.value,
  });

  static const Color cream = Color(0xFFFFFBF4);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cream.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: cream.withValues(alpha: 0.62),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: cream,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accentColor;

  const _StatusCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.accentColor,
  });

  static const Color backgroundColor = Color(0xFFF4EFE5);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.055),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              icon,
              color: accentColor,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: mutedText,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: textDark,
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: backgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.chevron_right,
              color: accentColor,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _UnavailableState extends StatelessWidget {
  const _UnavailableState();

  static const Color cream = Color(0xFFFFFBF4);
  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: sage.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 36,
                  color: darkSage,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Elder status unavailable',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'There is no current status information available for this elder.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: mutedText,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  static const Color cream = Color(0xFFFFFBF4);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: terracotta.withValues(alpha: 0.13),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_outline,
                  size: 34,
                  color: terracotta,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'Unable to load elder status',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: textDark,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: mutedText,
                ),
              ),
            ],
          ),
<<<<<<< HEAD
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
=======
>>>>>>> develop
=======
>>>>>>> origin/main
        ),
      ),
    );
  }
}