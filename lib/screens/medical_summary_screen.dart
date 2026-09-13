import 'package:flutter/material.dart';
import '../models/medical_summary_model.dart';

class MedicalSummaryScreen extends StatelessWidget {
  const MedicalSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final summary = MedicalSummary(
      bloodGroup: 'O+',
      allergies: 'None',
      conditions: 'Diabetes',
      notes: 'Regular medication required',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _infoCard(
              'Blood Group',
              summary.bloodGroup,
              Icons.bloodtype,
            ),
            _infoCard(
              'Allergies',
              summary.allergies,
              Icons.warning,
            ),
            _infoCard(
              'Medical Conditions',
              summary.conditions,
              Icons.medical_information,
            ),
            _infoCard(
              'Notes',
              summary.notes,
              Icons.notes,
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          size: 30,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(value),
        ),
      ),
    );
  }
}