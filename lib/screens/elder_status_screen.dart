import 'package:flutter/material.dart';
import '../services/elder_status_service.dart';

class ElderStatusScreen extends StatelessWidget {
  final String elderId;

  const ElderStatusScreen({
    super.key,
    required this.elderId,
  });

  @override
  Widget build(BuildContext context) {
    final service = ElderStatusService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Elder Status'),
      ),
      body: StreamBuilder(
        stream: service.getStatus(elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load elder status',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final document = snapshot.data;

          if (document == null || !document.exists) {
            return const Center(
              child: Text(
                'Elder status not available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final data = document.data() ?? {};

          final checkInStatus =
              data['checkInStatus'] ?? 'Not available';

          final safeZoneStatus =
              data['safeZoneStatus'] ?? 'Not available';

          final medicineStatus =
              data['medicineStatus'] ?? 'Not available';

          final lastActivity =
              data['lastActivity'] ?? 'Not available';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _statusCard(
                  icon: Icons.check_circle,
                  title: 'Check-in',
                  value: checkInStatus.toString(),
                ),
                const SizedBox(height: 12),
                _statusCard(
                  icon: Icons.home,
                  title: 'Safe Zone',
                  value: safeZoneStatus.toString(),
                ),
                const SizedBox(height: 12),
                _statusCard(
                  icon: Icons.medication,
                  title: 'Medicine',
                  value: medicineStatus.toString(),
                ),
                const SizedBox(height: 12),
                _statusCard(
                  icon: Icons.access_time,
                  title: 'Last Activity',
                  value: lastActivity.toString(),
                ),
              ],
            ),
          );
        },
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