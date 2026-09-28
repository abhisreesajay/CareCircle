import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/admin/admin_service.dart';

class AdminAlertsTab extends StatelessWidget {
  final AdminService adminService;
  const AdminAlertsTab({super.key, required this.adminService});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('System Emergency Logs & Active SOS', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: adminService.streamActiveAlerts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('No system alerts or active SOS.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final alertId = docs[index].id;
                    final status = data['status'] ?? 'unknown';

                    return Card(
                      color: status == 'active' ? Colors.red.shade50 : null,
                      child: ListTile(
                        leading: Icon(
                          Icons.warning,
                          color: status == 'active' ? Colors.red : Colors.grey,
                        ),
                        title: Text(data['title'] ?? 'Emergency Alert'),
                        subtitle: Text('Status: $status | Elder ID: ${data['elderId'] ?? 'N/A'}'),
                        trailing: status == 'active'
                            ? ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                                onPressed: () => adminService.resolveEmergencyAlert(alertId),
                                child: const Text('Override & Resolve'),
                              )
                            : const Chip(label: Text('Resolved')),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
