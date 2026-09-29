import 'package:flutter/material.dart';

import '../../models/medical_summary_model.dart';
import '../../services/caregiver/medical_summary_service.dart';
import 'medical_summary_edit_screen.dart';

class MedicalSummaryScreen extends StatelessWidget {
  final String elderId;

  const MedicalSummaryScreen({
    super.key,
    required this.elderId,
  });

  // ------------------------------------------------------------
  // CARE CIRCLE PALETTE
  // ------------------------------------------------------------

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

      // ----------------------------------------------------------
      // APP BAR
      // ----------------------------------------------------------

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Medical Summary',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: textDark,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit medical information',
            icon: const Icon(
              Icons.edit_rounded,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MedicalSummaryEditScreen(
                    elderId: elderId,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ----------------------------------------------------------
      // REAL-TIME FIRESTORE STREAM
      // ----------------------------------------------------------

      body: StreamBuilder<MedicalSummary?>(
        stream: service.getMedicalSummaryStream(
          elderId,
        ),

        builder: (context, snapshot) {
          // --------------------------------------------------------
          // LOADING
          // --------------------------------------------------------

          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: darkSage,
              ),
            );
          }

          // --------------------------------------------------------
          // ERROR
          // --------------------------------------------------------

          if (snapshot.hasError) {
            return const _ErrorState();
          }

          // --------------------------------------------------------
          // NO DATA
          // --------------------------------------------------------

          final summary = snapshot.data;

          if (summary == null) {
            return const _EmptyState();
          }

          // --------------------------------------------------------
          // MEDICAL INFORMATION
          // --------------------------------------------------------

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              100,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                // ==================================================
                // HEADER CARD
                // ==================================================

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: darkSage,
                    borderRadius:
                        BorderRadius.circular(28),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: cream.withValues(
                            alpha: 0.15,
                          ),
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
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              'Important medical information for your care circle.',
                              style: TextStyle(
                                color:
                                    cream.withValues(
                                  alpha: 0.78,
                                ),
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

                // ==================================================
                // SECTION TITLE
                // ==================================================

                const Text(
                  'Medical information',
                  style: TextStyle(
                    color: textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                // ==================================================
                // BLOOD GROUP
                // ==================================================

                _InfoCard(
                  title: 'Blood Group',
                  value: summary.bloodGroup,
                  icon: Icons.bloodtype_rounded,
                  iconColor: terracotta,
                ),

                // ==================================================
                // ALLERGIES
                // ==================================================

                _InfoCard(
                  title: 'Allergies',
                  value: summary.allergies,
                  icon: Icons.warning_amber_rounded,
                  iconColor: terracotta,
                ),

                // ==================================================
                // MEDICAL CONDITIONS
                // ==================================================

                _InfoCard(
                  title: 'Medical Conditions',
                  value: summary.conditions,
                  icon: Icons.health_and_safety_rounded,
                  iconColor: darkSage,
                ),

                // ==================================================
                // NOTES
                // ==================================================

                _InfoCard(
                  title: 'Notes',
                  value: summary.notes,
                  icon: Icons.notes_rounded,
                  iconColor: sage,
                ),

                const SizedBox(height: 10),

                // ==================================================
                // LIVE INDICATOR
                // ==================================================

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 7),
                    const Text(
                      'Medical information updates automatically',
                      style: TextStyle(
                        color: mutedText,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===================================================================
// INFO CARD
// ===================================================================

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
    final bool hasValue =
        value.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cream,
        borderRadius:
            BorderRadius.circular(24),
        border: Border.all(
          color: Colors.black.withValues(
            alpha: 0.04,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------------
          // ICON
          // --------------------------------------------------------

          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: iconColor.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 26,
            ),
          ),

          const SizedBox(width: 15),

          // --------------------------------------------------------
          // INFORMATION
          // --------------------------------------------------------

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: iconColor,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  hasValue
                      ? value
                      : 'Not provided',
                  style: TextStyle(
                    color: hasValue
                        ? textDark
                        : mutedText,
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

// ===================================================================
// EMPTY STATE
// ===================================================================

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  static const Color sage =
      Color(0xFF7FA68F);

  static const Color textDark =
      Color(0xFF26352F);

  static const Color mutedText =
      Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                color: sage.withValues(
                  alpha: 0.14,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.medical_information_outlined,
                size: 46,
                color: sage,
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              'No medical summary yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textDark,
                fontSize: 20,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Medical information will appear here once it is added.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ===================================================================
// ERROR STATE
// ===================================================================

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  static const Color terracotta =
      Color(0xFFC85C50);

  static const Color textDark =
      Color(0xFF26352F);

  static const Color mutedText =
      Color(0xFF7A827D);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: terracotta.withValues(
                  alpha: 0.10,
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: terracotta,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Unable to load medical summary',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textDark,
                fontSize: 18,
                fontWeight:
                    FontWeight.w700,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: mutedText,
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}