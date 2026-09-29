import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../services/admin/admin_service.dart';

class AdminUsersTab extends StatefulWidget {
  final AdminService adminService;
  const AdminUsersTab({super.key, required this.adminService});

  @override
  State<AdminUsersTab> createState() => _AdminUsersTabState();
}

class _AdminUsersTabState extends State<AdminUsersTab> {
  String _selectedRole = 'all';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('User Accounts', style: Theme.of(context).textTheme.headlineSmall),
              DropdownButton<String>(
                value: _selectedRole,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Roles')),
                  DropdownMenuItem(value: 'admin', child: Text('Admins')),
                  DropdownMenuItem(value: 'caregiver', child: Text('Caregivers')),
                  DropdownMenuItem(value: 'elder', child: Text('Elders')),
                ],
                onChanged: (val) => setState(() => _selectedRole = val!),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: widget.adminService.streamUsers(roleFilter: _selectedRole),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final uid = docs[index].id;
                    final role = data['role'] ?? 'elder';
                    final isDisabled = data['disabled'] ?? false;

                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(child: Text(role[0].toUpperCase())),
                        title: Text(data['name'] ?? data['email'] ?? 'Unnamed User'),
                        subtitle: Text('UID: $uid | Role: $role'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            DropdownButton<String>(
                              value: ['admin', 'caregiver', 'elder'].contains(role) ? role : 'elder',
                              items: const [
                                DropdownMenuItem(value: 'admin', child: Text('Admin')),
                                DropdownMenuItem(value: 'caregiver', child: Text('Caregiver')),
                                DropdownMenuItem(value: 'elder', child: Text('Elder')),
                              ],
                              onChanged: (newRole) {
                                if (newRole != null) widget.adminService.updateUserRole(uid, newRole);
                              },
                            ),
                            Switch(
                              value: !isDisabled,
                              onChanged: (val) => widget.adminService.toggleUserAccountStatus(uid, val),
                            ),
                          ],
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
