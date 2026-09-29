import 'package:flutter/material.dart';
import '../../../services/admin/admin_service.dart';

class AdminOverviewTab extends StatelessWidget {
  final AdminService adminService;
  const AdminOverviewTab({super.key, required this.adminService});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: adminService.streamSystemMetrics(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final data = snapshot.data!;

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('System Metrics', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 4 : 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _statCard('Elders', '${data['totalElders']}', Icons.elderly, Colors.blue),
                  _statCard('Caregivers', '${data['totalCaregivers']}', Icons.health_and_safety, Colors.green),
                  _statCard('Active Circles', '${data['activeCircles']}', Icons.group, Colors.purple),
                  _statCard('Active Alerts', '${data['pendingAlerts']}', Icons.warning_amber, Colors.red),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: color),
            const SizedBox(height: 8),
            Text(value, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
