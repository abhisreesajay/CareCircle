import 'package:flutter/material.dart';

import 'medicines_screen.dart';
import 'appointments_screen.dart';
import 'emergency_contacts_screen.dart';
import 'nearby_services_screen.dart';
import 'elder_status_screen.dart';
import 'check_in_history_screen.dart';
import 'activity_history_screen.dart';
import 'medical_summary_screen.dart';
import 'alerts_screen.dart';

class CaregiverDashboard extends StatelessWidget {
  const CaregiverDashboard({super.key});

  static const String elderId = 'test_elder_001';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Dashboard'),
      ),
      body: GridView.count(
        padding: const EdgeInsets.all(16),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          _dashboardCard(
            context,
            title: 'Medicines',
            icon: Icons.medication,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const MedicinesScreen(elderId: elderId),
                ),
              );
            },
          ),
          _dashboardCard(
            context,
            title: 'Appointments',
            icon: Icons.calendar_month,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const AppointmentsScreen(elderId: elderId),
                ),
              );
            },
          ),
          _dashboardCard(
            context,
            title: 'Emergency Contacts',
            icon: Icons.contact_phone,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const EmergencyContactsScreen(elderId: elderId),
                ),
              );
            },
          ),
          _dashboardCard(
            context,
            title: 'Elder Status',
            icon: Icons.person,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ElderStatusScreen(),
                ),
              );
            },
          ),
          _dashboardCard(
            context,
            title: 'Nearby Services',
            icon: Icons.location_on,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      const NearbyServicesScreen(elderId: elderId),
                ),
              );
            },
          ),
          _dashboardCard(
            context,
            title: 'Check-in History',
            icon: Icons.history,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CheckInHistoryScreen(),
                ),
              );
            },
          ),
          _dashboardCard(
            context,
            title: 'Activity History',
            icon: Icons.history_toggle_off,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ActivityHistoryScreen(),
                ),
              );
            },
          ),
          _dashboardCard(
            context,
            title: 'Medical Summary',
            icon: Icons.medical_information,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MedicalSummaryScreen(),
                ),
              );
            },
          ),
          _dashboardCard(
            context,
            title: 'Alerts',
            icon: Icons.notifications,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AlertsScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 40,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}