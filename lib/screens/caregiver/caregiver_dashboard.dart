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

  static const Color primaryGreen = Color(0xFF738F52);
  static const Color darkGreen = Color(0xFF536B3A);
  static const Color lightGreen = Color(0xFFE8EFDF);
  static const Color backgroundColor = Color(0xFFF7F9F3);
  static const Color textColor = Color(0xFF26301F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Caregiver Dashboard',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          int crossAxisCount;

          if (constraints.maxWidth >= 1100) {
            crossAxisCount = 3;
          } else if (constraints.maxWidth >= 650) {
            crossAxisCount = 2;
          } else {
            crossAxisCount = 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _welcomeCard(),
                const SizedBox(height: 28),

                const Text(
                  'Care Management',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio:
                      crossAxisCount == 3 ? 2.0 : 1.7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _dashboardCard(
                      context,
                      title: 'Medicines',
                      description: 'Manage medicines',
                      icon: Icons.medication_outlined,
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
                      description: 'Manage appointments',
                      icon: Icons.calendar_month_outlined,
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
                      description: 'Manage contacts',
                      icon: Icons.contact_phone_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                EmergencyContactsScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),
                    _dashboardCard(
                      context,
                      title: 'Nearby Services',
                      description: 'Hospitals, shops & more',
                      icon: Icons.location_on_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NearbyServicesScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),

                    _dashboardCard(
                      context,
                      title: 'Medical Summary',
                      description: 'View medical information',
                      icon: Icons.medical_information_outlined,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MedicalSummaryScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                const Text(
                  'Monitoring & History',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 14),

                GridView.count(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio:
                      crossAxisCount == 3 ? 2.0 : 1.7,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _dashboardCard(
                      context,
                      title: 'Elder Status',
                      description: 'View current status',
                      icon: Icons.person_outline,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ElderStatusScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),
                    _dashboardCard(
                      context,
                      title: 'Check-in History',
                      description: 'View check-in records',
                      icon: Icons.check_circle_outline,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CheckInHistoryScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),
                    _dashboardCard(
                      context,
                      title: 'Activity History',
                      description: 'View elder activities',
                      icon: Icons.history,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ActivityHistoryScreen(
                              elderId: elderId,
                            ),
                          ),
                        );
                      },
                    ),
                    _dashboardCard(
                      context,
                      title: 'Alerts',
                      description: 'View important alerts',
                      icon: Icons.notifications_outlined,
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
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _welcomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryGreen,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.favorite_outline,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 18),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caregiver Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Manage and monitor your elder’s care in one place.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: lightGreen,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: darkGreen,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: primaryGreen,
              ),
            ],
          ),
        ),
      ),
    );
  }
}