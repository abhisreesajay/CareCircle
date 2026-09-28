import 'package:flutter/material.dart';
import '../../models/check_in_history_model.dart';
import '../../services/caregiver/check_in_history_service.dart';

class CheckInHistoryScreen extends StatelessWidget {
  final String elderId;

  const CheckInHistoryScreen({
    super.key,
    required this.elderId,
  });

  @override
  Widget build(BuildContext context) {
    final service = CheckInHistoryService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Check-in History'),
      ),
      body: StreamBuilder<List<CheckInHistory>>(
        stream: service.getCheckInHistory(elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load check-in history',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final history = snapshot.data ?? [];

          if (history.isEmpty) {
            return const Center(
              child: Text(
                'No check-in history available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
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
          );
        },
      ),
    );
  }
}