import 'package:flutter/material.dart';

import '../../models/medicine_model.dart';
import '../../services/caregiver/medicine_service.dart';
import '../../app/theme.dart';

class ElderMedicationScreen extends StatefulWidget {
  final String elderId;

  const ElderMedicationScreen({
    super.key,
    required this.elderId,
  });

  @override
  State<ElderMedicationScreen> createState() =>
      _ElderMedicationScreenState();
}

class _ElderMedicationScreenState
    extends State<ElderMedicationScreen> {
  final MedicineService _medicineService = MedicineService();

  Future<void> _acknowledgeMedicine(
    Medicine medicine,
  ) async {
    try {
      await _medicineService.acknowledgeMedicine(
        widget.elderId,
        medicine.id,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${medicine.name} marked as taken.',
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
    if (widget.elderId.trim().isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Medications'),
        ),
        body: const Center(
          child: Text(
            'Unable to identify your account.',
            style: TextStyle(
              fontSize: 18,
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
          stream: _medicineService.getMedicines(
            widget.elderId,
          ),
          builder: (context, snapshot) {
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
                child: Padding(
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
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
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
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: ElderColors.accent,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.medication_rounded,
                        size: 34,
                        color: ElderColors.secondary,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Here are your medications. Tap "Taken" after taking a medicine.',
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
                    onAcknowledge: () {
                      _acknowledgeMedicine(medicine);
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
  final VoidCallback onAcknowledge;

  const _MedicineCard({
    required this.medicine,
    required this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    final bool taken = medicine.acknowledged;

    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: taken
              ? ElderColors.success
              : ElderColors.border,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: taken
                        ? ElderColors.success.withValues(
                            alpha: 0.12,
                          )
                        : ElderColors.secondary.withValues(
                            alpha: 0.12,
                          ),
                    borderRadius:
                        BorderRadius.circular(14),
                  ),
                  child: Icon(
                    taken
                        ? Icons.check_circle_rounded
                        : Icons.medication_rounded,
                    color: taken
                        ? ElderColors.success
                        : ElderColors.secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    medicine.name,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (medicine.dosage.isNotEmpty)
              _InfoRow(
                icon: Icons.straighten,
                label: 'Dosage',
                value: medicine.dosage,
              ),
            if (medicine.time.isNotEmpty)
              _InfoRow(
                icon: Icons.access_time,
                label: 'Time',
                value: medicine.time,
              ),
            if (medicine.frequency.isNotEmpty)
              _InfoRow(
                icon: Icons.repeat,
                label: 'Frequency',
                value: medicine.frequency,
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: taken
                    ? null
                    : onAcknowledge,
                icon: Icon(
                  taken
                      ? Icons.check_circle
                      : Icons.check,
                ),
                label: Text(
                  taken ? 'TAKEN' : 'MARK AS TAKEN',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: ElderColors.secondary,
          ),
          const SizedBox(width: 10),
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: ElderColors.mutedText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}