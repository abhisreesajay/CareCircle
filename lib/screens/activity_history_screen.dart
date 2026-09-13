import 'package:flutter/material.dart';
import '../models/activity_history_model.dart';

class ActivityHistoryScreen extends StatelessWidget {
  const ActivityHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final activities = [
      ActivityHistory(
        id: '1',
        activity: 'Check-in completed',
        date: '12 Sep 2026',
        time: '09:05 AM',
      ),
      ActivityHistory(
        id: '2',
        activity: 'Medicine acknowledged',
        date: '12 Sep 2026',
        time: '09:10 AM',
      ),
      ActivityHistory(
        id: '3',
        activity: 'Check-in completed',
        date: '11 Sep 2026',
        time: '09:03 AM',
      ),
      ActivityHistory(
        id: '4',
        activity: 'Check-in missed',
        date: '10 Sep 2026',
        time: '09:30 AM',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: activities.length,
        itemBuilder: (context, index) {
          final activity = activities[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const Icon(Icons.history),
              title: Text(activity.activity),
              subtitle: Text(
                '${activity.date} • ${activity.time}',
              ),
            ),
          );
        },
      ),
    );
  }
}