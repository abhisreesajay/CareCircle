import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';
<<<<<<< HEAD
import '../../services/medicine_service.dart';
=======
import '../../services/caregiver/medicine_service.dart';
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317

class MedicinesScreen extends StatefulWidget {
  final String elderId;

  const MedicinesScreen({
    super.key,
    required this.elderId,
  });

  @override
  State<MedicinesScreen> createState() => _MedicinesScreenState();
}

class _MedicinesScreenState extends State<MedicinesScreen> {
  final MedicineService _medicineService = MedicineService();

<<<<<<< HEAD
  static const Color primaryGreen = Color(0xFF738F52);
  static const Color darkGreen = Color(0xFF536B3A);
  static const Color lightGreen = Color(0xFFE8EFDF);
  static const Color backgroundColor = Color(0xFFF7F9F3);
  static const Color textColor = Color(0xFF26301F);
=======
  static const Color background = Color(0xFFF4EFE5);
  static const Color sage = Color(0xFF7FA68F);
  static const Color darkSage = Color(0xFF46695A);
  static const Color terracotta = Color(0xFFC85C50);
  static const Color cream = Color(0xFFFFFBF4);
  static const Color textDark = Color(0xFF26352F);

  // -----------------------------------------------------------------------
  // ADD / EDIT MEDICINE
  // -----------------------------------------------------------------------
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317

  void _showMedicineDialog({Medicine? medicine}) {
    final nameController =
        TextEditingController(text: medicine?.name ?? '');
    final dosageController =
        TextEditingController(text: medicine?.dosage ?? '');
    final timeController =
        TextEditingController(text: medicine?.time ?? '');
    final frequencyController =
        TextEditingController(text: medicine?.frequency ?? '');

    showDialog(
      context: context,
<<<<<<< HEAD
      builder: (context) {
        return AlertDialog(
          title: Text(
            medicine == null ? 'Add Medicine' : 'Edit Medicine',
            style: const TextStyle(
              color: darkGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Medicine Name',
                    prefixIcon: const Icon(
                      Icons.medication,
                      color: primaryGreen,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: dosageController,
                  decoration: InputDecoration(
                    labelText: 'Dosage',
                    prefixIcon: const Icon(
                      Icons.medical_information,
                      color: primaryGreen,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: timeController,
                  decoration: InputDecoration(
                    labelText: 'Time',
                    prefixIcon: const Icon(
                      Icons.access_time,
                      color: primaryGreen,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: frequencyController,
                  decoration: InputDecoration(
                    labelText: 'Frequency',
                    prefixIcon: const Icon(
                      Icons.repeat,
                      color: primaryGreen,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: primaryGreen,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
=======
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: cream,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE3E9E1),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.medication_rounded,
                        color: darkSage,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        medicine == null
                            ? 'Add medicine'
                            : 'Edit medicine',
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.w800,
                          color: textDark,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                _InputField(
                  controller: nameController,
                  label: 'Medicine name',
                  icon: Icons.medication_rounded,
                ),

                const SizedBox(height: 12),

                _InputField(
                  controller: dosageController,
                  label: 'Dosage',
                  icon: Icons.medical_information_rounded,
                ),

                const SizedBox(height: 12),

                _InputField(
                  controller: timeController,
                  label: 'Time',
                  icon: Icons.access_time_rounded,
                ),

                const SizedBox(height: 12),

                _InputField(
                  controller: frequencyController,
                  label: 'Frequency',
                  icon: Icons.repeat_rounded,
                ),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: darkSage,
                          side: const BorderSide(
                            color: sage,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text('Cancel'),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty) {
                            return;
                          }

                          final newMedicine = Medicine(
                            id: medicine?.id ??
                                DateTime.now()
                                    .millisecondsSinceEpoch
                                    .toString(),
                            name: nameController.text.trim(),
                            dosage: dosageController.text.trim(),
                            time: timeController.text.trim(),
                            frequency: frequencyController.text.trim(),
                            acknowledged:
                                medicine?.acknowledged ?? false,
                          );

                          if (medicine == null) {
                            await _medicineService.addMedicine(
                              widget.elderId,
                              newMedicine,
                            );
                          } else {
                            await _medicineService.updateMedicine(
                              widget.elderId,
                              newMedicine,
                            );
                          }

                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: darkSage,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          medicine == null ? 'Add medicine' : 'Save changes',
                        ),
                      ),
                    ),
                  ],
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
                ),
              ],
            ),
          ),
<<<<<<< HEAD
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: darkGreen,
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  return;
                }

                final newMedicine = Medicine(
                  id: medicine?.id ??
                      DateTime.now()
                          .millisecondsSinceEpoch
                          .toString(),
                  name: nameController.text.trim(),
                  dosage: dosageController.text.trim(),
                  time: timeController.text.trim(),
                  frequency: frequencyController.text.trim(),
                  acknowledged: medicine?.acknowledged ?? false,
                );

                if (medicine == null) {
                  await _medicineService.addMedicine(
                    widget.elderId,
                    newMedicine,
                  );
                } else {
                  await _medicineService.updateMedicine(
                    widget.elderId,
                    newMedicine,
                  );
                }

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: Text(
                medicine == null ? 'Add' : 'Update',
              ),
            ),
          ],
=======
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
        );
      },
    );
  }

<<<<<<< HEAD
=======
  // -----------------------------------------------------------------------
  // DELETE
  // -----------------------------------------------------------------------

>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
  void _deleteMedicine(String medicineId) async {
    await _medicineService.deleteMedicine(
      widget.elderId,
      medicineId,
    );
  }

<<<<<<< HEAD
=======
  // -----------------------------------------------------------------------
  // ACKNOWLEDGE
  // -----------------------------------------------------------------------

>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
  void _acknowledgeMedicine(String medicineId) async {
    await _medicineService.acknowledgeMedicine(
      widget.elderId,
      medicineId,
    );
  }

<<<<<<< HEAD
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Medicines',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<List<Medicine>>(
        stream: _medicineService.getMedicines(widget.elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryGreen,
=======
  // -----------------------------------------------------------------------
  // BUILD
  // -----------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: background,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Medicines',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: textDark,
          ),
        ),
      ),

      body: StreamBuilder<List<Medicine>>(
        stream: _medicineService.getMedicines(widget.elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: darkSage,
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
              ),
            );
          }

          if (snapshot.hasError) {
<<<<<<< HEAD
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 50,
                      color: darkGreen,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
=======
            return _ErrorState(
              error: snapshot.error.toString(),
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
            );
          }

          final medicines = snapshot.data ?? [];

<<<<<<< HEAD
          if (medicines.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medication_outlined,
                    size: 70,
                    color: primaryGreen,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No medicines added yet.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tap + to add a medicine.',
                    style: TextStyle(
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];

              return Card(
                color: medicine.acknowledged
                    ? lightGreen
                    : Colors.white,
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    medicine.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: textColor,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${medicine.dosage}\n'
                      '${medicine.time} • ${medicine.frequency}',
                      style: const TextStyle(
                        height: 1.5,
                      ),
                    ),
                  ),
                  isThreeLine: true,
                  leading: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: lightGreen,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      medicine.acknowledged
                          ? Icons.check_circle
                          : Icons.medication,
                      color: darkGreen,
                      size: 28,
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.more_vert,
                      color: darkGreen,
                    ),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showMedicineDialog(
                          medicine: medicine,
                        );
                      } else if (value == 'delete') {
                        _deleteMedicine(medicine.id);
                      } else if (value == 'acknowledge') {
                        _acknowledgeMedicine(medicine.id);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(
                              Icons.edit,
                              color: darkGreen,
                            ),
                            SizedBox(width: 10),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_outline,
                              color: darkGreen,
                            ),
                            SizedBox(width: 10),
                            Text('Delete'),
                          ],
                        ),
                      ),
                      if (!medicine.acknowledged)
                        const PopupMenuItem(
                          value: 'acknowledge',
                          child: Row(
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                color: darkGreen,
                              ),
                              SizedBox(width: 10),
                              Text('Mark as Acknowledged'),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryGreen,
=======
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -----------------------------------------------------------
              // INTRO
              // -----------------------------------------------------------

              Padding(
                padding: const EdgeInsets.fromLTRB(22, 4, 22, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Medication',
                            style: TextStyle(
                              fontSize: 29,
                              fontWeight: FontWeight.w800,
                              color: textDark,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            medicines.isEmpty
                                ? 'No medicines scheduled yet'
                                : '${medicines.length} medicine${medicines.length == 1 ? '' : 's'} scheduled',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5D3C8),
                        borderRadius: BorderRadius.circular(17),
                      ),
                      child: const Icon(
                        Icons.medication_rounded,
                        color: terracotta,
                        size: 27,
                      ),
                    ),
                  ],
                ),
              ),

              // -----------------------------------------------------------
              // EMPTY STATE
              // -----------------------------------------------------------

              if (medicines.isEmpty)
                const Expanded(
                  child: Center(
                    child: _EmptyMedicineState(),
                  ),
                )
              else
                // ---------------------------------------------------------
                // MEDICINE LIST
                // ---------------------------------------------------------
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(22, 0, 22, 110),
                    itemCount: medicines.length,
                    itemBuilder: (context, index) {
                      final medicine = medicines[index];

                      return _MedicineCard(
                        medicine: medicine,
                        onEdit: () {
                          _showMedicineDialog(
                            medicine: medicine,
                          );
                        },
                        onDelete: () {
                          _deleteMedicine(medicine.id);
                        },
                        onAcknowledge: () {
                          _acknowledgeMedicine(medicine.id);
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),

      // ---------------------------------------------------------------
      // ADD BUTTON
      // ---------------------------------------------------------------

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: darkSage,
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          _showMedicineDialog();
        },
<<<<<<< HEAD
        child: const Icon(Icons.add),
=======
        icon: const Icon(
          Icons.add_rounded,
        ),
        label: const Text(
          'Add medicine',
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}


// =======================================================================
// MEDICINE CARD
// =======================================================================

class _MedicineCard extends StatelessWidget {
  final Medicine medicine;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onAcknowledge;

  const _MedicineCard({
    required this.medicine,
    required this.onEdit,
    required this.onDelete,
    required this.onAcknowledge,
  });

  @override
  Widget build(BuildContext context) {
    final bool taken = medicine.acknowledged;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: taken
            ? const Color(0xFFE5EDE2)
            : const Color(0xFFFFFBF4),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: taken
              ? const Color(0xFFD0DDCB)
              : Colors.transparent,
        ),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medicine icon
              Container(
                height: 58,
                width: 58,
                decoration: BoxDecoration(
                  color: taken
                      ? const Color(0xFFD3E1D0)
                      : const Color(0xFFE5D3C8),
                  borderRadius: BorderRadius.circular(19),
                ),
                child: Icon(
                  taken
                      ? Icons.check_circle_rounded
                      : Icons.medication_rounded,
                  color: taken
                      ? const Color(0xFF46695A)
                      : const Color(0xFFC85C50),
                  size: 29,
                ),
              ),

              const SizedBox(width: 14),

              // Name + dosage
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medicine.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF26352F),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      medicine.dosage.isEmpty
                          ? 'Dosage not specified'
                          : medicine.dosage,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF46695A),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  } else if (value == 'delete') {
                    onDelete();
                  } else if (value == 'acknowledge') {
                    onAcknowledge();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_rounded,
                          color: Color(0xFF46695A),
                        ),
                        SizedBox(width: 10),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFC85C50),
                        ),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                  if (!medicine.acknowledged)
                    const PopupMenuItem(
                      value: 'acknowledge',
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline_rounded,
                            color: Color(0xFF46695A),
                          ),
                          SizedBox(width: 10),
                          Text('Mark as taken'),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 18),

          // -------------------------------------------------------------
          // TIME / FREQUENCY
          // -------------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: _MedicineDetail(
                  icon: Icons.access_time_rounded,
                  label: 'Time',
                  value: medicine.time.isEmpty
                      ? 'Not set'
                      : medicine.time,
                ),
              ),

              const SizedBox(width: 10),

              Expanded(
                child: _MedicineDetail(
                  icon: Icons.repeat_rounded,
                  label: 'Frequency',
                  value: medicine.frequency.isEmpty
                      ? 'Not set'
                      : medicine.frequency,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // -------------------------------------------------------------
          // STATUS
          // -------------------------------------------------------------

          GestureDetector(
            onTap: taken ? null : onAcknowledge,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: taken
                    ? const Color(0xFFD3E1D0)
                    : const Color(0xFFF0D5CE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    taken
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: taken
                        ? const Color(0xFF46695A)
                        : const Color(0xFFC85C50),
                    size: 21,
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      taken
                          ? 'Medicine taken'
                          : 'Tap to mark as taken',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: taken
                            ? const Color(0xFF46695A)
                            : const Color(0xFF9C5047),
                      ),
                    ),
                  ),
                  if (!taken)
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Color(0xFF9C5047),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// =======================================================================
// MEDICINE DETAIL
// =======================================================================

class _MedicineDetail extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MedicineDetail({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFF1ECE2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: const Color(0xFF46695A),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black45,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF26352F),
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


// =======================================================================
// INPUT FIELD
// =======================================================================

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;

  const _InputField({
    required this.controller,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF46695A),
          size: 21,
        ),
        filled: true,
        fillColor: const Color(0xFFF1ECE2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFF7FA68F),
            width: 2,
          ),
        ),
      ),
    );
  }
}


// =======================================================================
// EMPTY STATE
// =======================================================================

class _EmptyMedicineState extends StatelessWidget {
  const _EmptyMedicineState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 92,
            width: 92,
            decoration: BoxDecoration(
              color: const Color(0xFFE5D3C8),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(
              Icons.medication_rounded,
              size: 45,
              color: Color(0xFFC85C50),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            'No medicines yet',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.w800,
              color: Color(0xFF26352F),
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Add the medicines your elder needs to take.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}


// =======================================================================
// ERROR STATE
// =======================================================================

class _ErrorState extends StatelessWidget {
  final String error;

  const _ErrorState({
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFF0D5CE),
                borderRadius: BorderRadius.circular(26),
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFC85C50),
                size: 40,
              ),
            ),

            const SizedBox(height: 18),

            const Text(
              'Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF26352F),
              ),
            ),

            const SizedBox(height: 8),

            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
>>>>>>> a3aebc2c1aa208a23c4a02ef94e26ea39211c317
      ),
    );
  }
}