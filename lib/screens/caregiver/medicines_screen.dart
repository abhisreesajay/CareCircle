import 'package:flutter/material.dart';
import '../../models/medicine_model.dart';
import '../../services/medicine_service.dart';

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

  static const Color primaryGreen = Color(0xFF738F52);
  static const Color darkGreen = Color(0xFF536B3A);
  static const Color lightGreen = Color(0xFFE8EFDF);
  static const Color backgroundColor = Color(0xFFF7F9F3);
  static const Color textColor = Color(0xFF26301F);

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
                ),
              ],
            ),
          ),
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
        );
      },
    );
  }

  void _deleteMedicine(String medicineId) async {
    await _medicineService.deleteMedicine(
      widget.elderId,
      medicineId,
    );
  }

  void _acknowledgeMedicine(String medicineId) async {
    await _medicineService.acknowledgeMedicine(
      widget.elderId,
      medicineId,
    );
  }

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
              ),
            );
          }

          if (snapshot.hasError) {
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
            );
          }

          final medicines = snapshot.data ?? [];

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
        foregroundColor: Colors.white,
        elevation: 4,
        onPressed: () {
          _showMedicineDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}