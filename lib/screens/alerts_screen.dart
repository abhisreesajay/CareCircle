import 'package:flutter/material.dart';
import '../models/alert_model.dart';
import '../services/alert_service.dart';

class AlertsScreen extends StatelessWidget {
  final String elderId;

  const AlertsScreen({
    super.key,
    required this.elderId,
  });

  @override
  Widget build(BuildContext context) {
    final service = AlertService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: StreamBuilder<List<CareAlert>>(
        stream: service.getAlerts(elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load alerts',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final alerts = snapshot.data ?? [];

          if (alerts.isEmpty) {
            return const Center(
              child: Text(
                'No alerts available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (context, index) {
              final alert = alerts[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(
                    alert.type == 'sos'
                        ? Icons.warning
                        : alert.type == 'checkin'
                            ? Icons.check_circle
                            : Icons.medication,
                    size: 32,
                  ),
                  title: Text(
                    alert.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '${alert.message}\n${alert.date}',
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}