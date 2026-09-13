import 'package:flutter/material.dart';
import '../models/activity_history_model.dart';
import '../services/activity_history_service.dart';

class ActivityHistoryScreen extends StatelessWidget {
  final String elderId;

  const ActivityHistoryScreen({
    super.key,
    required this.elderId,
  });

  @override
  Widget build(BuildContext context) {
    final service = ActivityHistoryService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity History'),
      ),
      body: StreamBuilder<List<ActivityHistory>>(
        stream: service.getActivityHistory(elderId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load activity history',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final activities = snapshot.data ?? [];

          if (activities.isEmpty) {
            return const Center(
              child: Text(
                'No activity history available',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
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
          );
        },
      ),
    );
  }
}