import 'package:flutter/material.dart';
import '../models/check_in_history_model.dart';

class CheckInHistoryScreen extends StatelessWidget {
  const CheckInHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = [
      CheckInHistory(
        id: '1',
        date: '12 Sep 2026',
        scheduledTime: '09:00 AM',
        status: 'COMPLETED',
      ),
      CheckInHistory(
        id: '2',
        date: '11 Sep 2026',
        scheduledTime: '09:00 AM',
        status: 'COMPLETED',
      ),
      CheckInHistory(
        id: '3',
        date: '10 Sep 2026',
        scheduledTime: '09:00 AM',
        status: 'MISSED',
      ),
      CheckInHistory(
        id: '4',
        date: '09 Sep 2026',
        scheduledTime: '09:00 AM',
        status: 'COMPLETED',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final checkIn = history[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: Icon(
                checkIn.status == 'COMPLETED'
                    ? Icons.check_circle
                    : Icons.cancel,
              ),
              title: Text(checkIn.date),
              subtitle: Text(
                'Scheduled: ${checkIn.scheduledTime}',
              ),
              trailing: Text(
                checkIn.status,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}