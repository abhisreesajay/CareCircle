import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/medical_summary_model.dart';
import '../../services/caregiver/medical_summary_service.dart';

class MedicalInformationScreen extends StatelessWidget {
  const MedicalInformationScreen({
    super.key,
  });

  static const Color primary = Color(0xFF000000);
  static const Color secondary = Color(0xFFFF6B00);
  static const Color accent = Color(0xFFFFB81C);
  static const Color background = Colors.white;
  static const Color muted = Color(0xFF666666);

  @override
  Widget build(BuildContext context) {
    final User? user =
        FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text(
            'Please log in first.',
          ),
        ),
      );
    }

    final MedicalSummaryService service =
        MedicalSummaryService();

    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text(
          'Medical Information',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: StreamBuilder<MedicalSummary?>(
        stream: service.getMedicalSummaryStream(
          user.uid,
        ),

        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: secondary,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load medical information.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    color: muted,
                  ),
                ),
              ),
            );
          }

          final MedicalSummary? summary =
              snapshot.data;

          if (summary == null) {
            return const _EmptyMedicalState();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: primary,
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.medical_information_rounded,
                        color: Colors.white,
                        size: 32,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Your Medical Information',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                const _SectionLabel(
                  text: 'Blood Group',
                ),
                _MedicalCard(
                  value: summary.bloodGroup,
                  icon: Icons.bloodtype_rounded,
                  iconColor: secondary,
                ),

                const SizedBox(height: 14),

                const _SectionLabel(
                  text: 'Allergies',
                ),
                _MedicalCard(
                  value: summary.allergies,
                  icon: Icons.warning_amber_rounded,
                  iconColor: secondary,
                ),

                const SizedBox(height: 14),

                const _SectionLabel(
                  text: 'Medical Conditions',
                ),
                _MedicalCard(
                  value: summary.conditions,
                  icon: Icons.health_and_safety_rounded,
                  iconColor: primary,
                ),

                const SizedBox(height: 14),

                const _SectionLabel(
                  text: 'Medical Notes',
                ),
                _MedicalCard(
                  value: summary.notes,
                  icon: Icons.notes_rounded,
                  iconColor: accent,
                ),

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF5EA),
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: secondary,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Medical information can only be updated by your caregiver.',
                          style: TextStyle(
                            color: primary,
                            fontSize: 14,
                            fontWeight:
                                FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ============================================================
// SECTION LABEL
// ============================================================

class _SectionLabel extends StatelessWidget {
  final String text;

  const _SectionLabel({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 17,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

// ============================================================
// MEDICAL CARD
// ============================================================

class _MedicalCard extends StatelessWidget {
  final String value;
  final IconData icon;
  final Color iconColor;

  const _MedicalCard({
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasValue =
        value.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Text(
              hasValue
                  ? value
                  : 'Not provided',
              style: TextStyle(
                color: hasValue
                    ? Colors.black
                    : Colors.black54,
                fontSize: 16,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyMedicalState extends StatelessWidget {
  const _EmptyMedicalState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_information_outlined,
              size: 70,
              color: Color(0xFFFF6B00),
            ),
            SizedBox(height: 20),
            Text(
              'No medical information yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your caregiver has not added your medical information yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}