import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../models/medicine_model.dart';
import '../../services/caregiver/medicine_service.dart';

class ElderMedicationScreen extends StatefulWidget {
  final String? elderId;

  const ElderMedicationScreen({
    super.key,
    this.elderId,
  });

  @override
  State<ElderMedicationScreen> createState() =>
      _ElderMedicationScreenState();
}

class _ElderMedicationScreenState
    extends State<ElderMedicationScreen> {
  final MedicineService _medicineService = MedicineService();

  String? get _currentElderId {
    final authUser = FirebaseAuth.instance.currentUser;

    if (authUser == null) {
      return null;
    }

    // For the elder app, the logged-in Firebase user is
    // the source of truth for the elder document.
    return authUser.uid;
  }

  Future<void> _acknowledgeDose(
    Medicine medicine,
    int doseIndex,
  ) async {
    final elderId = _currentElderId;

    if (elderId == null || elderId.isEmpty) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to identify your account.',
          ),
          backgroundColor: ElderColors.critical,
        ),
      );

      return;
    }

    try {
      await _medicineService.acknowledgeMedicineDose(
        elderId,
        medicine.id,
        doseIndex,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${medicine.name} dose ${doseIndex + 1} marked as taken.',
          ),
          backgroundColor: ElderColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Unable to update medicine: $e',
          ),
          backgroundColor: ElderColors.critical,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final elderId = _currentElderId;

    if (elderId == null || elderId.isEmpty) {
      return Theme(
        data: elderTheme(),
        child: Scaffold(
          appBar: AppBar(
            title: const Text(
              'My Medications',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Unable to identify your account.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Theme(
      data: elderTheme(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'My Medications',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: StreamBuilder<List<Medicine>>(
          stream: _medicineService.getMedicines(elderId),
          builder: (
            context,
            snapshot,
          ) {
            if (snapshot.connectionState ==
                ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: ElderColors.secondary,
                ),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: ElderColors.critical,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Unable to load medications.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ElderColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            final medicines = snapshot.data ?? [];

            if (medicines.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.medication_outlined,
                        size: 80,
                        color: ElderColors.secondary,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'No medications added yet.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Your caregiver can add your medications for you.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: ElderColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ElderColors.accent.withValues(
                      alpha: 0.18,
                    ),
                    borderRadius:
                        BorderRadius.circular(16),
                    border: Border.all(
                      color: ElderColors.accent,
                    ),
                  ),
                  child: const Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.medication_rounded,
                        size: 34,
                        color: ElderColors.secondary,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Here are your medications. Tap "TAKE" after taking each dose.',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                ...medicines.map(
                  (medicine) => _MedicineCard(
                    medicine: medicine,
                    onAcknowledge: (doseIndex) {
                      _acknowledgeDose(
                        medicine,
                        doseIndex,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;

  final void Function(int doseIndex) onAcknowledge;

  const _MedicineCard({
    required this.medicine,
    required this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    final takenCount =
        medicine.takenDosesTodayCount;

    final allTaken =
        medicine.allDosesTakenToday;

    return Card(
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: allTaken
              ? ElderColors.success
              : ElderColors.border,
          width: allTaken ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: allTaken
                        ? ElderColors.success
                            .withValues(alpha: 0.12)
                        : ElderColors.secondary
                            .withValues(alpha: 0.12),
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: Icon(
                    allTaken
                        ? Icons.check_circle_rounded
                        : Icons.medication_rounded,
                    color: allTaken
                        ? ElderColors.success
                        : ElderColors.secondary,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        medicine.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (medicine.dosage.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          medicine.dosage,
                          style: const TextStyle(
                            fontSize: 14,
                            color: ElderColors.mutedText,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: ElderColors.accent.withValues(
                  alpha: 0.12,
                ),
                borderRadius:
                    BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.repeat_rounded,
                    color: ElderColors.secondary,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${medicine.frequency} time${medicine.frequency == 1 ? '' : 's'} per day',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    '$takenCount/${medicine.frequency}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            ...List.generate(
              medicine.frequency,
              (doseIndex) {
                final isTaken =
                    medicine.isDoseTakenToday(
                  doseIndex,
                );

                final time =
                    medicine.getTimeForDose(
                  doseIndex,
                );

                return Padding(
                  padding: const EdgeInsets.only(
                    bottom: 10,
                  ),
                  child: _DoseRow(
                    doseNumber: doseIndex + 1,
                    time: time,
                    isTaken: isTaken,
                    onTap: isTaken
                        ? null
                        : () {
                            onAcknowledge(
                              doseIndex,
                            );
                          },
                  ),
                );
              },
            ),

            if (allTaken)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(
                  top: 4,
                ),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: ElderColors.success
                      .withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: ElderColors.success,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'All doses taken today.',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ElderColors.success,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DoseRow extends StatelessWidget {
  final int doseNumber;
  final String time;
  final bool isTaken;
  final VoidCallback? onTap;

  const _DoseRow({
    required this.doseNumber,
    required this.time,
    required this.isTaken,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isTaken
            ? ElderColors.success.withValues(
                alpha: 0.10,
              )
            : ElderColors.secondary.withValues(
                alpha: 0.08,
              ),
        borderRadius:
            BorderRadius.circular(16),
        border: Border.all(
          color: isTaken
              ? ElderColors.success
              : ElderColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isTaken
                  ? ElderColors.success.withValues(
                      alpha: 0.15,
                    )
                  : ElderColors.secondary.withValues(
                      alpha: 0.12,
                    ),
              borderRadius:
                  BorderRadius.circular(13),
            ),
            child: Icon(
              isTaken
                  ? Icons.check_circle_rounded
                  : Icons.access_time_rounded,
              color: isTaken
                  ? ElderColors.success
                  : ElderColors.secondary,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'Dose $doseNumber',
                  style: const TextStyle(
                    fontSize: 13,
                    color: ElderColors.mutedText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // IMPORTANT:
          // Give the button an explicit finite width.
          SizedBox(
            width: 82,
            height: 44,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: isTaken
                    ? ElderColors.success
                    : ElderColors.secondary,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    ElderColors.success.withValues(
                  alpha: 0.75,
                ),
                disabledForegroundColor:
                    Colors.white,
                minimumSize: const Size(
                  82,
                  44,
                ),
                maximumSize: const Size(
                  82,
                  44,
                ),
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 8,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
              child: Text(
                isTaken ? 'TAKEN' : 'TAKE',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}