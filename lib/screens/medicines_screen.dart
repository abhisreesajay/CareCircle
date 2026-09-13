import 'package:flutter/material.dart';
import '../models/medicine_model.dart';
import '../services/medicine_service.dart';

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
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Medicine Name',
                  ),
                ),
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosage',
                  ),
                ),
                TextField(
                  controller: timeController,
                  decoration: const InputDecoration(
                    labelText: 'Time',
                  ),
                ),
                TextField(
                  controller: frequencyController,
                  decoration: const InputDecoration(
                    labelText: 'Frequency',
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
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  return;
                }

                final newMedicine = Medicine(
                  id: medicine?.id ??
                      DateTime.now().millisecondsSinceEpoch.toString(),
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
      appBar: AppBar(
        title: const Text('Medicines'),
      ),
      body: StreamBuilder<List<Medicine>>(
        stream: _medicineService.getMedicines(widget.elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
              ),
            );
          }

          final medicines = snapshot.data ?? [];

          if (medicines.isEmpty) {
            return const Center(
              child: Text(
                'No medicines added yet.',
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medicines.length,
            itemBuilder: (context, index) {
              final medicine = medicines[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    medicine.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    '${medicine.dosage}\n'
                    '${medicine.time} • ${medicine.frequency}',
                  ),
                  isThreeLine: true,
                  leading: Icon(
                    medicine.acknowledged
                        ? Icons.check_circle
                        : Icons.medication,
                  ),
                  trailing: PopupMenuButton<String>(
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
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                      if (!medicine.acknowledged)
                        const PopupMenuItem(
                          value: 'acknowledge',
                          child: Text('Mark as Acknowledged'),
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
        onPressed: () {
          _showMedicineDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}