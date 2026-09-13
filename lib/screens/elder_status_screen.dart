import 'package:flutter/material.dart';

class ElderStatusScreen extends StatelessWidget {
  const ElderStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Elder Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _statusCard(
              icon: Icons.check_circle,
              title: 'Check-in',
              value: 'Completed',
            ),
            const SizedBox(height: 12),
            _statusCard(
              icon: Icons.home,
              title: 'Safe Zone',
              value: 'At Home',
            ),
            const SizedBox(height: 12),
            _statusCard(
              icon: Icons.medication,
              title: 'Medicine',
              value: 'Acknowledged',
            ),
            const SizedBox(height: 12),
            _statusCard(
              icon: Icons.access_time,
              title: 'Last Activity',
              value: 'Today, 10:30 AM',
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(
          icon,
          size: 32,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(value),
      ),
    );
  }
}