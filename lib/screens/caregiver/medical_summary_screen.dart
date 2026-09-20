import 'package:flutter/material.dart';
import '../../models/medical_summary_model.dart';
import '../../services/caregiver/medical_summary_service.dart';

class MedicalSummaryScreen extends StatelessWidget {
  final String elderId;

  const MedicalSummaryScreen({
    super.key,
    required this.elderId,
  });

  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color background = Color(0xFFF4EFE5);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    final service = MedicalSummaryService();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        title: const Text(
          'Medical Summary',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: FutureBuilder<MedicalSummary?>(
        future: service.getMedicalSummary(elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: darkSage,
              ),
            );
          }

          if (snapshot.hasError) {
            return const _ErrorState();
          }

          final summary = snapshot.data;

          if (summary == null) {
            return const _EmptyState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: darkSage,
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: cream.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.medical_information_rounded,
                          color: cream,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Health at a glance',
                              style: TextStyle(
                                color: cream,
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Important medical information for your care circle.',
                              style: TextStyle(
                                color: cream.withValues(alpha: 0.78),
                                fontSize: 14,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 26),
                const Text(
                  'Medical information',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  title: 'Blood Group',
                  value: summary.bloodGroup,
                  icon: Icons.bloodtype_rounded,
                  iconColor: terracotta,
                ),
                _InfoCard(
                  title: 'Allergies',
                  value: summary.allergies,
                  icon: Icons.warning_amber_rounded,
                  iconColor: terracotta,
                ),
                _InfoCard(
                  title: 'Medical Conditions',
                  value: summary.conditions,
                  icon: Icons.health_and_safety_rounded,
                  iconColor: darkSage,
                ),
                _InfoCard(
                  title: 'Notes',
                  value: summary.notes,
                  icon: Icons.notes_rounded,
                  iconColor: sage,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  static const Color cream = Color(0xFFFFFBF4);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  value.isEmpty ? 'Not provided' : value,
                  style: TextStyle(
                    color: value.isEmpty ? mutedText : textDark,
                    fontSize: 15,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  static const Color sage = Color(0xFF7FA68F);
  static const Color textDark = Color(0xFF26352F);
  static const Color mutedText = Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: 65,
              color: sage,
            ),
            const SizedBox(height: 18),
            const Text(
              'No medical summary yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textDark,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Medical information will appear here once it is added.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedText,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  static const Color terracotta = Color(0xFFC85C50);
  static const Color textDark = Color(0xFF26352F);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 55,
              color: terracotta,
            ),
            SizedBox(height: 16),
            Text(
              'Unable to load medical summary',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}