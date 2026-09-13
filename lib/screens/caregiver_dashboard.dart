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
  final String elderId;

  const CaregiverDashboard({
    super.key,
    required this.elderId,
  });

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
                  builder: (context) => MedicinesScreen(
                    elderId: elderId,
                  ),
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
                  builder: (context) => AppointmentsScreen(
                    elderId: elderId,
                  ),
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
                  builder: (context) => EmergencyContactsScreen(
                    elderId: elderId,
                  ),
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
                  builder: (context) => ElderStatusScreen(
                    elderId: elderId,
                  ),
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
                  builder: (context) => NearbyServicesScreen(
                    elderId: elderId,
                  ),
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
                  builder: (context) => CheckInHistoryScreen(
                    elderId: elderId,
                  ),
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
                  builder: (context) => ActivityHistoryScreen(
                    elderId: elderId,
                  ),
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
                  builder: (context) => MedicalSummaryScreen(
                    elderId: elderId,
                  ),
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
                  builder: (context) => AlertsScreen(
                    elderId: elderId,
                  ),
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