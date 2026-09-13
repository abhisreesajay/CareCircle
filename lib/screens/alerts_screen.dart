import 'package:flutter/material.dart';
import '../models/alert_model.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final alerts = [
      CareAlert(
        id: '1',
        title: 'Missed Check-in',
        message: 'The elder missed the scheduled check-in.',
        date: '12 Sep 2026, 09:30 AM',
        type: 'checkin',
      ),
      CareAlert(
        id: '2',
        title: 'Medicine Reminder',
        message: 'Medicine acknowledgement is pending.',
        date: '12 Sep 2026, 10:00 AM',
        type: 'medicine',
      ),
      CareAlert(
        id: '3',
        title: 'SOS Alert',
        message: 'An SOS alert was received.',
        date: '11 Sep 2026, 06:20 PM',
        type: 'sos',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alerts'),
      ),
      body: ListView.builder(
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
      ),
    );
  }
}