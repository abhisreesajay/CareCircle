import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/admin/admin_service.dart';
import 'tabs/admin_overview_tab.dart';
import 'tabs/admin_users_tab.dart';
import 'tabs/admin_circles_tab.dart';
import 'tabs/admin_alerts_tab.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('CareCircle Admin Operations'),
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Sync Platform',
            onPressed: () => setState(() {}),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign Out',
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            extended: isDesktop,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            labelType: isDesktop
                ? NavigationRailLabelType.none
                : NavigationRailLabelType.selected,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Overview'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.people_outline),
                selectedIcon: Icon(Icons.people),
                label: Text('Users'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.diversity_3_outlined),
                selectedIcon: Icon(Icons.diversity_3),
                label: Text('Care Circles'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.emergency_outlined),
                selectedIcon: Icon(Icons.emergency, color: Colors.red),
                label: Text('System Alerts'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: IndexedStack(
              index: _selectedIndex,
              children: [
                AdminOverviewTab(adminService: _adminService),
                AdminUsersTab(adminService: _adminService),
                AdminCirclesTab(adminService: _adminService),
                AdminAlertsTab(adminService: _adminService),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
