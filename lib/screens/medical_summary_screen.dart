import 'package:flutter/material.dart';
import '../models/medical_summary_model.dart';
import '../services/medical_summary_service.dart';

class MedicalSummaryScreen extends StatelessWidget {
  final String elderId;

  const MedicalSummaryScreen({
    super.key,
    required this.elderId,
  });

  @override
  Widget build(BuildContext context) {
    final service = MedicalSummaryService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Summary'),
      ),
      body: FutureBuilder<MedicalSummary?>(
        future: service.getMedicalSummary(elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Unable to load medical summary',
                style: const TextStyle(fontSize: 16),
              ),
            );
          }

          final summary = snapshot.data;

          if (summary == null) {
            return const Center(
              child: Text(
                'No medical summary available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return Padding(
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
          );
        },
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