import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/admin/admin_service.dart';

class AdminCirclesTab extends StatelessWidget {
  final AdminService adminService;
  const AdminCirclesTab({super.key, required this.adminService});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Care Circles', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: adminService.streamCareCircles(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('No active care circles registered.'));
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return Card(
                      child: ListTile(
                        leading: const Icon(Icons.group_work, color: Colors.deepPurple),
                        title: Text('Circle ID: ${docs[index].id}'),
                        subtitle: Text('Elder ID: ${data['elderId'] ?? 'Unassigned'}'),
                        trailing: Chip(
                          label: Text('${(data['caregiverIds'] as List?)?.length ?? 0} Caregivers'),
                        ),
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
